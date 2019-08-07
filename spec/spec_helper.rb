if ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start 'rails'
  puts 'required simplecov'
end

module RSpec
  # DSL method `.its` for writing one-liner specs of `subject` methods
  #
  # @example
  #  subject { Hello.new }
  #  its(:say_hello, 'World') { should eq 'Hello World' }
  module Its
    def its(method, *args, &block)
      describe ":#{method}" do
        subject { super().send(method, *args) }
        it("with args #{args}", &block)
      end
    end
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.extend RSpec::Its
end
