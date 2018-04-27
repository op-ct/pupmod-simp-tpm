require 'spec_helper'

describe 'tpm_version', :type => :fact do

  before :each do
    Facter.clear
    Facter.clear_messages
    # This allow argument seems really wrong and I don't understand it works yet
    allow(Facter.fact(:has_tpm)).to receive(:value).and_return true
  end

  context 'the link exists' do
    before(:each) {
      allow(Dir).to receive(:glob).with('/sys/class/tpm/tpm*').and_return ['/tpm0']
      allow(File).to receive(:symlink?).with('/tpm0').and_return true
    }
    it 'should return tpm2 if MSFT is in the link name' do
      allow(File).to receive(:readlink).with('/tpm0').and_return '../xyz/MSFT00049/foo/bar'
      expect(Facter.fact(:tpm_version).value).to eq  'tpm2'
    end

    it 'should return tpm1 if link exists and no MSFT in name' do
      allow(File).to receive(:readlink).with('/tpm0').and_return '../xyz/foo/bar'
      expect(Facter.fact(:tpm_version).value).to eq  'tpm1'
    end
  end

  context 'the link file is not a link to the device' do
    before (:each) {
      allow(Dir).to receive(:glob).with('/sys/class/tpm/tpm*').and_return ['/tpm0']
      allow(File).to receive(:symlink?).with('/tpm0').and_return false
    }
    it 'should return unknown' do
      expect(Facter.fact(:tpm_version).value).to eq 'unknown'
    end
  end

  context 'There is nothing in the directory' do
    before (:each) {
      allow(Dir).to receive(:glob).with('/sys/class/tpm/tpm*').and_return []
    }
    it 'should return unknown' do
      expect(Facter.fact(:tpm_version).value).to eq 'unknown'
    end
  end

end
