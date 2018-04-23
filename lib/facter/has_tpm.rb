# Detects whether or not the machine has a TPM
Facter.add('has_tpm') do
  confine :kernel => 'Linux'

  setcode do
    result = false
    # Testing for Physical TPM 0
    #
    # This test works for:
    #
    # - TPM 1.2
    # - TPM 2.0, with TAB/RM configured to use the local TPM device `/dev/tpm0`
    #
    # It does not work for/consider:
    #
    # - TPM 2.0, when the RM/TCTI is configured to use `socket` or `tabrmd`
    # - Non-zero TPM devices (e.g., `/dev/tmp1`, `/dev/tmp2`, etc.,)
    # - VTPMs
    #
    # Notes from tpm2-tools 3.0.3:
    #
    # - Using the tpm directly requires the users to ensure that concurrent
    #   access does not occur and that they  manage  the  tpm  resources.
    # - These tasks are usually managed by a resource manager.
    # - Linux 4.12 and greater supports an in kernel resource manager at
    #   `/dev/tpmrm`, typically `/dev/tpmrm0`.
    result = File.exists?('/dev/tpm0')

    unless result
      # Testing for
      _cmd = 'tpm2_pcrlist'
      tpm2_bin_paths = []
      ['/usr/bin', '/usr/local/bin'].each do |_path|
        if File.executable? File.join( _path, _cmd )
          tpm2_bin_paths << _path
        end
      end

      unless tpm2_bin_paths.empty?
        x = Facter::Core::Execution.execute File.join(tpm2_bin_paths.first ,'tpm2_pcrlist -s')
        result = (x =~ %r{^Supported Bank/Algorithm:} ? true : false)
      end
    end

    result
  end
end
