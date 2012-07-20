require File.expand_path('../boot.rb', File.dirname(__FILE__))
require 'em-spec/rspec'

Server.new(
  env: "test",
  config: "./config",
  listen: "127.0.0.1",
  port: 15001
)

Dir[File.dirname(__FILE__)+"/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.include EM::SpecHelper
  config.include ServerHelper
  config.include FakeModels
end
