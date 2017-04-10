require "spec_helper"

RSpec.describe Resonad do
  describe 'Success' do
    subject { Resonad.Success('hello') }

    it 'indicates success' do
      expect(subject).to be_success
    end

    it 'does not indicate failure' do
      expect(subject).not_to be_failure
    end

    it 'contains a value' do
      expect(subject.value).to eq('hello')
    end

    it 'does not contain an error' do
      expect{ subject.error }.to raise_error(Resonad::NonExistantError)
    end

    it 'can map the value' do
      result = subject.map { |value| value + ' world' }
      expect(result.value).to eq('hello world')
    end

    it 'is optimised when mapping to the same value' do
      result = subject.map{ |value| value }
      expect(result).to be(subject)
    end

    it 'can flat_map to a successful resonad' do
      result = subject.flat_map{ |value| Resonad.Success(value + ' moto') }
      expect(result.value).to eq('hello moto')
    end

    it 'can flat_map to a failure resonad' do
      result = subject.flat_map{ |value| Resonad.Failure('boo') }
      expect(result.error).to eq('boo')
    end

    specify '#on_success yields its value, and returns self' do
      result = subject.on_success do |value|
        expect(value).to eq('hello')
      end
      expect(result).to be(subject)
    end

    specify '#on_failure does not yield, and returns self' do
      result = subject.on_failure { raise 'this should not be called' }
      expect(result).to be(subject)
    end
  end

  describe 'Failure' do
    subject { Resonad.Failure(:buzz) }

    it 'does not indicate success' do
      expect(subject).not_to be_success
    end

    it 'indicates failure' do
      expect(subject).to be_failure
    end

    it 'contains an error' do
      expect(subject.error).to eq(:buzz)
    end

    it 'does not contain a value' do
      expect{ subject.value }.to raise_error(Resonad::NonExistantValue)
    end

    it "can not be map'd" do
      result = subject.map { |value| fail }
      expect(result).to be(subject)
    end

    it "can not be flat_map'd" do
      result = subject.map{ |value| fail }
      expect(result).to be(subject)
    end

    specify '#on_success does not yield, and returns self' do
      result = subject.on_success { raise 'this should not be called' }
      expect(result).to be(subject)
    end

    specify '#on_failure yields the error, and returns self' do
      result = subject.on_failure do |error|
        expect(error).to eq(:buzz)
      end
      expect(result).to be(subject)
    end
  end
end
