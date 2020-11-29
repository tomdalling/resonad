RSpec.describe Resonad::Success do
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

  describe 'success predicate' do
    Naming::SUCCESS_ALIASES.each do |success|
      specify "##{success} indicates success" do
        expect(subject.public_send(success)).to be(true)
      end
    end
  end

  describe 'failure predicate' do
    Naming::FAILURE_ALIASES.each do |failure|
      specify "##{failure} does not indicate failure" do
        expect(subject.public_send(failure)).to be(false)
      end
    end
  end

  it 'contains a value' do
    expect(subject.value).to eq('hello')
  end

  it 'does not contain an error' do
    expect{ subject.error }.to raise_error(Resonad::NonExistentError)
  end

  describe 'mapping values' do
    Naming::MAP_ALIASES.each do |map|
      specify "##{map} maps the value" do
        result = subject.public_send(map) { |value| value + ' world' }
        expect(result.value).to eq('hello world')
      end

      specify "##{map} is optimised when mapping to the same value" do
        result = subject.public_send(map) { |value| value }
        expect(result).to be(subject)
      end
    end
  end

  context 'success chaining' do
    Naming::AND_THEN_ALIASES.each do |and_then|
      it "can be ##{and_then}'d" do
        result = subject.public_send(and_then){ |value| value + ' moto' }
        expect(result).to eq('hello moto')
      end
    end
  end

  context 'failure chaining' do
    Naming::OR_ELSE_ALIASES.each do |or_else|
      it "can not be ##{or_else}'d" do
        result = subject.public_send(or_else){ |error| fail('shouldnt run this') }
        expect(result).to be(subject)
      end
    end
  end

  it 'wont map an error' do
    result = subject.map_error { |error| fail('shouldnt run this') }
    expect(result).to be(subject)
  end

  context 'success callbacks' do
    Naming::ON_SUCCESS_ALIASES.each do |on_success|
      specify "##{on_success} yields its value, and returns self" do
        result = subject.public_send(on_success) do |value|
          expect(value).to eq('hello')
        end
        expect(result).to be(subject)
      end
    end
  end

  context 'failure callbacks' do
    Naming::ON_FAILURE_ALIASES.each do |on_failure|
      specify "##{on_failure} does not yield, and returns self" do
        result = subject.public_send(on_failure) { raise 'this should not be called' }
        expect(result).to be(subject)
      end
    end
  end
end
