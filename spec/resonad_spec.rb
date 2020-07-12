require "spec_helper"

RSpec.describe Resonad do
  AND_THEN_ALIASES = [:and_then, :flat_map]
  OR_ELSE_ALIASES = [:or_else, :otherwise, :flat_map_error]
  SUCCESS_ALIASES = [:success?, :successful?, :ok?]
  FAILURE_ALIASES = [:failure?, :failed?, :bad?]
  MAP_ALIASES = [:map, :map_value]

  describe 'Success' do
    subject { Resonad.Success('hello') }

    SUCCESS_ALIASES.each do |method|
      it "##{method} indicates success" do
        expect(subject.send(method)).to be(true)
      end
    end

    FAILURE_ALIASES.each do |method|
      it "##{method} does not indicate failure" do
        expect(subject.send(method)).to be(false)
      end
    end

    it 'contains a value' do
      expect(subject.value).to eq('hello')
    end

    it 'does not contain an error' do
      expect{ subject.error }.to raise_error(Resonad::NonExistentError)
    end

    MAP_ALIASES.each do |method|
      specify "##{method} maps the value" do
        result = subject.public_send(method) { |value| value + ' world' }
        expect(result.value).to eq('hello world')
      end

      specify "##{method} is optimised when mapping to the same value" do
        result = subject.public_send(method) { |value| value }
        expect(result).to be(subject)
      end
    end

    AND_THEN_ALIASES.each do |method|
      it "can be #{method}'d" do
        result = subject.send(method){ |value| value + ' moto' }
        expect(result).to eq('hello moto')
      end
    end

    OR_ELSE_ALIASES.each do |method|
      it "can not be #{method}'d" do
        result = subject.send(method){ |error| fail('shouldnt run this') }
        expect(result).to be(subject)
      end
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

    SUCCESS_ALIASES.each do |method|
      it "##{method} does not indicate success" do
        expect(subject.send(method)).to be(false)
      end
    end

    FAILURE_ALIASES.each do |method|
      it "##{method} indicates failure" do
        expect(subject.send(method)).to be(true)
      end
    end

    it 'contains an error' do
      expect(subject.error).to eq(:buzz)
    end

    it 'does not contain a value' do
      expect{ subject.value }.to raise_error(Resonad::NonExistentValue)
    end

    MAP_ALIASES.each do |method|
      specify "##{method} does nothing" do
        result = subject.public_send(method) { |value| fail }
        expect(result).to be(subject)
      end
    end

    it 'can map the error' do
      result = subject.map_error { |error| "Fizz #{error}" }
      expect(result.error).to eq('Fizz buzz')
    end

    it 'is optimised when mapping the error results in no change' do
      result = subject.map_error { |error| error }
      expect(result).to be(subject)
    end

    AND_THEN_ALIASES.each do |method|
      it "can not be #{method}'d" do
        result = subject.send(method){ |value| fail }
        expect(result).to be(subject)
      end
    end

    OR_ELSE_ALIASES.each do |method|
      it "can be #{method}'d" do
        result = subject.flat_map_error{ |error| error.to_s }
        expect(result).to eq('buzz')
      end
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

  describe Resonad::Mixin do
    module MixinHost
      extend Resonad::Mixin
    end

    it 'has a Success constructor' do
      result = MixinHost.Success(5)
      expect(result).to be_a(Resonad::Success)
      expect(result.value).to eq(5)
    end

    it 'has a Failure constructor' do
      result = MixinHost.Failure(:buzz)
      expect(result).to be_a(Resonad::Failure)
      expect(result.error).to eq(:buzz)
    end

    describe 'default nil value optimisation' do
      specify '#Success' do
        result = Resonad.Success
        expect(result.value).to be_nil
        expect(result).to be(Resonad.Success)
      end

      specify '#Failure' do
        result = Resonad.Failure
        expect(result.error).to be_nil
        expect(result).to be(Resonad.Failure)
      end
    end
  end
end
