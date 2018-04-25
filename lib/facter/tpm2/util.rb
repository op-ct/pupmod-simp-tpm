require 'yaml'

module Facter; end
module Facter::TPM2; end

class Facter::TPM2::Util
  attr_accessor :result

  def initialize
    @prefix = Facter::TPM2::Util.tpm2_tools_prefix
  end

  # Facter execute from tpm2-tools path
  def exec(cmd)
    Facter::Core::Execution.execute(File.join(@prefix,cmd))
  end


  def uint32_to_s(num)
    ('%x' % num).scan(/.{2}/).map{|x| x.hex.chr }.join
  end
  # return a structured fact
  def build_structured_fact
    # fail fast
    return nil unless @prefix                 # must have tpm2-tools installed
    return nil unless exec('tpm2_pcrlist -s') # must have access to TPM

    _yaml = exec('tpm2_getcap -c properties-fixed')
    properties_fixed = YAML.load(_yaml)

    # Translate the TPM_PT_MANUFACTURER number into the TCG-regisred ID strings
    #   (registry at: https://trustedcomputinggroup.org/vendor-id-registry/)
    tpm2_manufacturer_str =
      uint32_to_s(properties_fixed['TPM_PT_MANUFACTURER'])

    # When in failure mode, the TPM is only required to provide the following properties:
    result = {
      :vendor =>
        {
          :manufacturer         => tpm2_manufacturer,
          :manufacturer_numeric => properties_fixed['TPM_PT_MANUFACTURER'],
          :vendor_string_1      => properties_fixed['TPM_PT_VENDOR_STRING_1'],
          :vendor_string_2      => properties_fixed['TPM_PT_VENDOR_STRING_2'],
          :vendor_string_3      => properties_fixed['TPM_PT_VENDOR_STRING_3'],
          :vendor_string_4      => properties_fixed['TPM_PT_VENDOR_STRING_4'],
          :tpm_type             => properties_fixed['TPM_PT_VENDOR_TPM_TYPE'],
          :firmware_version_1   => properties_fixed['TPM_PT_FIRMWARE_VERSION_1'],
          :firmware_version_2   => properties_fixed['TPM_PT_FIRMWARE_VERSION_2'],
        }
    }
    result
  end

  # Returns the path of the tpm2-tools binaries
  # @return [String,nil] the first valid path found, or `nil` if no paths
  #                      were found.
  def self.tpm2_tools_prefix(paths=['/usr/local/bin', '/usr/bin'])
    _cmd = 'tpm2_pcrlist'
    tpm2_bin_path = nil
    paths.each do |_path|
      if File.executable? File.join( _path, _cmd )
        tpm2_bin_path = _path
        break
      end
    end
    return tpm2_bin_path
  end

end
