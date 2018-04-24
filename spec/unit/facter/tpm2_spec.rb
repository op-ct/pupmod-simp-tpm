require 'facter/tpm2/util'

describe Facter::TPM2::Util do
    before(:each) do
#      Facter::Core::Execution.stubs(:execute).with('tpm_version', :timeout => 15).returns File.read('spec/files/tpm/tpm_version.txt')
 #     @tpm_fact = Facter::TPM::Util.new('spec/files/tpm')
    end
end

