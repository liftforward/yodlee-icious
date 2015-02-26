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

  let(:registered_user) {
    {
      email: 'testuser_with_transactions@liftforward.com',
      password: 'testpassword143'
    }
  }

  describe 'the yodlee apis cobranded login endpoint' do
    context 'Given valid cobranded credentials and base_url' do
      context 'When /authenticate/coblogin is called the return' do
        subject { api.cobranded_login }

        it { is_expected.to be_kind_of(Yodlicious::Response) }
        it { is_expected.to be_success }

        it 'contains valid json response' do
          expect(subject.body['cobrandConversationCredentials']).not_to be_nil
          expect(subject.body['cobrandConversationCredentials']['sessionToken']).not_to be_nil
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

          it { is_expected.to be_kind_of(Yodlicious::Response) }
          it { is_expected.to be_fail }

          it 'returns an error response' do
            expect(subject.body).to eq({"Error"=>[{"errorDetail"=>"Invalid User Credentials"}]})
          end
        end
      end

      context 'Given a user who does exist within the cobranded account' do
        describe 'When /authenticate/coblogin is called the return' do
          subject { 
            api.cobranded_login
            api.user_login 'testuser', 'testpassword'
          }

          it { is_expected.to be_kind_of(Yodlicious::Response) }
          it { is_expected.to be_fail }

          it 'returns an error response' do
            expect(subject.body).to eq({"Error"=>[{"errorDetail"=>"Invalid User Credentials"}]})
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
            is_expected.to be_kind_of(Yodlicious::Response)
            is_expected.to be_success
            expect(subject.body['errorOccurred']).to be_nil
            expect(subject.body['userContext']['conversationCredentials']['sessionToken']).to be_kind_of(String)
            expect(subject.body['userContext']['conversationCredentials']['sessionToken'].length).to be > 0
            expect(api.user_session_token).not_to be_nil
          end
        end
      end
    end
  end

  describe '#unregister_user' do
    context 'Given a valid cobranded credentials and base_url' do
      context 'Given a user who it logged into the api' do
        context 'When #unregister_user is called the response' do
          subject {
            api.cobranded_login
            api.login_or_register_user "testuser#{rand(100...200)}", 'testpassword143', 'test@test.com'
            expect(api.user_session_token).not_to be_nil
            api.unregister_user
          }


          it 'is expected to offer a valid response' do
            is_expected.to be_kind_of(Yodlicious::Response)
            is_expected.to be_success
            expect(api.user_session_token).to be_nil
          end

          after { api.unregister_user }

        end
      end
    end
  end

  describe 'the yodlicious login_or_register_user method' do
    before { api.cobranded_login }

    context 'Given a new user with valid credentials' do
      after { api.unregister_user }
      let (:email) { "testuser#{rand(100...200)}@test.com" }
      let (:password) { "password#{rand(100...200)}" }

      context 'When login_or_register_user is called' do
        subject { api.login_or_register_user email, password, email }

        it 'should register the new user and set the user_session_token'  do 
          expect(subject).to be_success
          expect(subject).to be_kind_of(Yodlicious::Response)
          expect(api.user_session_token).not_to be_nil
        end
      end
    end

    context 'Given an existing user with valid credentials' do
      before { api.register_user registered_user[:email], registered_user[:password], registered_user[:email] }

      context 'When login_or_register_user is called' do
        subject { api.login_or_register_user registered_user[:email], registered_user[:password], registered_user[:email] }

        it 'should login the user and not register them' do
          expect(subject).to be_success
          expect(subject).to be_kind_of(Yodlicious::Response)
          expect(api.user_session_token).not_to be_nil
        end
      end
    end
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
          is_expected.to be_kind_of(Yodlicious::Response)
          expect(subject.body['errorOccurred']).to be_nil
          expect(subject.body['loginForms']).not_to be_nil
          expect(subject.body['loginForms']).to be_kind_of(Array)
          expect(subject.body['loginForms'].length).to be > 0
        end
      end
    end
  end

  #todo reorganize this spec to use given-when-then
  describe '#add_site_account_and_wait' do
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
          # puts JSON.pretty_generate(subject.body)
          is_expected.to be_success
          expect(subject.body['siteRefreshInfo']['siteRefreshStatus']['siteRefreshStatus']).to eq('LOGIN_FAILURE')
          expect(subject.body['siteRefreshInfo']['siteRefreshMode']['refreshMode']).to eq('NORMAL')
          expect(subject.body['siteAccountId']).not_to be_nil
        end
      end

      context 'When a valid username and password for an account is added' do
        before {
          dag_login_form['componentList'][0]['value'] = 'yodlicious.site16441.1'
          dag_login_form['componentList'][1]['value'] = 'site16441.1'
        }
        subject { api.add_site_account_and_wait(16441, dag_login_form, seconds_between_retry, retry_count) }

        it 'is expected to respond with siteRefreshStatus=LOGIN_SUCCESS and refreshMode=NORMAL a siteAccountId' do
          is_expected.to be_success
          expect(subject.body['siteRefreshInfo']['siteRefreshStatus']['siteRefreshStatus']).to eq('LOGIN_SUCCESS')
          expect(subject.body['siteRefreshInfo']['siteRefreshMode']['refreshMode']).to eq('NORMAL')
          expect(subject.body['siteAccountId']).not_to be_nil
        end
      end

    end
  end

  describe '#get_mfa_response_for_site' do
    context 'Given a valid cobranded credentials and base_url' do
      context 'Given a user who it logged into the api' do
        context 'When #get_mfa_response_for_site is called the response' do
          subject {
            api.cobranded_login
            response = api.login_or_register_user "testuser#{rand(100...200)}", 'testpassword143', 'test@test.com'

            dag_fmfa_login_form['componentList'][0]['value'] = 'yodlicious1.site16445.1'
            dag_fmfa_login_form['componentList'][1]['value'] = 'site16445.1'

            response = api.add_site_account_and_wait(16445, dag_fmfa_login_form)
            expect(response).to be_success
            # puts "refreshMode= #{response.body['siteRefreshInfo']['siteRefreshMode']['refreshMode']}"
            expect(response.body['siteRefreshInfo']['siteRefreshMode']['refreshMode']).to eq('MFA')
            api.get_mfa_response_for_site response.body['siteAccountId']
          }

          it 'is expected be a valid response' do
            is_expected.to be_kind_of(Yodlicious::Response)
            is_expected.to be_success
            expect(subject.body['isMessageAvailable']).not_to be_nil
          end

          after { api.unregister_user }
        end
      end
    end
  end

  describe '#get_mfa_response_for_site_and_wait' do
    context 'Given a valid cobranded credentials and base_url' do
      context 'Given a user who it logged into the api' do
        context 'When #get_mfa_response_for_site_and_wait is called the response' do
          subject {
            api.cobranded_login
            response = api.login_or_register_user "testuser#{rand(100...200)}", 'testpassword143', 'test@test.com'

            dag_fmfa_login_form['componentList'][0]['value'] = 'yodlicious1.site16445.1'
            dag_fmfa_login_form['componentList'][1]['value'] = 'site16445.1'

            response = api.add_site_account_and_wait(16445, dag_fmfa_login_form)
            expect(response).to be_success

            expect(response.body['siteRefreshInfo']['siteRefreshMode']['refreshMode']).to eq('MFA')
            api.get_mfa_response_for_site_and_wait response.body['siteAccountId'], 1
          }

          it 'is expected be a valid response' do
            is_expected.to be_kind_of(Yodlicious::Response)
            is_expected.to be_success
            expect(subject.body['isMessageAvailable']).to be_truthy
            expect(subject.body['fieldInfo']).not_to be_nil
          end

          after { api.unregister_user }
        end
      end
    end
  end

  describe '#put_mfa_request_for_site' do
    context 'Given a valid cobranded credentials and base_url' do
      context 'Given a user who is logged into the api' do
        context 'Given a user attempting to add a site with Token Based MFA' do
          context 'When #put_mfa_request_for_site is called the response' do
            subject {
              api.cobranded_login
              response = api.login_or_register_user "testuser#{rand(100...200)}", 'testpassword143', 'test@test.com'

              dag_fmfa_login_form['componentList'][0]['value'] = 'yodlicious1.site16445.1'
              dag_fmfa_login_form['componentList'][1]['value'] = 'site16445.1'

              response = api.add_site_account_and_wait(16445, dag_fmfa_login_form)
              expect(response).to be_success

              expect(response.body['siteRefreshInfo']['siteRefreshMode']['refreshMode']).to eq('MFA')
              site_account_id = response.body['siteAccountId']
              response = api.get_mfa_response_for_site_and_wait site_account_id, 2
              #{ 
              #  "isMessageAvailable":true,
              #  "fieldInfo":{
              #    "responseFieldType":"text",
              #    "minimumLength":-1,
              #    "maximumLength":6,
              #    "displayString":"Security Key"
              #  },
              #  "timeOutTime":116420,
              #  "itemId":0,
              #  "memSiteAccId":10992295,
              #  "retry":false
              #}
              expect(response.body['isMessageAvailable']).to be_truthy

              field_info = response.body['fieldInfo']
              field_info['value'] = "monkeys"
              api.put_mfa_request_for_site site_account_id, :MFATokenResponse, field_info
            }

            it 'is expected be a valid response' do
              is_expected.to be_kind_of(Yodlicious::Response)
              is_expected.to be_success
              expect(subject.body['primitiveObj']).to be_truthy
            end

            after { api.unregister_user }
          end
        end
      end
    end
  end

  describe 'the yodlee apis fetching summary data about registered site accounts endpoints' do
    context 'Given a registered user with registered accounts' do
      before { 
        api.cobranded_login
        api.user_login "testuser_with_transactions@liftforward.com", 'testpassword143'
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
          is_expected.to be_success
          expect(subject.body).to be_kind_of(Array)
          expect(subject.body.length).to be > 0
          expect(subject.body[0]['siteAccountId']).not_to be_nil
          expect(subject.body[0]['siteRefreshInfo']['siteRefreshStatus']['siteRefreshStatus']).to eq('REFRESH_COMPLETED')

        end
      end

      context 'when getItemSummariesForSite is called the return' do
        subject {
          site_accounts = api.get_all_site_accounts
          # puts site_accounts[0]['siteAccountId']
          # puts JSON.pretty_generate(site_accounts)
          api.get_item_summaries_for_site(site_accounts.body[0]['siteAccountId'])
        }

        it 'is expected to return an array site summaries' do
          # puts JSON.pretty_generate(subject)

          is_expected.to be_kind_of(Yodlicious::Response)
          is_expected.to be_success
          expect(subject.body[0]['itemId']).not_to be_nil
        end
      end

      context 'when getItemSummaries is called the return' do
        subject { api.get_item_summaries }

        it 'is expected to return an array of site summaries' do
          # puts JSON.pretty_generate(subject)

          is_expected.to be_kind_of(Yodlicious::Response)
          is_expected.to be_success
          expect(subject.body.length).to be > 0
          expect(subject.body[0]['itemId']).not_to be_nil
        end
      end
    end
  end

  describe 'the yodlee apis fetching user/s transactions' do
    context 'Given a registered user with registered accounts' do
      before { 
        api.cobranded_login
        api.login_or_register_user 'testuser_with_transactions@liftforward.com', 'testpassword143', 'testuser_with_transactions@liftforward.com'
        dag_login_form['componentList'][0]['value'] = 'yodlicious.site16441.1'
        dag_login_form['componentList'][1]['value'] = 'site16441.1'
        api.add_site_account_and_wait(16441, dag_login_form)
      }

      context 'When a transaction search for all transactions is performed the result' do
        subject { api.execute_user_search_request }

        it 'is expected to return a valid search result' do
          # puts JSON.pretty_generate(subject.body)

          is_expected.not_to be_nil
          is_expected.to be_kind_of(Yodlicious::Response)
          is_expected.to be_success
          expect(subject.body['errorOccurred']).to be_nil
          expect(subject.body['searchIdentifier']).not_to be_nil
          expect(subject.body['searchResult']['transactions']).to be_kind_of(Array)
          expect(subject.body['searchResult']['transactions'].length).to be > 0
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

  let(:dag_fmfa_login_form) {
    {
      "conjunctionOp"=> {
        "conjuctionOp"=>1
      },
      "componentList"=> [ 
        {
          "valueIdentifier"=>"LOGIN1",
          "valueMask"=>"LOGIN_FIELD",
          "fieldType"=>{"typeName"=>"IF_LOGIN"},
          "size"=>20,
          "maxlength"=>40,
          "name"=>"LOGIN1",
          "displayName"=>"Catalog",
          "isEditable"=>true,
          "isOptional"=>false,
          "isEscaped"=>false,
          "helpText"=>"150876",
          "isOptionalMFA"=>false,
          "isMFA"=>false
        },
        {
          "valueIdentifier"=>"PASSWORD1",
          "valueMask"=>"LOGIN_FIELD",
          "fieldType"=>{"typeName"=>"IF_PASSWORD"},
          "size"=>20,
          "maxlength"=>40,
          "name"=>"PASSWORD1",
          "displayName"=>"Password",
          "isEditable"=>true,
          "isOptional"=>false,
          "isEscaped"=>false,
          "helpText"=>"150877",
          "isOptionalMFA"=>false,
          "isMFA"=>false
        }
      ],
      "defaultHelpText"=>"16126"
    }
  }

  let(:dag_mfa_login_form) {
    JSON.parse('{
      "conjunctionOp" : 
      { 
        "conjuctionOp" : 1
      },
      "componentList" : [
        {
          "valueIdentifier" : "LOGIN",
           "valueMask" : "LOGIN_FIELD",
           "fieldType" : {"typeName" : "IF_LOGIN"},
           "size" : 20,
           "maxlength" : 40,
           "name" : "LOGIN",
           "displayName" : "Catalog",
           "isEditable" : true,
           "isOptional" : false,
           "isEscaped" : false,
           "helpText" : "150970",
           "isOptionalMFA" : false,
           "isMFA" : false
        },
        {
          "valueIdentifier" : "PASSWORD",
          "valueMask" : "LOGIN_FIELD",
          "fieldType" : {"typeName" : "IF_PASSWORD"},
          "size" : 20,
          "maxlength" : 40,
          "name" : "PASSWORD",
          "displayName" : "Password",
          "isEditable" : true,
          "isOptional" : false,
          "isEscaped" : false,
          "helpText" : "150971",
          "isOptionalMFA" : false,
          "isMFA" : false
        }
      ],
      "defaultHelpText" : "16167"
    }')
  }
end



  # {"popularity"=>0,
  #  "siteId"=>16477,
  #  "orgId"=>1148,
  #  "defaultDisplayName"=>"DagSIteMFAAndNonMFA (US)",
  #  "defaultOrgDisplayName"=>"Demo Bank",
  #  "contentServiceInfos"=>
  #   [{"contentServiceId"=>20631, "siteId"=>16477, "containerInfo"=>{"containerName"=>"bank", "assetType"=>1}},
  #    {"contentServiceId"=>20632, "siteId"=>16477, "containerInfo"=>{"containerName"=>"miles", "assetType"=>0}}],
  #  "enabledContainers"=>[{"containerName"=>"bank", "assetType"=>1}, {"containerName"=>"miles", "assetType"=>0}],
  #  "baseUrl"=>"http://192.168.210.152:9090/dag/dhaction.do",
  #  "loginForms"=>
  #   [{"conjunctionOp"=>{"conjuctionOp"=>1},
  #     "componentList"=>
  #      [{"valueIdentifier"=>"LOGIN",
  #        "valueMask"=>"LOGIN_FIELD",
  #        "fieldType"=>{"typeName"=>"IF_LOGIN"},
  #        "size"=>20,
  #        "maxlength"=>40,
  #        "name"=>"LOGIN",
  #        "displayName"=>"Catalog",
  #        "isEditable"=>true,
  #        "isOptional"=>false,
  #        "isEscaped"=>false,
  #        "helpText"=>"150970",
  #        "isOptionalMFA"=>false,
  #        "isMFA"=>false},
  #       {"valueIdentifier"=>"PASSWORD",
  #        "valueMask"=>"LOGIN_FIELD",
  #        "fieldType"=>{"typeName"=>"IF_PASSWORD"},
  #        "size"=>20,
  #        "maxlength"=>40,
  #        "name"=>"PASSWORD",
  #        "displayName"=>"Password",
  #        "isEditable"=>true,
  #        "isOptional"=>false,
  #        "isEscaped"=>false,
  #        "helpText"=>"150971",
  #        "isOptionalMFA"=>false,
  #        "isMFA"=>false}],
  #     "defaultHelpText"=>"16167"}],
  #  "isHeld"=>false,
  #  "isCustom"=>false,
  #  "mfaType"=>{"typeId"=>4, "typeName"=>"SECURITY_QUESTION"},
  #  "mfaCoverage"=>"FMPA",
  #  "siteSearchVisibility"=>true,
  #  "isAlreadyAddedByUser"=>false,
  #  "isOauthEnabled"=>false}
