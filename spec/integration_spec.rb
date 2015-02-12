require "yodlicious"

describe 'the yodlee api client' do
  let(:config) { { 'base_url' => "https://rest.developer.yodlee.com/services/srest/restserver/v1.0",
                   'username' => "sbCobandrewnichols",
                   'password' => "d02aeac7-0ead-432e-a187-f8ff8a24e0cd" } }
  let(:api) { Yodlicious::YodleeApi.new(config) }

  context 'new user adds bank account site' do
    before { 
      api.cobranded_login
      api.user_login 'sbMemandrewnichols3', 'sbMemandrewnichols3#123'
    }

    it 'captures a new cobranded auth token json' do
      expect(api.cobranded_auth).not_to be_nil
    end

    it 'captures a session token' do
      expect(api.session_token).not_to be_nil
    end

    it 'captures a new user auth token json' do
      expect(api.user_auth).not_to be_nil
    end

    it 'captures a user session token' do
      expect(api.user_session_token).not_to be_nil
    end

    it 'returns an array of sites when search is performed' do
      sites = api.site_search 'chase'
      expect(sites).to be_kind_of(Array)
      expect(sites).not_to be_empty
      expect(sites[0]['baseUrl']).not_to be_empty
      expect(sites[0]['loginForms']).not_to be_empty
    end

    it 'returns a SiteAccountInfo object' do
      chase_login_form = {
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

      site_account_info = api.add_site_account(643, chase_login_form)
      site_account_id = site_account_info['siteAccountId']

      expect(site_account_id).not_to be_nil
    end
  end

  describe 'the yodlee apis fetching data about registered accounts endpoints' do
    context 'Given a registered user with registered accounts' do
      before { 
        api.cobranded_login
        api.user_login 'sbMemandrewnichols2', 'sbMemandrewnichols2#123'
      }

      context 'when getAllSiteAccounts is called the return' do 
        subject { api.get_all_site_accounts }

        it { is_expected.to be_kind_of(Array) }
        it { is_expected.not_to be_nil }
        it 'is expected to return more than 0 sites' do
          expect(subject.length).to be > 0
        end
        it 'is expected to return a siteAccountId' do
          expect(subject[0]['siteAccountId']).not_to be_nil
        end
      end

      context 'when getItemSummariesForSite is called the return' do
        subject {
          site_account_id = api.get_all_site_accounts[0]['siteAccountId']
          api.get_item_summaries_for_site(site_account_id)
        }

        it { is_expected.not_to be_nil }
        it { is_expected.to be_kind_of(Array) }
        it 'is expected to return more than 0 sites' do
          expect(subject.length).to be > 0
        end
        it 'is expected to return an itemId' do
          expect(subject[0]['itemId']).not_to be_nil
        end
      end

      # it 'user can select one or more accounts'
      # it 'system can fetch transaction history'
    end
  end

  describe 'the yodlee apis fetching user/s transactions' do
    context 'Given a registered user with registered accounts' do
      before { 
        api.cobranded_login
        api.user_login 'sbMemandrewnichols2', 'sbMemandrewnichols2#123'
      }

      context 'When a transaction search for all transactions is performed the result' do
        subject { api.execute_user_search_request }

        it { is_expected.to be_kind_of(Hash) }
        it 'is expected to not contain an error' do
          expect(subject['errorOccurred']).to be_nil
        end
        it { is_expected.not_to be_nil }

        it 'is expected to contain a searchIdentifier' do
          expect(subject['searchIdentifier']).not_to be_nil
        end

        it 'is expected to contain an array of transactions larger then 0' do
          expect(subject['searchResult']['transactions']).to be_kind_of(Array)
          expect(subject['searchResult']['transactions'].length).to be > 0
        end
      end
    end
  end
          # puts JSON.pretty_generate(subject)


  # context 'downloading transaction history' 

  # context 'fetching a list of content services', focus: true do
  #   let (:api) { Yodlee::Base.new }
  #   before { api.login }

  #   subject { api.all_content_services }

  #   it 'returns a set of content services' do
  #     expect(subject).not_to be_empty
  #   end
  # end


  # context 'failing to create a new session' do
  #   it 'handles non 200 response gracefully'
  #   it 'handles 200 response with error message'
  # end

  # context 'failing when running a search for a site' do
  #   it 'return error json'
  # end

end
