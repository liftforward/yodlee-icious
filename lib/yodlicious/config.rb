module Yodlicious
  class Config

    def self.base_url= url
      @@base_url= url
    end

    def self.cobranded_username username
      @@cobranded_username = username
    end

    def self.cobranded_password password
      @@cobranded_password = password
    end

    #todo logger configuration
  end
end
