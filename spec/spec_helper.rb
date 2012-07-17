require File.expand_path('../boot.rb', File.dirname(__FILE__))
require 'em-spec/rspec'

Server.env = "test"

Dir[File.dirname(__FILE__)+"/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.include EM::SpecHelper
  config.include ServerHelper
  #config.order = 'random'

end
