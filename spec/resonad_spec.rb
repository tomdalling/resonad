RSpec.describe Resonad do
  AND_THEN_ALIASES = [:and_then, :flat_map]
  OR_ELSE_ALIASES = [:or_else, :otherwise, :flat_map_error]
  SUCCESS_ALIASES = [:success?, :successful?, :ok?]
  FAILURE_ALIASES = [:failure?, :failed?, :bad?]
  MAP_ALIASES = [:map, :map_value]

  ON_PREFIXES = ["on_", "if_", "when_"]
  ON_SUCCESS_SUFFIXES = SUCCESS_ALIASES.map { |m| m.to_s.chomp('?') }
  ON_FAILURE_SUFFIXES = FAILURE_ALIASES.map { |m| m.to_s.chomp('?') }
  ON_SUCCESS_ALIASES = ON_PREFIXES.product(ON_SUCCESS_SUFFIXES).map(&:join)
  ON_FAILURE_ALIASES = ON_PREFIXES.product(ON_FAILURE_SUFFIXES).map(&:join)

  describe 'Success' do
    subject { Resonad.Success('hello') }

    it "has an alternate, more-standardly-named constructor method" do
      alternate = Resonad.success(subject.value)
      expect(alternate.class).to be(subject.class)
      expect(alternate.value).to be(subject.value)
    end

    it "has an alternate class constructor method" do
      alternate = Resonad::Success[subject.value]
      expect(alternate.class).to be(subject.class)
      expect(alternate.value).to be(subject.value)
    end

    SUCCESS_ALIASES.each do |success|
      specify "##{success} indicates success" do
        expect(subject.public_send(success)).to be(true)
      end
    end

    FAILURE_ALIASES.each do |failure|
      specify "##{failure} does not indicate failure" do
        expect(subject.public_send(failure)).to be(false)
      end
    end

    it 'contains a value' do
      expect(subject.value).to eq('hello')
    end

    it 'does not contain an error' do
      expect{ subject.error }.to raise_error(Resonad::NonExistentError)
    end

    MAP_ALIASES.each do |map|
      specify "##{map} maps the value" do
        result = subject.public_send(map) { |value| value + ' world' }
        expect(result.value).to eq('hello world')
      end

      specify "##{map} is optimised when mapping to the same value" do
        result = subject.public_send(map) { |value| value }
        expect(result).to be(subject)
      end
    end

    AND_THEN_ALIASES.each do |and_then|
      it "can be #{and_then}'d" do
        result = subject.public_send(and_then){ |value| value + ' moto' }
        expect(result).to eq('hello moto')
      end
    end

    OR_ELSE_ALIASES.each do |or_else|
      it "can not be #{or_else}'d" do
        result = subject.public_send(or_else){ |error| fail('shouldnt run this') }
        expect(result).to be(subject)
      end
    end

    it 'wont map an error' do
      result = subject.map_error { |error| fail('shouldnt run this') }
      expect(result).to be(subject)
    end

    ON_SUCCESS_ALIASES.each do |on_success|
      specify "##{on_success} yields its value, and returns self" do
        result = subject.public_send(on_success) do |value|
          expect(value).to eq('hello')
        end
        expect(result).to be(subject)
      end
    end

    ON_FAILURE_ALIASES.each do |on_failure|
      specify "##{on_failure} does not yield, and returns self" do
        result = subject.public_send(on_failure) { raise 'this should not be called' }
        expect(result).to be(subject)
      end
    end
  end

  describe 'Failure' do
    subject { Resonad.Failure(:buzz) }

    it "has an alternate, more-standardly-named constructor method" do
      alternate = Resonad.failure(subject.error)
      expect(alternate.class).to be(subject.class)
      expect(alternate.error).to be(subject.error)
    end

    it "has an alternate class constructor method" do
      alternate = Resonad::Failure[subject.error]
      expect(alternate.class).to be(subject.class)
      expect(alternate.error).to be(subject.error)
    end

    SUCCESS_ALIASES.each do |success|
      specify "##{success} does not indicate success" do
        expect(subject.public_send(success)).to be(false)
      end
    end

    FAILURE_ALIASES.each do |failure|
      specify "##{failure} indicates failure" do
        expect(subject.public_send(failure)).to be(true)
      end
    end

    it 'contains an error' do
      expect(subject.error).to eq(:buzz)
    end

    it 'does not contain a value' do
      expect{ subject.value }.to raise_error(Resonad::NonExistentValue)
    end

    MAP_ALIASES.each do |map|
      specify "##{map} does nothing" do
        result = subject.public_send(map) { |value| fail }
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

    AND_THEN_ALIASES.each do |and_then|
      it "can not be #{and_then}'d" do
        result = subject.public_send(and_then){ |value| fail }
        expect(result).to be(subject)
      end
    end

    OR_ELSE_ALIASES.each do |or_else|
      it "can be #{or_else}'d" do
        result = subject.flat_map_error{ |error| error.to_s }
        expect(result).to eq('buzz')
      end
    end

    ON_SUCCESS_ALIASES.each do |on_success|
      specify "##{on_success} does not yield, and returns self" do
        result = subject.public_send(on_success) { raise 'this should not be called' }
        expect(result).to be(subject)
      end
    end

    ON_FAILURE_ALIASES.each do |on_failure|
      specify "##{on_failure} yields the error, and returns self" do
        result = subject.public_send(on_failure) do |error|
          expect(error).to eq(:buzz)
        end
        expect(result).to be(subject)
      end
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
    class MixinHost
      include Resonad::Mixin
      def gimme_success; Success; end
      def gimme_failure; Failure; end
    end

    def host_eval(&block)
      MixinHost.new.instance_eval(&block)
    end

    it 'has a #Success constructor' do
      result = host_eval { Success(5) }
      expect(result).to be_a(Resonad::Success)
      expect(result.value).to eq(5)
    end

    it 'has a #success constructor' do
      result = host_eval { success(5) }
      expect(result).to be_a(Resonad::Success)
      expect(result.value).to eq(5)
    end

    it 'has the Success class as a constant' do
      expect(host_eval { gimme_success }).to be(Resonad::Success)
    end

    it 'has a #Failure constructor' do
      result = host_eval { Failure(:buzz) }
      expect(result).to be_a(Resonad::Failure)
      expect(result.error).to eq(:buzz)
    end

    it 'has a #failure constructor' do
      result = host_eval { failure(:buzz) }
      expect(result).to be_a(Resonad::Failure)
      expect(result.error).to eq(:buzz)
    end

    it 'has the Failure class as a constant' do
      expect(host_eval { gimme_failure }).to be(Resonad::Failure)
    end

    it 'provides private methods and constants' do
      host = MixinHost.new
      expect { host.success }.to raise_error(NoMethodError, /private method/)
      expect { host.Success }.to raise_error(NoMethodError, /private method/)
      expect { host.failure }.to raise_error(NoMethodError, /private method/)
      expect { host.Failure }.to raise_error(NoMethodError, /private method/)
      expect { MixinHost::Success }.to raise_error(NameError, /private constant/)
      expect { MixinHost::Failure }.to raise_error(NameError, /private constant/)
    end
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
