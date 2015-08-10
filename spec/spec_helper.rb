if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

unless defined?(SPEC_HELPER_LOADED)
  SPEC_HELPER_LOADED = true

  require "yodlicious"
  require 'dotenv'
  Dotenv.load

  RSpec.configure do |config|

    config.filter_run :focus
    config.run_all_when_everything_filtered = true

  end
end