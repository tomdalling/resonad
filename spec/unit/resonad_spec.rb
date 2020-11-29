RSpec.describe Resonad do
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
