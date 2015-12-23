require "spec_helper"
require "yodlicious/config"

describe Yodlicious::Config do
  describe "#base_url" do
    it "default value is nil" do
      Yodlicious::Config.base_url = nil
    end
  end

  describe "#cobranded_username" do
    it "default value is nil" do
      Yodlicious::Config.cobranded_username = nil
    end
  end

  describe "#cobranded_password" do
    it "default value is nil" do
      Yodlicious::Config.cobranded_password = nil
    end
  end

  describe "#proxy_url" do
    it "default value is nil" do
      Yodlicious::Config.proxy_url = nil
    end
  end

  describe "#base_url=" do
    it "can set value" do
      Yodlicious::Config.base_url = 'http://someurl'
      expect(Yodlicious::Config.base_url).to eq('http://someurl')
    end
  end

  describe "#cobranded_username=" do
    it "can set value" do
      Yodlicious::Config.cobranded_username = 'some username'
      expect(Yodlicious::Config.cobranded_username).to eq('some username')
    end
  end

  describe "#cobranded_password=" do
    it "can set value" do
      Yodlicious::Config.cobranded_password = 'some password'
      expect(Yodlicious::Config.cobranded_password).to eq('some password')
    end
  end

  describe "#proxy_url=" do
    it "can set value" do
      Yodlicious::Config.proxy_url = 'http://someurl'
      expect(Yodlicious::Config.proxy_url).to eq('http://someurl')
    end
  end

end
