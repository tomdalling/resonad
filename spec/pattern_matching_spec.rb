RSpec.describe 'Ruby 2.7 pattern matching' do
  describe Resonad::Success do
    subject { described_class.new('hello') }

    it 'deconstructs to an array' do
      case subject
      in [type, value]
        expect(type).to eq(:success)
        expect(value).to eq('hello')
      else
        fail
      end
    end

    it 'deconstructs to a hash' do
      case subject
      in { value: String => x }
        expect(x).to eq('hello')
      else
        fail
      end
    end
  end

  describe Resonad::Failure do
    subject { described_class.new(:oh_noez) }

    it 'deconstructs to an array' do
      case subject
      in [type, value]
        expect(type).to eq(:failure)
        expect(value).to eq(:oh_noez)
      else
        fail
      end
    end

    it 'deconstructs to a hash' do
      case subject
      in { error: :oh_noez }
        # do nothing
      else
        fail
      end
    end
  end
end
