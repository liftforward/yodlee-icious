unless defined?(SPEC_HELPER_LOADED)
  SPEC_HELPER_LOADED = true

  require "yodlicious"


  RSpec.configure do |config|

    config.filter_run :focus
    config.run_all_when_everything_filtered = true

  end
end