# Provides utilities for interacting with a TPM
#
# @param ima Toggles IMA on or off.
#
# @param take_ownership Enable to allow Puppet to take ownership
#   of the TPM.
#
# @param tpm_name The name of the device (usually tpm0).
#
# @param tpm_version Override for the tpm_version fact.
#
# @param package_ensure The ensure status of packages to be installed
#
# @author SIMP Team https://simp-project.com
#
class tpm (
  Boolean                $ima            = false,
  Boolean                $take_ownership = false,
  String                 $tpm_name       = 'tpm0',
  Optional[Tpm::Version] $tpm_version    = pick($facts['tpm_version'], 'unknown'),
  String                 $package_ensure = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' })
){
  # Check if the system has a TPM (which also checks that it
  # is a physical machine, and if so install tools and setup
  # tcsd service - uses str2bool because facts return as strings :(
  if str2bool($facts['has_tpm']) and $tpm_version  {
    case $tpm_version {
      'tpm1':   { include '::tpm::tpm1::install' }
      'tpm2':   { include '::tpm::tpm2::install' }
      default:  { warning("${module_name}: TPM version - ${tpm_version} - is unknown or not supported.") }
    }
  }
  # If facter doesn't detect a hardware TPM device, but TPM 2.0 has been
  # specified, then 
  elsif $tpm_version == 'tpm2' {
    include '::tpm::tpm2::install'
  }

  if $ima {
    include '::tpm::ima'
  }
}
