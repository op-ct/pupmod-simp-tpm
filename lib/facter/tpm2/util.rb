module Facter
  module TPM2
    class Util
      attr_accessor :result

      def initialize
        @sys_path = sys_path
        @tpm2_tools_paths = 

        @result = {
          'sys_path' => sys_path,
          'version'  => version,
          'status'   => status
        }

        @result['pubek'] = pubek(@result['status'])
      end


      def self.tpm2_tools_prefix(paths=['/usr/bin', '/usr/local/bin'])
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
  end
end
