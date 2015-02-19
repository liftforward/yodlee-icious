require "yodlicious"

describe 'the yodlee api client integration tests', integration: true do
  let(:config) { 
    { 
      base_url: ENV['YODLEE_BASE_URL'],
      cobranded_username: ENV['YODLEE_COBRANDED_USERNAME'],
      cobranded_password: ENV['YODLEE_COBRANDED_PASSWORD'],
      proxy_url: ENV['YODLICIOUS_PROXY_URL']
    }
  }

  let(:api) { Yodlicious::YodleeApi.new(config) }

  describe 'the yodlee apis cobranded login endpoint' do
    context 'Given valid cobranded credentials and base_url' do
      context 'When /authenticate/coblogin is called the return' do
        subject { api.cobranded_login }

        it { is_expected.to be_kind_of(Hash) }
        it { is_expected.not_to be_empty }

        it 'contains valid json response' do
          expect(subject['cobrandConversationCredentials']).not_to be_nil
          expect(subject['cobrandConversationCredentials']['sessionToken']).not_to be_nil
        end
      end
    end
  end

  describe 'the yodlee apis user login endpoint' do
    context 'Given valid cobranded credentials and base_url' do
      context 'Given a new user who does not exist within the cobranded account' do
        describe 'When /authenticate/coblogin is called the return' do
          subject { 
            api.cobranded_login
            api.user_login 'testuser', 'testpassword'
          }

          it { is_expected.to be_kind_of(Hash) }
          it { is_expected.not_to be_empty }

          it 'returns an error response' do
            expect(subject).to eq({"Error"=>[{"errorDetail"=>"Invalid User Credentials"}]})
          end
        end
      end

      context 'Given a user who does exist within the cobranded account' do
        describe 'When /authenticate/coblogin is called the return' do
          subject { 
            api.cobranded_login
            api.user_login 'testuser', 'testpassword'
          }

          it { is_expected.to be_kind_of(Hash) }
          it { is_expected.not_to be_empty }

          it 'returns an error response' do
            expect(subject).to eq({"Error"=>[{"errorDetail"=>"Invalid User Credentials"}]})
          end
        end
      end
    end
  end

  describe 'the yodlee apis register user endpoint' do
    context 'Given a valid cobranded credentials and base_url' do
      context 'Given a new user who does not exist within the cobranded account' do
        context 'When /jsonsdk/UserRegistration/register3 endpoint is called the response' do
          subject {
            api.cobranded_login
            api.register_user "testuser#{rand(100...200)}", 'testpassword143', 'test@test.com'
          }

          after {
            api.unregister_user
          }

          it 'is expected to offer a valid response' do
            is_expected.to be_kind_of(Hash)
            is_expected.not_to be_empty
            expect(subject['errorOccurred']).to be_nil
            expect(subject['userContext']['conversationCredentials']['sessionToken']).to be_kind_of(String)
            expect(subject['userContext']['conversationCredentials']['sessionToken'].length).to be > 0
            expect(api.user_session_token).not_to be_nil
          end
        end
      end
    end
  end

  describe 'the yodlicious login_or_register_user method' do

    it 'should login an existing user'
    it 'should register a new user'
    it 'should not register an existing user twice'

  end

  describe 'the yodlee apis site info endpoint' do
    context 'Given a valid cobranded credentials and base_url' do
      before { 
        api.cobranded_login
      }

      context 'When a request for site info is performed the result' do
        subject { api.get_site_info 16441 }

        it 'is expected to contain login form details' do
          is_expected.not_to be_nil
          is_expected.to be_kind_of(Hash)
          expect(subject['errorOccurred']).to be_nil
          expect(subject['loginForms']).not_to be_nil
          expect(subject['loginForms']).to be_kind_of(Array)
          expect(subject['loginForms'].length).to be > 0
        end
      end
    end
  end

  #todo reorganize this spec to use given-when-then
  describe 'Yodilicious add_site_account_and_wait method' do
    context 'Given a user who has registered and does not have any accounts' do
      before { 
        api.cobranded_login
        # api.user_login 'testuser', 'testpassword143'
        # api.unregister_user
        # api.logout_user
        api.register_user "testuser#{rand(100..999)}", 'testpassword143', 'test@test.com'
      }

      let(:seconds_between_retry) { 3 }
      let(:retry_count) { 10 }

      after {
        begin
          api.unregister_user
        rescue
        end
      }

      context 'When a invalid username and password for an account is added' do
        before {
          dag_login_form['componentList'][0]['value'] = 'invalid_username'
          dag_login_form['componentList'][1]['value'] = 'invalid_password'
        }
        subject { api.add_site_account_and_wait(16441, dag_login_form, seconds_between_retry, retry_count) }

        it 'is expected to respond with siteRefreshStatus=LOGIN_FAILURE and refreshMode=NORMAL a siteAccountId' do
          expect(subject['siteRefreshInfo']['siteRefreshStatus']['siteRefreshStatus']).to eq('LOGIN_FAILURE')
          expect(subject['siteRefreshInfo']['siteRefreshMode']['refreshMode']).to eq('NORMAL')
          expect(subject['siteAccountId']).not_to be_nil
          # puts JSON.pretty_generate(subject)
        end
      end

      context 'When a valid username and password for an account is added' do
        before {
          dag_login_form['componentList'][0]['value'] = 'yodlicious.site16441.1'
          dag_login_form['componentList'][1]['value'] = 'site16441.1'
        }
        subject { api.add_site_account_and_wait(16441, dag_login_form, seconds_between_retry, retry_count) }

        it 'is expected to respond with siteRefreshStatus=LOGIN_SUCCESS and refreshMode=NORMAL a siteAccountId' do
          # puts JSON.pretty_generate(subject)
          expect(subject['siteRefreshInfo']['siteRefreshStatus']['siteRefreshStatus']).to eq('LOGIN_SUCCESS')
          expect(subject['siteRefreshInfo']['siteRefreshMode']['refreshMode']).to eq('NORMAL')
          expect(subject['siteAccountId']).not_to be_nil
        end
      end

    end
  end

  describe 'the yodlee apis fetching summary data about registered site accounts endpoints' do
    context 'Given a registered user with registered accounts' do
      before { 
        api.cobranded_login
        api.user_login "testuser_with_transactions", 'testpassword143'
        # api.register_user "testuser#{rand(100..999)}", 'testpassword143', 'test@test.com'
        # dag_login_form[:componentList][0][:value] = 'yodlicious.site16441.1'
        # dag_login_form[:componentList][1][:value] = 'site16441.1'
        # api.add_site_account_and_wait(16441, dag_login_form)
      }

      # after {
      #   begin
      #     api.unregister_user
      #   rescue
      #   end
      # }

      context 'when getAllSiteAccounts is called the return' do 
        subject { api.get_all_site_accounts }

        it 'is expected to return an array containing 1 siteAccount' do
          # puts JSON.pretty_generate(subject)
          is_expected.not_to be_nil
          is_expected.to be_kind_of(Array)
          expect(subject.length).to be > 0
          expect(subject[0]['siteAccountId']).not_to be_nil
          expect(subject[0]['siteRefreshInfo']['siteRefreshStatus']['siteRefreshStatus']).to eq('REFRESH_COMPLETED')

        end
      end

      context 'when getItemSummariesForSite is called the return' do
        subject {
          site_accounts = api.get_all_site_accounts
          # puts site_accounts[0]['siteAccountId']
          # puts JSON.pretty_generate(site_accounts)
          api.get_item_summaries_for_site(site_accounts[0]['siteAccountId'])
        }

        it 'is expected to return an array site summaries' do
          # puts JSON.pretty_generate(subject)

          is_expected.not_to be_nil
          is_expected.to be_kind_of(Array)
          expect(subject[0]['itemId']).not_to be_nil
        end
      end

      context 'when getItemSummaries is called the return' do
        subject { api.get_item_summaries }

        it 'is expected to return an array of site summaries' do
          # puts JSON.pretty_generate(subject)

          is_expected.not_to be_nil
          is_expected.to be_kind_of(Array)
          expect(subject.length).to be > 0
          expect(subject[0]['itemId']).not_to be_nil
        end
      end
    end
  end

  describe 'the yodlee apis fetching user/s transactions' do
    context 'Given a registered user with registered accounts' do
      before { 
        api.cobranded_login
        api.user_login "testuser_with_transactions", 'testpassword143'
        # dag_login_form[:componentList][0][:value] = 'yodlicious.site16441.1'
        # dag_login_form[:componentList][1][:value] = 'site16441.1'
        # api.add_site_account_and_wait(16441, dag_login_form)
      }

      context 'When a transaction search for all transactions is performed the result' do
        subject { api.execute_user_search_request }

        it 'is expected to return a valid search result' do
          # puts JSON.pretty_generate(subject)

          is_expected.not_to be_nil
          is_expected.to be_kind_of(Hash)
          expect(subject['errorOccurred']).to be_nil
          expect(subject['searchIdentifier']).not_to be_nil
          expect(subject['searchResult']['transactions']).to be_kind_of(Array)
          expect(subject['searchResult']['transactions'].length).to be > 0
        end
      end
    end
  end


  # puts JSON.pretty_generate(subject)

  # context 'downloading transaction history' 

  # context 'fetching a list of content services' do
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


          # { 
          #   "siteAccountId"=>10921402, 
          #   "isCustom"=>false, 
          #   "credentialsChangedTime"=>1424120024, 
          #   "siteRefreshInfo"=>{
          #     "siteRefreshStatus"=>{
          #       "siteRefreshStatusId"=>1, 
          #       "siteRefreshStatus"=>"REFRESH_TRIGGERED"
          #       }, 
          #     "siteRefreshMode"=>{
          #       "refreshModeId"=>2, 
          #       "refreshMode"=>"NORMAL"
          #     }, 
          #     "updateInitTime"=>1424120024, 
          #     "nextUpdate"=>1424120924, 
          #     "code"=>801, 
          #     "suggestedFlow"=>{
          #       "suggestedFlowId"=>2, 
          #       "suggestedFlow"=>"REFRESH"
          #     }, 
          #     "noOfRetry"=>0
          #   }, 
          #   "siteInfo"=>{
          #     "popularity"=>0, 
          #     "siteId"=>643, 
          #     "orgId"=>520, 
          #     "defaultDisplayName"=>"Chase", 
          #     "defaultOrgDisplayName"=>"Chase Manhattan Bank", 
          #     "enabledContainers"=>[
          #       {"containerName"=>"bank", "assetType"=>1}, 
          #       {"containerName"=>"bill_payment", "assetType"=>0}, 
          #       {"containerName"=>"credits", "assetType"=>2}, 
          #       {"containerName"=>"stocks", "assetType"=>1}, 
          #       {"containerName"=>"loans", "assetType"=>2}, 
          #       {"containerName"=>"mortgage", "assetType"=>2}, 
          #       {"containerName"=>"miles", "assetType"=>0}
          #     ], 
          #     "baseUrl"=>"http://www.chase.com/", 
          #     "loginForms"=>[], 
          #     "isHeld"=>false, 
          #     "isCustom"=>false, 
          #     "siteSearchVisibility"=>true, 
          #     "isAlreadyAddedByUser"=>true, 
          #     "isOauthEnabled"=>false
          #   }, 
          #   "created"=>"2015-02-16T12:53:44-0800", 
          #   "retryCount"=>0
          # }


      #   {
      #     conjunctionOp: {  
      #       conjuctionOp: 1
      #     },
      #     componentList: [  
      #       {  
      #         valueIdentifier: 'LOGIN',
      #         valueMask: 'LOGIN_FIELD',
      #         fieldType: {  
      #           typeName: 'IF_LOGIN'
      #         },
      #         size: 20,
      #         maxlength: 32,
      #         name: 'LOGIN',
      #         displayName: 'User ID',
      #         isEditable: true,
      #         isOptional: false,
      #         isEscaped: false,
      #         helpText: 4710,
      #         isOptionalMFA: false,
      #         isMFA: false,
      #         value: 'yodlicious.site16441.1'
      #       },
      #       {  
      #         valueIdentifier: 'PASSWORD',
      #         valueMask: 'LOGIN_FIELD',
      #         fieldType: {  
      #           typeName: 'IF_PASSWORD'
      #         },
      #         size: 20,
      #         maxlength: 40,
      #         name: 'PASSWORD',
      #         displayName: 'Password',
      #         isEditable: true,
      #         isOptional: false,
      #         isEscaped: false,
      #         helpText: 11976,
      #         isOptionalMFA: false,
      #         isMFA: false,
      #         value: 'site16441.1'
      #       }
      #     ],
      #     defaultHelpText: 324
      #   }
      # }

  let(:dag_login_form) {
    JSON.parse('{
      "conjunctionOp": {
        "conjuctionOp": 1
      },
      "componentList": [
        {
          "valueIdentifier": "LOGIN1",
          "valueMask": "LOGIN_FIELD",
          "fieldType": {
            "typeName": "IF_LOGIN"
          },
          "size": 20,
          "maxlength": 40,
          "name": "LOGIN1",
          "displayName": "Catalog",
          "isEditable": true,
          "isOptional": false,
          "isEscaped": false,
          "helpText": "150862",
          "isOptionalMFA": false,
          "isMFA": false
        },
        {
          "valueIdentifier": "PASSWORD1",
          "valueMask": "LOGIN_FIELD",
          "fieldType": {
            "typeName": "IF_PASSWORD"
          },
          "size": 20,
          "maxlength": 40,
          "name": "PASSWORD1",
          "displayName": "Password",
          "isEditable": true,
          "isOptional": false,
          "isEscaped": false,
          "helpText": "150863",
          "isOptionalMFA": false,
          "isMFA": false
        }
      ],
      "defaultHelpText": "16103"
    }')
  }
end
