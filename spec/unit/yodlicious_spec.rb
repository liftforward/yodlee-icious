require "yodlicious"
require "yodlicious/config"

describe Yodlicious::YodleeApi do

  context 'Given a new uninitialized YodleeApi objecvt' do
    before {
      Yodlicious::Config.base_url=nil
      Yodlicious::Config.cobranded_username=nil
      Yodlicious::Config.cobranded_password=nil
      Yodlicious::Config.proxy_url=nil
    }
    subject { Yodlicious::YodleeApi.new }

    it 'should return nil for cobranded_auth' do
      expect(subject.cobranded_auth).to be_nil
    end

    it 'should return nil for user_auth' do
      expect(subject.user_auth).to be_nil
    end

    it 'should return nil for session_token' do
      expect(subject.session_token).to be_nil
    end

    it 'should return nil for user_session_token' do
      expect(subject.user_session_token).to be_nil
    end

    it 'should return a translator' do
      expect(subject.translator).not_to be_nil
    end
  end

  context 'Given a Yodlicious::Config with nil configuration' do
    context 'When a new YodleeApi instance is created with no configuration' do
      before {
        Yodlicious::Config.base_url=nil
        Yodlicious::Config.cobranded_username=nil
        Yodlicious::Config.cobranded_password=nil
        Yodlicious::Config.proxy_url=nil
      }
      subject { Yodlicious::YodleeApi.new }

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
  end

  context 'Given a Yodlicious::Config with a configuration' do
    context 'When a new YodleeApi instance is created with the global configuration set' do
      before {
        Yodlicious::Config.base_url='base url'
        Yodlicious::Config.cobranded_username='user name'
        Yodlicious::Config.cobranded_password='password'
        Yodlicious::Config.proxy_url='socks5h://somehostname'
      }
      subject { Yodlicious::YodleeApi.new }

      it 'base_url set' do
        expect(subject.base_url).to eq('base url')
      end

      it 'cobranded_username is set' do
        expect(subject.cobranded_username).to eq('user name')
      end

      it 'cobranded_password is set' do
        expect(subject.cobranded_password).to eq('password')
      end

      it 'proxy_url is set' do
        expect(subject.proxy_url).to eq('socks5h://somehostname')
      end

      it 'proxy_opts are created' do
        expect(subject.proxy_opts).to eq({ socks: true, uri: URI.parse('socks5h://somehostname') })
      end

      it 'socks proxy is used' do
        expect(subject.use_socks?).to eq(true)
      end
    end
  end
  
  context 'Given a Yodlicious::Config with nil configuration' do
    context 'When a new YodleeApi instance is created and provided a configuration' do
      before {
        Yodlicious::Config.base_url=nil
        Yodlicious::Config.cobranded_username=nil
        Yodlicious::Config.cobranded_password=nil
        Yodlicious::Config.proxy_url=nil
      }
      let(:config) {
        { 
          base_url: "https://rest.developer.yodlee.com/services/srest/restserver/v1.0",
          cobranded_username: "some_username",
          cobranded_password: "some_password",
          proxy_url: "socks5h://127.0.0.1:1080"
        }
      }

      subject { Yodlicious::YodleeApi.new(config) }

      it 'the provided base url is set' do
        expect(subject.base_url).to eq(config[:base_url])
      end

      it 'the provided cobranded_username is set' do
        expect(subject.cobranded_username).to eq(config[:cobranded_username])
      end

      it 'the provided cobranded_password is set' do
        expect(subject.cobranded_password).to eq(config[:cobranded_password])
      end

      it 'the provided proxy_url is set' do
        expect(subject.proxy_url).to eq(config[:proxy_url])
      end

      it 'the provided proxy_opts are created' do
        proxy_opts = {
          socks: true,
          uri: URI.parse(config[:proxy_url])
        }
        expect(subject.proxy_opts).to eq(proxy_opts)
      end

      it 'the provided socks proxy is used' do
        expect(subject.use_socks?).to eq(true)
      end
    end
  end

  context 'Given a Yodlicious::Config with set config values' do
    context 'When a new YodleeApi instance is created and provided a configuration' do
      before {
        Yodlicious::Config.base_url='base url'
        Yodlicious::Config.cobranded_username='user name'
        Yodlicious::Config.cobranded_password='password'
        Yodlicious::Config.proxy_url='socks5h://somehostname'
      }
      let(:config) { 
         {
           base_url: "https://rest.developer.yodlee.com/services/srest/restserver/v1.0",
           cobranded_username: "some_username",
           cobranded_password: "some_password",
           proxy_url: "socks5h://127.0.0.1:1080"
         }
      }

      subject { Yodlicious::YodleeApi.new(config) }

      it 'the provided base url is set' do
        expect(subject.base_url).to eq(config[:base_url])
      end

      it 'the provided cobranded_username is set' do
        expect(subject.cobranded_username).to eq(config[:cobranded_username])
      end

      it 'the provided cobranded_password is set' do
        expect(subject.cobranded_password).to eq(config[:cobranded_password])
      end

      it 'the provided proxy_url is set' do
        expect(subject.proxy_url).to eq(config[:proxy_url])
      end

      it 'the provided proxy_opts are created' do
        proxy_opts = {
          socks: true,
          uri: URI.parse(config[:proxy_url])
        }
        expect(subject.proxy_opts).to eq(proxy_opts)
      end

      it 'the provided socks proxy is used' do
        expect(subject.use_socks?).to eq(true)
      end
    end
  end

  context 'Given a Yodlicious::Config with nil config values' do
    context 'When a new YodleeApi instance is configured with no proxy_url' do
      before {
        Yodlicious::Config.base_url=nil
        Yodlicious::Config.cobranded_username=nil
        Yodlicious::Config.cobranded_password=nil
        Yodlicious::Config.proxy_url=nil
      }
      let(:config) {
        {
          base_url: "https://rest.developer.yodlee.com/services/srest/restserver/v1.0",
          cobranded_username: "some_username",
          cobranded_password: "some_password"
        }
      }

      subject { Yodlicious::YodleeApi.new(config) }

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
end