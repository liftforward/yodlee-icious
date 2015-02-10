require "yodlicious"

describe 'yodlee api client', focus: true do
  let(:config) { { 'base_url' => "https://rest.developer.yodlee.com/services/srest/restserver/v1.0",
                   'username' => "sbCobandrewnichols",
                   'password' => "d02aeac7-0ead-432e-a187-f8ff8a24e0cd" } }
  let(:api) { Yodlicious::YodleeApi.new(config) }

  context 'a new YodleeApi instance' do
    subject { api }
    it 'allows for the provided config' do
      expect(subject).not_to be_nil
    end
  end

  context 'creating a new session' do
    before { api.cobranded_login }
    subject { api }

    it 'captures a new cobranded auth token json' do
      expect(subject.cobranded_auth).not_to be_nil
    end

    it 'captures a session token' do
      expect(subject.session_token).not_to be_nil
    end

  end

  context 'failing to create a new session' do
    it 'handles non 200 response gracefully'
    it 'handles 200 response with error message'
  end

  context 'registering a new user'

  context 'logging in a registered user' do
    before { 
      api.cobranded_login
      api.user_login 'sbMemandrewnichols1', 'sbMemandrewnichols1#123'
    }
    subject { api }

    it 'captures a new user auth token json' do
      expect(subject.user_auth).not_to be_nil
    end

    it 'captures a user session token' do
      expect(subject.user_session_token).not_to be_nil
    end
  end

  context 'searching for a site' do
    before { 
      api.cobranded_login
      api.user_login 'sbMemandrewnichols1', 'sbMemandrewnichols1#123'
    }
    subject { api.site_search 'chase' }

    it 'returns an array of sites' do
      expect(subject).to be_kind_of(Array)
      expect(subject).not_to be_empty
      expect(subject[0]['baseUrl']).not_to be_empty
      expect(subject[0]['loginForms']).not_to be_empty
    end
  end

  context 'failing when running a search for a site' do
    it 'return error json'
  end

  context 'adding a chase bank account site' do
    before { 
      api.cobranded_login
      api.user_login 'sbMemandrewnichols1', 'sbMemandrewnichols1#123'
    }

    let (:login_form) {
      {  
        conjunctionOp: {  
          conjuctionOp: 1
        },
        componentList: [  
          {  
            valueIdentifier: 'LOGIN',
            valueMask: 'LOGIN_FIELD',
            fieldType: {  
              typeName: 'IF_LOGIN'
            },
            size: 20,
            maxlength: 32,
            name: 'LOGIN',
            displayName: 'User ID',
            isEditable: true,
            isOptional: false,
            isEscaped: false,
            helpText: 4710,
            isOptionalMFA: false,
            isMFA: false,
            value: 'kanyewest'
          },
          {  
            valueIdentifier: 'PASSWORD',
            valueMask: 'LOGIN_FIELD',
            fieldType: {  
              typeName: 'IF_PASSWORD'
            },
            size: 20,
            maxlength: 40,
            name: 'PASSWORD',
            displayName: 'Password',
            isEditable: true,
            isOptional: false,
            isEscaped: false,
            helpText: 11976,
            isOptionalMFA: false,
            isMFA: false,
            value: 'iLoveTheGrammies'
          }
        ],
        defaultHelpText: 324
      }
    }

    subject { api.add_site_account(643, login_form) }

    it 'returns a SiteAccountInfo object' do
      puts (subject)
      expect(subject['siteAccountId']).not_to be_nil
    end
  end

  context 'downloading transaction history'

  # context 'fetching a list of content services', focus: true do
  #   let (:api) { Yodlee::Base.new }
  #   before { api.login }

  #   subject { api.all_content_services }

  #   it 'returns a set of content services' do
  #     expect(subject).not_to be_empty
  #   end
  # end
end
