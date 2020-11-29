RSpec.describe Resonad::Failure do
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

  describe 'success predicate' do
    Naming::SUCCESS_ALIASES.each do |success|
      specify "##{success} does not indicate success" do
        expect(subject.public_send(success)).to be(false)
      end
    end
  end

  describe 'failure predicate' do
    Naming::FAILURE_ALIASES.each do |failure|
      specify "##{failure} indicates failure" do
        expect(subject.public_send(failure)).to be(true)
      end
    end
  end

  it 'contains an error' do
    expect(subject.error).to eq(:buzz)
  end

  it 'does not contain a value' do
    expect{ subject.value }.to raise_error(Resonad::NonExistentValue)
  end

  shared_examples 'higher-order methods (Resonad::Failure)' do
    describe 'mapping values' do
      Naming::MAP_ALIASES.each do |map|
        specify "##{map} does nothing" do
          result = higher_order_send(map) { |value| fail }
          expect(result).to be(subject)
        end
      end
    end

    it 'can map the error' do
      result = higher_order_send(:map_error) { |error| "Fizz #{error}" }
      expect(result.error).to eq('Fizz buzz')
    end

    it 'is optimised when mapping the error results in no change' do
      result = higher_order_send(:map_error) { |error| error }
      expect(result).to be(subject)
    end

    context 'success chaining' do
      Naming::AND_THEN_ALIASES.each do |and_then|
        it "can not be ##{and_then}'d" do
          result = higher_order_send(and_then){ |value| fail }
          expect(result).to be(subject)
        end
      end
    end

    context 'failure chaining' do
      Naming::OR_ELSE_ALIASES.each do |or_else|
        it "can be ##{or_else}'d" do
          result = higher_order_send(:flat_map_error) { |error| error.to_s }
          expect(result).to eq('buzz')
        end
      end
    end

    context 'success callbacks' do
      Naming::ON_SUCCESS_ALIASES.each do |on_success|
        specify "##{on_success} does not yield, and returns self" do
          result = higher_order_send(on_success) { raise 'this should not be called' }
          expect(result).to be(subject)
        end
      end
    end

    context 'failure callbacks' do
      Naming::ON_FAILURE_ALIASES.each do |on_failure|
        specify "##{on_failure} yields the error, and returns self" do
          result = higher_order_send(on_failure) do |error|
            expect(error).to eq(:buzz)
          end
          expect(result).to be(subject)
        end
      end
    end
  end

  context 'higher-order methods using block argument' do
    include_context 'higher_order_send using block argument'
    include_examples 'higher-order methods (Resonad::Failure)'
  end

  context 'higher-order methods using callable positional argument' do
    include_context 'higher_order_send using callable positional argument'
    include_examples 'higher-order methods (Resonad::Failure)'
  end
end
