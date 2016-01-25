require "spec_helper"
require "yodleeicious/config"

describe Yodleeicious::Config do
  describe "#base_url" do
    it "default value is nil" do
      Yodleeicious::Config.base_url = nil
    end
  end

  describe "#cobranded_username" do
    it "default value is nil" do
      Yodleeicious::Config.cobranded_username = nil
    end
  end

  describe "#cobranded_password" do
    it "default value is nil" do
      Yodleeicious::Config.cobranded_password = nil
    end
  end

  describe "#proxy_url" do
    it "default value is nil" do
      Yodleeicious::Config.proxy_url = nil
    end
  end

  describe "#base_url=" do
    it "can set value" do
      Yodleeicious::Config.base_url = 'http://someurl'
      expect(Yodleeicious::Config.base_url).to eq('http://someurl')
    end
  end

  describe "#cobranded_username=" do
    it "can set value" do
      Yodleeicious::Config.cobranded_username = 'some username'
      expect(Yodleeicious::Config.cobranded_username).to eq('some username')
    end
  end

  describe "#cobranded_password=" do
    it "can set value" do
      Yodleeicious::Config.cobranded_password = 'some password'
      expect(Yodleeicious::Config.cobranded_password).to eq('some password')
    end
  end

  describe "#proxy_url=" do
    it "can set value" do
      Yodleeicious::Config.proxy_url = 'http://someurl'
      expect(Yodleeicious::Config.proxy_url).to eq('http://someurl')
    end
  end

  describe "#logger="do
    let(:logger) { Logger.new(STDOUT) }
    it "can set value" do
      Yodleeicious::Config.logger = logger
      expect(Yodleeicious::Config.logger).to eq(logger)
    end
  end

end
