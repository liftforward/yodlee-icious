

module Yodleeicious
  class Config
    class << self
      attr_accessor :base_url, :cobranded_username, :cobranded_password, :proxy_url, :logger
    end
    
    self.logger = Logger.new(STDOUT)
    self.logger.level = Logger::WARN  

  end
end
