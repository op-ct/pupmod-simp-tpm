require 'beaker-rspec'
require 'tmpdir'
require 'yaml'
require 'simp/beaker_helpers'
include Simp::BeakerHelpers

unless ENV['BEAKER_provision'] == 'no'
  hosts.each do |host|
    # Install Puppet
    if host.is_pe?
      install_pe
    else
      install_puppet
    end
  end
end


def install_tpm2_0_tools
  # install any rpm files in the top-level directory to tmp
  rpm_staging_dir = "/root/rpms.#{$$}"
  extra_file=<<-SYSTEMD.gsub(/^\s*/,'')
  [Service]
  ExecStart=
  ExecStart=/usr/local/sbin/tpm2-abrmd -t socket
  SYSTEMD

  on hosts, "mkdir -p #{rpm_staging_dir}"
  Dir['*.rpm'].each{ |f| scp_to(hosts,f,rpm_staging_dir) }
  on hosts, "yum install -y #{rpm_staging_dir}/*.rpm"
  on hosts, 'runuser tpm2sim --shell /bin/sh -c "cd /tmp; nohup /usr/local/bin/tpm2-simulator &"', pty: true, run_in_parallel: true
  on hosts, 'mkdir -p /etc/systemd/system/tpm2-abrmd.service.d'
  create_remote_file hosts, '/etc/systemd/system/tpm2-abrmd.service.d/override.conf', extra_file
  on hosts, 'systemctl daemon-reload'
  on hosts, 'systemctl start tpm2-abrmd'
end

RSpec.configure do |c|
  # ensure that environment OS is ready on each host
  fix_errata_on hosts

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    begin

      # Install modules and dependencies from spec/fixtures/modules
      copy_fixture_modules_to( hosts )
      begin
        server = only_host_with_role(hosts, 'server')
      rescue ArgumentError =>e
        server = only_host_with_role(hosts, 'default')
      end

      # Generate and install PKI certificates on each SUT
      Dir.mktmpdir do |cert_dir|
        run_fake_pki_ca_on(server, hosts, cert_dir )
        hosts.each{ |sut| copy_pki_to( sut, cert_dir, '/etc/pki/simp-testing' )}
      end

      # add PKI keys
      copy_keydist_to(server)
    rescue StandardError, ScriptError => e
      if ENV['PRY']
        require 'pry'; binding.pry
      else
        raise e
      end
    end
  end
end
