require "yodlicious"

describe Yodlicious::YodleeApi, focus: true do

  context 'When a new YodleeApi instance is not configured' do
    it 'no base_url set' do
      expect(subject.base_url).to be_nil
    end

    it 'no cobranded_username is set' do
      expect(subject.cobranded_username).to be_nil
    end

    it 'no cobranded_password is set' do
      expect(subject.cobranded_password).to be_nil
    end

    it 'no proxy_url is set' do
      expect(subject.proxy_url).to be_nil
    end

    it 'empty proxy_opts are created' do
      expect(subject.proxy_opts).to eq({})
    end

    it 'no socks proxy is used' do
      expect(subject.use_socks?).to eq(false)
    end

  end

  context 'When a new YodleeApi instance is configured with a proxy_url' do
    let(:config) { 
                   { 
                     base_url: "https://rest.developer.yodlee.com/services/srest/restserver/v1.0",
                     cobranded_username: "some_username",
                     cobranded_password: "some_password",
                     proxy_url: "socks5h://127.0.0.1:1080"
                   }
                 }

    before { subject.configure(config) }

    it 'the base url is set' do
      expect(subject.base_url).to eq(config[:base_url])
    end

    it 'the cobranded_username is set' do
      expect(subject.cobranded_username).to eq(config[:cobranded_username])
    end

    it 'the cobranded_password is set' do
      expect(subject.cobranded_password).to eq(config[:cobranded_password])
    end

    it 'the proxy_url is set' do
      expect(subject.proxy_url).to eq(config[:proxy_url])
    end

    it 'the proxy_opts are created' do
      proxy_opts = {
        socks: true,
        uri: config[:proxy_url]
      }
      expect(subject.proxy_opts).to eq(proxy_opts)
    end

    it 'the socks proxy is used' do
      expect(subject.use_socks?).to eq(true)
    end

  end

  context 'When a new YodleeApi instance is configured with no proxy_url' do
    let(:config) { 
                   { 
                     base_url: "https://rest.developer.yodlee.com/services/srest/restserver/v1.0",
                     cobranded_username: "some_username",
                     cobranded_password: "some_password"
                   }
                 }

    before { subject.configure(config) }

    it 'the base url is set' do
      expect(subject.base_url).to eq(config[:base_url])
    end

    it 'the cobranded_username is set' do
      expect(subject.cobranded_username).to eq(config[:cobranded_username])
    end

    it 'the cobranded_password is set' do
      expect(subject.cobranded_password).to eq(config[:cobranded_password])
    end

    it 'no proxy_url is set' do
      expect(subject.proxy_url).to be_nil
    end

    it 'no proxy_opts are created' do
      expect(subject.proxy_opts).to eq({})
    end

    it 'the socks proxy is not used' do
      expect(subject.use_socks?).to eq(false)
    end
  end
end