#
# Installs the TCG Software stack for the TPM and
# and configures service.
#
# @param package_list   The tpm2 packages to install (provided by module data)
# @param package_ensure The ensure status of packages to be installed
# @param take_ownership Whether or not to take ownership of the TPM.
#
# @author SIMP Team https://simp-project.com
#
class tpm::tpm2::install (
  Array[String] $package_list,
  String        $package_ensure = $::tpm::package_ensure,
  Boolean       $take_ownership = $::tpm::take_ownership,
) inherits tpm {

  if !($facts['os']['name'] in ['RedHat','CentOS']) {
    fail("Operating System ${facts['os']['name']} is not supported for TPM 2.0")
  } else {
    if versioncmp($facts['os']['release']['major'],'7') < 0 {
      fail("Operating System ${facts['os']['name']} version ${facts['os']['release']['major']} is not supported for TPM 2.0")
    }
  }

  # Start the resource daemon
  service { 'resourcemgr':
    ensure => 'running',
    enable => true,
  }

  # Install the needed packages
  $package_list.each |String $_name| {
    package{ $_name:
      ensure => $package_ensure,
      before => Service['resourcemgr'],
    }
  }

  if $take_ownership {
    include '::tpm::tpm2::ownership'
  }
}
