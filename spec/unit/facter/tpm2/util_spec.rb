require 'spec_helper'
require 'rspec/mocks'
require 'facter/tpm2/util'

describe Facter::TPM2::Util do
  before :all do
    @l_bin = '/usr/local/bin'
    @u_bin = '/usr/bin'
  end
  describe '::tpm2_tools_prefix' do
    context "tpm2-tools aren't installed" do
      it 'should return nil' do
        allow(File).to receive(:executable?).with("#{@l_bin}/tpm2_pcrlist").and_return( false )
        allow(File).to receive(:executable?).with("#{@u_bin}/tpm2_pcrlist").and_return( false )
        expect(Facter::TPM2::Util.tpm2_tools_prefix).to eq nil
      end
    end
    context "tpm2-tools are only under /usr/local" do
      it 'should return the correct path' do
        allow(File).to receive(:executable?).with("#{@l_bin}/tpm2_pcrlist").and_return( true )
        allow(File).to receive(:executable?).with("#{@u_bin}/tpm2_pcrlist").and_return( false )
        expect(Facter::TPM2::Util.tpm2_tools_prefix).to eq @l_bin
      end
    end
    context "tpm2-tools are only under /usr" do
      it 'should return the correct path' do
        allow(File).to receive(:executable?).with("#{@l_bin}/tpm2_pcrlist").and_return(false)
        allow(File).to receive(:executable?).with("#{@u_bin}/tpm2_pcrlist").and_return( true )
        expect(Facter::TPM2::Util.tpm2_tools_prefix).to eq @u_bin
      end
    end
    context "tpm2-tools are installed under both /usr/local AND /usr" do
      it 'should return the most specific path (/usr/local/bin)' do
        allow(File).to receive(:executable?).with("#{@l_bin}/tpm2_pcrlist").and_return( true )
        allow(File).to receive(:executable?).with("#{@u_bin}/tpm2_pcrlist").and_return( true )
        expect(Facter::TPM2::Util.tpm2_tools_prefix).to eq @l_bin
      end
    end
  end

  describe '#build_structured_fact' do

    context "when tpm2-tools aren't installed" do
      it 'should return nil' do
        allow(File).to receive(:executable?).with("#{@l_bin}/tpm2_pcrlist").and_return( false )
        allow(File).to receive(:executable?).with("#{@u_bin}/tpm2_pcrlist").and_return( false )
        util = Facter::TPM2::Util.new
        expect( util.build_structured_fact ).to be nil
      end
    end

    context "when tpm2-tools are installed" do
      before :each do
        allow(File).to receive(:executable?).with("#{@l_bin}/tpm2_pcrlist").and_return( true )
      end

      context 'when tpm2-tools cannot query the TABRM' do
        it 'should return nil' do
          allow(Facter::Core::Execution).to receive(:execute).with( "#{@l_bin}/tpm2_pcrlist -s").and_return( nil )
          util = Facter::TPM2::Util.new
          expect( util.build_structured_fact ).to be nil
        end
      end
      context 'when tpm2-tools can query the TABRM' do
        before :each do
          allow(Facter::Core::Execution).to receive(:execute).with("#{@l_bin}/tpm2_pcrlist -s").and_return(
            "Supported Bank/Algorithm: sha1(0x0004) sha256(0x000b) sha384(0x000c)\n"
          )
          allow(Facter::Core::Execution).to receive(:execute).with("#{@l_bin}/tpm2_getcap -c properties-fixed").and_return(
            File.read File.expand_path( '../../../../files/tpm2/mocks/tpm2_getcap_-c_properties-fixed/nuvoton-ncpt6xx-fbfc85e.yaml', __FILE__)
          )
        end
        it 'should populate result' do
          util = Facter::TPM2::Util.new
          expect( util.build_structured_fact.is_a? Hash ).to be true
        end
      end
      context 'when tpm2-tools can query the TABRM' do
      end
    end
  end
end
