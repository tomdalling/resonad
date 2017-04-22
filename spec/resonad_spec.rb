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
      expect{ subject.error }.to raise_error(Resonad::NonExistentError)
    end

    it 'can map the value' do
      result = subject.map { |value| value + ' world' }
      expect(result.value).to eq('hello world')
    end

    it 'is optimised when mapping to the same value' do
      result = subject.map{ |value| value }
      expect(result).to be(subject)
    end

    it "can be flat_map'd" do
      result = subject.flat_map{ |value| value + ' moto' }
      expect(result).to eq('hello moto')
    end

    it "can not be flat_map_error'd" do
      result = subject.flat_map_error{ |error| fail('shouldnt run this') }
      expect(result).to be(subject)
    end

    it 'wont map an error' do
      result = subject.map_error { |error| fail('shouldnt run this') }
      expect(result).to be(subject)
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
      expect{ subject.value }.to raise_error(Resonad::NonExistentValue)
    end

    it "can not be map'd" do
      result = subject.map { |value| fail }
      expect(result).to be(subject)
    end

    it 'can map the error' do
      result = subject.map_error { |error| "Fizz #{error}" }
      expect(result.error).to eq('Fizz buzz')
    end

    it 'is optimised when mapping the error results in no change' do
      result = subject.map_error { |error| error }
      expect(result).to be(subject)
    end

    it "can not be flat_map'd" do
      result = subject.map{ |value| fail }
      expect(result).to be(subject)
    end

    it "can be flat_map_error'd" do
      result = subject.flat_map_error{ |error| error.to_s }
      expect(result).to eq('buzz')
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

  describe '#rescuing_from' do
    it 'is successful if no exception is raised' do
      result = Resonad.rescuing_from { 'hello' }
      expect(result).to be_success
      expect(result.value).to eq('hello')
    end

    it 'rescues the specified kinds of exceptions' do
      result = Resonad.rescuing_from(ArgumentError, ZeroDivisionError) do
        raise ArgumentError
      end
      expect(result).to be_failure
      expect(result.error).to be_a(ArgumentError)
    end

    it 'does not rescue unspecified exceptions' do
      expect {
        Resonad.rescuing_from(ArgumentError, ZeroDivisionError) do
          raise NameError
        end
      }.to raise_error(NameError)
    end

    it 'rescues subtypes of specified exceptions' do
      result = Resonad.rescuing_from(StandardError) { raise NoMethodError }
      expect(result).to be_failure
      expect(result.error).to be_a(NoMethodError)
    end

    it 'rescues all exceptions, if none are specified' do
      result = Resonad.rescuing_from { raise ArgumentError }
      expect(result).to be_failure
      expect(result.error).to be_a(ArgumentError)
    end
  end
end
