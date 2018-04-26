require 'yaml'

module Facter; end

# Namespace for TPM2-related classes
#
# @see Facter::TPM2::Util Facter::TPM2::Util - Utilities for detecting and
#   reporting TPM 2.0 details
module Facter::TPM2; end

# Utilities for detecting and reporting TPM2 information
#
# @note This class requires the following software to be installed on the
#   underlying operating system:
#   - `tpm2-tools` ~> 3.0 (tested with 3.0.3)
#   - (probably) `tpm2-abrmd` ~> 1.2 (tested with 1.2.0)
#   - `tpm2-tools` (and probably `tpm2-abrmd`) must be configured to access TPM
class Facter::TPM2::Util
  def initialize
    @prefix = Facter::TPM2::Util.tpm2_tools_prefix
  end

  # Facter executes a CLI command using the tpm2-tools path
  # @param [String] cmd The CLI command string for Facter to execute
  def exec(cmd)
    Facter::Core::Execution.execute(File.join(@prefix, cmd))
  end

  # Translate the TPM_PT_MANUFACTURER number into the TCG-registered ID strings
  #   (registry at: https://trustedcomputinggroup.org/vendor-id-registry/)
  #
  # @parame [Numeric] number to decode
  # @return [String] the decoded String
  def decode_uint32_string(num)
    # rubocop:disable Style/FormatStringToken
    # NOTE: only strip "\x00" from the end of strings; some registered
    # identifiers include trailing spaces (e.g., 'NSM ')!
    ('%x' % num).scan(/.{2}/).map { |x| x.hex.chr }.join.gsub(/\x00*$/,'')
    # rubocop:enable Style/FormatStringToken
  end

  # Converts two unsigned Integers in a 4-part version string
  def tpm2_firmware_version(tpm_pt_firmware_version_1,tpm_pt_firmware_version_2)
    # rubocop:disable Style/FormatStringToken
    s1 = ('%x' % tpm_pt_firmware_version_1).rjust(8,'0')
    s2 = ('%x' % tpm_pt_firmware_version_2).rjust(8,'0')
    # rubocop:enable Style/FormatStringToken
    (s1.scan(/.{4}/) + s2.scan(/.{4}/)).map{|x| x.hex }.join('.')
  end

  # When in failure mode, the TPM is only required to provide the following
  # properties:
  def failure_safe_properties(tpm2_properties)
    {
      'manufacturer'         => decode_uint32_string(
                                  tpm2_properties['TPM_PT_MANUFACTURER']
                                ),
      'manufacturer_numeric' => tpm2_properties['TPM_PT_MANUFACTURER'],
      'vendor_string_1'      => tpm2_properties['TPM_PT_VENDOR_STRING_1'],
      'vendor_string_2'      => tpm2_properties['TPM_PT_VENDOR_STRING_2'],
      'vendor_string_3'      => tpm2_properties['TPM_PT_VENDOR_STRING_3'],
      'vendor_string_4'      => tpm2_properties['TPM_PT_VENDOR_STRING_4'],
      'tpm_type'             => tpm2_properties['TPM_PT_VENDOR_TPM_TYPE'],
      'firmware_version'     => tpm2_firmware_version(
                                  tpm2_properties['TPM_PT_FIRMWARE_VERSION_1'],
                                  tpm2_properties['TPM_PT_FIRMWARE_VERSION_2']
                                ),
      'firmware_version_1'   => tpm2_properties['TPM_PT_FIRMWARE_VERSION_1'],
      'firmware_version_2'   => tpm2_properties['TPM_PT_FIRMWARE_VERSION_2']
    }
  end

  # Returns a structured fact describing the TPM 2.0 data
  # @return [nil] if TPM data cannot be retrieved.
  # @return [
  def build_structured_fact
    # fail fast
    return nil unless @prefix                 # must have tpm2-tools installed
    return nil unless exec('tpm2_pcrlist -s') # tpm2-tools must report on TPM

    yaml = exec('tpm2_getcap -c properties-fixed')
    properties_fixed = YAML.safe_load(yaml)

    result = {
      'vendor' => failure_safe_properties(properties_fixed)
    }
    result
  end

  # Returns the path of the tpm2-tools binaries
  # @return [String,nil] the first valid path found, or `nil` if no paths
  #                      were found.
  def self.tpm2_tools_prefix(paths = ['/usr/local/bin', '/usr/bin'])
    cmd = 'tpm2_pcrlist'
    tpm2_bin_path = nil
    paths.each do |path|
      if File.executable? File.join(path, cmd)
        tpm2_bin_path = path
        break
      end
    end
    tpm2_bin_path
  end
end
