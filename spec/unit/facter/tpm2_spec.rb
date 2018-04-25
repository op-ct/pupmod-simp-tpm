require 'facter/tpm2/util'
require 'facter'

describe Facter::TPM2::Util do
  before(:example) do
    @execution = class_double('Facter::Core::Execution')
  end


  describe '::tpm2_tools_prefix' do
    context "tpm2-tools aren't installed" do
      it 'should return nil' do
        allow(File).to receive(:executable?).with('/usr/local/bin/tpm2_pcrlist').and_return( false )
        allow(File).to receive(:executable?).with('/usr/bin/tpm2_pcrlist').and_return( false )
        expect(Facter::TPM2::Util.tpm2_tools_prefix).to eq nil
      end
    end
    context "tpm2-tools are only under /usr/local" do
      it 'should return the correct path' do
        allow(File).to receive(:executable?).with('/usr/local/bin/tpm2_pcrlist').and_return( true )
        allow(File).to receive(:executable?).with('/usr/bin/tpm2_pcrlist').and_return( false )
        expect(Facter::TPM2::Util.tpm2_tools_prefix).to eq '/usr/local/bin'
      end
    end
    context "tpm2-tools are only under /usr" do
      it 'should return the correct path' do
        allow(File).to receive(:executable?).with('/usr/local/bin/tpm2_pcrlist').and_return(false)
        allow(File).to receive(:executable?).with('/usr/bin/tpm2_pcrlist').and_return( true )
        expect(Facter::TPM2::Util.tpm2_tools_prefix).to eq '/usr/bin'
      end
    end
    context "tpm2-tools are installed under both /usr/local AND /usr" do
      it 'should return the most specific path (/usr/local/bin)' do
        allow(File).to receive(:executable?).with('/usr/local/bin/tpm2_pcrlist').and_return( true )
        allow(File).to receive(:executable?).with('/usr/bin/tpm2_pcrlist').and_return( true )
        expect(Facter::TPM2::Util.tpm2_tools_prefix).to eq '/usr/local/bin'
      end
    end
  end

  describe '::tpm2_tools_prefix' do
    context 'has_tpm fact is false' do
      it 'should xxxxxx' do
        allow(Facter::Core::Execution).to receive(:execute).with(
          '/usr/local/bin/tpm2_pcrlist -s'
        ).and_return(
          "Supported Bank/Algorithm: sha1(0x0004) sha256(0x000b) sha384(0x000c)\n"
        )
        expect(Facter.fact(:tpm).value).to eq nil
      end
    end
  end
end
