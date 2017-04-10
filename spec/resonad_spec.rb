require "spec_helper"

RSpec.describe Resonad do
  describe 'Success' do
    subject { Resonad.Success('hello') }

    it 'indicates success' do
      expect(subject).to be_success
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
  end

  describe 'Failure' do
    subject { Resonad.Failure(6) }

    it 'indicates failure' do
      expect(subject).not_to be_success
    end

    it 'contains an error' do
      expect(subject.error).to eq(6)
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
  end

  describe Resonad::ConvenienceMethods do
    class Harness
      include Resonad::ConvenienceMethods
    end

    subject { Harness.new }

    it 'provides #failure? which is the opposite of #success?' do
      expect(subject).to receive(:success?).and_return(true)
      expect(subject.failure?).to be(false)
    end

    it 'provides #and_then - a nicer sounding alias for #flat_map' do
      block = Proc.new { |x| x }
      expect(subject).to receive(:flat_map).and_yield(5)
      expect(subject.and_then(&block)).to eq(5)
    end
  end
end
