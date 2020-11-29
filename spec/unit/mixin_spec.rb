RSpec.describe Resonad::Mixin do
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
