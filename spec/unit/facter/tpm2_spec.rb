require 'spec_helper'

describe 'tpm', :type => :fact do
  before :each do
    Facter.clear
    Facter.clear_messages
    allow(File).to receive(:executable?).with("#{@l_bin}/tpm2_pcrlist").and_return( true )
  end

  context 'tpm_version is "tpm1"' do
    it 'should return nil' do
      Facter.fact(:has_tpm).stubs(:value).returns(true)
      Facter.fact(:tpm_version).stubs(:value).returns('tpm1')
      Facter::Core::Execution.stubs(:which).with('tpm_version').returns nil
      expect(Facter.fact(:tpm).value).to eq nil
    end
  end
end
