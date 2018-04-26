require 'yaml'

module Facter; end

# Namespace for TPM2-related classes
#
# @see Facter::TPM2::Util Facter::TPM2::Util - Utilities for detecting and
#   reporting TPM 2.0 details
module Facter::TPM2; end

# Utilities for detecting and reporting TPM2 details
#
# @note Requires:
#   - `tpm2-tools` ~> 3.0.3 or later
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

  # Converts an unsigned Integer to String characters
  #
  # This is intended to decode TPM2 strings that are returned as uint32s, such
  # as `TPM_PT_MANUFACTURER`.
  #
  # @parame [Numeric] number to decode
  # @return [String] the decoded String
  def uint32_to_s(num)
    # rubocop:disable Style/FormatStringToken
    format('%x', num).scan(/.{2}/).map { |x| x.hex.chr }.join
    # rubocop:enable Style/FormatStringToken
  end

  # When in failure mode, the TPM is only required to provide the following
  # properties:
  def failure_safe_properties(tpm2_properties)
    # Translate the TPM_PT_MANUFACTURER number into the TCG-regisred ID strings
    #   (registry at: https://trustedcomputinggroup.org/vendor-id-registry/)
    tpm2_manufacturer_str =
      uint32_to_s(tpm2_properties['TPM_PT_MANUFACTURER'])

    {
      manufacturer:          tpm2_manufacturer_str,
      manufacturer_numeric:  tpm2_properties['TPM_PT_MANUFACTURER'],
      vendor_string_1:       tpm2_properties['TPM_PT_VENDOR_STRING_1'],
      vendor_string_2:       tpm2_properties['TPM_PT_VENDOR_STRING_2'],
      vendor_string_3:       tpm2_properties['TPM_PT_VENDOR_STRING_3'],
      vendor_string_4:       tpm2_properties['TPM_PT_VENDOR_STRING_4'],
      tpm_type:              tpm2_properties['TPM_PT_VENDOR_TPM_TYPE'],
      firmware_version_1:    tpm2_properties['TPM_PT_FIRMWARE_VERSION_1'],
      firmware_version_2:    tpm2_properties['TPM_PT_FIRMWARE_VERSION_2']
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
      vendor: failure_safe_properties(properties_fixed)
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
