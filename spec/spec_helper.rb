require "bundler/setup"
require "byebug"
require "resonad"
require "support/naming"

RSpec.shared_context 'higher_order_send using block argument' do
  def higher_order_send(method_name, &block)
    subject.public_send(method_name, &block)
  end
end

RSpec.shared_context 'higher_order_send using callable positional argument' do
  def higher_order_send(method_name, &block)
    subject.public_send(method_name, block)
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
