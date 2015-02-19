module Yodlicious
  class Config
    class << self
      attr_accessor :base_url, :cobranded_username, :cobranded_password, :proxy_url
    end
    
    # def initialize
    #   # @base_url = nil
    # end
  end
end
