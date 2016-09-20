require "yodleeicious"

describe 'the yodlee api client integration tests', integration: true do
  let(:config) {
    {
      base_url: ENV['YODLEE_BASE_URL'],
      cobranded_username: ENV['YODLEE_COBRANDED_USERNAME'],
      cobranded_password: ENV['YODLEE_COBRANDED_PASSWORD'],
      proxy_url: ENV['YODLEEICIOUS_PROXY_URL']
    }
  }

  let(:api) { Yodleeicious::YodleeApi.new(config) }

  let(:registered_user) {
    {
      email: 'testuser_with_transactions@liftforward.com',
      password: 'testpassword143'
    }
  }

  shared_examples "request_response_examples" do
    it 'sets the response data' do
      expect(subject.response).not_to be_nil
    end

    it 'sets the request_url' do
      expect(subject.request_url).not_to be_nil
    end

    it 'sets payload' do
      expect(subject.payload).not_to be_nil
    end
  end


  describe 'the yodlee apis cobranded login endpoint' do
    context 'Given valid cobranded credentials and base_url' do
      context 'When /authenticate/coblogin is called the return' do
        subject { api.cobranded_login }

        it { is_expected.to be_kind_of(Yodleeicious::Response) }
        it { is_expected.to be_success }

        include_examples 'request_response_examples'

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

          it { is_expected.to be_kind_of(Yodleeicious::Response) }
          it { is_expected.to be_fail }

          include_examples 'request_response_examples'

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

          it { is_expected.to be_kind_of(Yodleeicious::Response) }
          it { is_expected.to be_fail }

          include_examples 'request_response_examples'

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

          include_examples 'request_response_examples'

          it 'is expected to offer a valid response' do
            is_expected.to be_kind_of(Yodleeicious::Response)
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

          include_examples 'request_response_examples'

          it 'is expected to offer a valid response' do
            is_expected.to be_kind_of(Yodleeicious::Response)
            is_expected.to be_success
            expect(api.user_session_token).to be_nil
          end

          after { api.unregister_user }

        end
      end
    end
  end

  describe 'the yodleeicious login_or_register_user method' do
    before { api.cobranded_login }

    context 'Given a new user with valid credentials' do
      after { api.unregister_user }
      let (:email) { "testuser#{rand(100...200)}@test.com" }
      let (:password) { "password#{rand(100...200)}" }

      context 'When login_or_register_user is called' do
        subject { api.login_or_register_user email, password, email }

        include_examples 'request_response_examples'

        it 'should register the new user and set the user_session_token'  do
          expect(subject).to be_success
          expect(subject).to be_kind_of(Yodleeicious::Response)
          expect(api.user_session_token).not_to be_nil
        end
      end
    end

    context 'Given an existing user with valid credentials' do
      before { api.register_user registered_user[:email], registered_user[:password], registered_user[:email] }

      context 'When login_or_register_user is called' do
        subject { api.login_or_register_user registered_user[:email], registered_user[:password], registered_user[:email] }

        include_examples 'request_response_examples'

        it 'should login the user and not register them' do
          expect(subject).to be_success
          expect(subject).to be_kind_of(Yodleeicious::Response)
          expect(api.user_session_token).not_to be_nil
        end
      end
    end
  end

  describe '#get_site_info' do
    context 'Given a valid cobranded credentials and base_url' do
      before {
        api.cobranded_login
      }

      context 'When a request for site info is performed the result' do
        subject { api.get_site_info 16441 }

        include_examples 'request_response_examples'

        it 'is expected to contain login form details' do
          is_expected.not_to be_nil
          is_expected.to be_kind_of(Yodleeicious::Response)
          expect(subject.body['errorOccurred']).to be_nil
          expect(subject.body['loginForms']).not_to be_nil
          expect(subject.body['loginForms']).to be_kind_of(Array)
          expect(subject.body['loginForms'].length).to be > 0
        end
      end
    end
  end


  describe '#get_content_service_info_by_routing_number' do
    context 'Given a valid cobranded credentials and base_url' do
      before { api.cobranded_login }

      context 'When #get_content_service_info_by_routing_number is called with a valid routing number the result' do
        subject { api.get_content_service_info_by_routing_number 999988181 }

        include_examples 'request_response_examples'

        it 'is expected to contain valid content services info' do
          is_expected.not_to be_nil
          is_expected.to be_kind_of(Yodleeicious::Response)
          is_expected.to be_success
          expect(subject.body['errorOccurred']).to be_nil
          expect(subject.body['siteId']).to eq(16441)
          expect(subject.body['contentServiceDisplayName']).to eq('Dag Site (US) - Bank')
        end
      end

      context 'When #get_content_service_info_by_routing_number is called with an invalid routing number' do
        subject { api.get_content_service_info_by_routing_number -23423 }

        include_examples 'request_response_examples'

        it 'is expected to contain valid error details' do
          is_expected.not_to be_nil
          is_expected.to be_kind_of(Yodleeicious::Response)
          is_expected.to be_fail
          expect(subject.body['errorOccurred']).to be_truthy
          expect(subject.body['exceptionType']).to eq('com.yodlee.core.routingnumberservice.InvalidRoutingNumberException')
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
            expect(response).to be_success

            response = api.get_site_login_form(16445)
            expect(response).to be_success

            login_form = response.body
            login_form['componentList'][0]['fieldValue'] = 'yodlicious1.site16445.1'
            login_form['componentList'][1]['fieldValue'] = 'site16445.1'

            response = api.add_site_account_and_wait(16445, login_form)
            expect(response).to be_success

            expect(response.body['siteRefreshInfo']['siteRefreshMode']['refreshMode']).to eq('MFA')
            api.get_mfa_response_for_site response.body['siteAccountId']
          }

          include_examples 'request_response_examples'

          it 'is expected be a valid response' do
            is_expected.to be_kind_of(Yodleeicious::Response)
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
            expect(response).to be_success

            response = api.get_site_login_form(16445)
            expect(response).to be_success

            login_form = response.body
            login_form['componentList'][0]['fieldValue'] = 'yodlicious1.site16445.1'
            login_form['componentList'][1]['fieldValue'] = 'site16445.1'

            response = api.add_site_account(16445, login_form)
            expect(response).to be_success

            expect(response.body['siteRefreshInfo']['siteRefreshMode']['refreshMode']).to eq('MFA')
            api.get_mfa_response_for_site_and_wait response.body['siteAccountId'], 2
          }

          include_examples 'request_response_examples'

          it 'is expected be a valid response' do
            is_expected.to be_kind_of(Yodleeicious::Response)
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

              response = api.get_site_login_form(16445)
              expect(response).to be_success

              login_form = response.body

              login_form['componentList'][0]['fieldValue'] = 'yodlicious1.site16445.1'
              login_form['componentList'][1]['fieldValue'] = 'site16445.1'

              response = api.add_site_account(16445, login_form)
              expect(response).to be_success

              expect(response.body['siteRefreshInfo']['siteRefreshMode']['refreshMode']).to eq('MFA')
              site_account_id = response.body['siteAccountId']
              response = api.get_mfa_response_for_site_and_wait site_account_id, 2
              expect(response.body['isMessageAvailable']).to be_truthy

              field_info = response.body['fieldInfo']
              field_info['fieldValue'] = "monkeys"
              api.put_mfa_request_for_site site_account_id, :MFATokenResponse, field_info
            }

            include_examples 'request_response_examples'

            it 'is expected be a valid response' do
              is_expected.to be_kind_of(Yodleeicious::Response)
              is_expected.to be_success
              expect(subject.body['primitiveObj']).to be_truthy
            end

            after { api.unregister_user }
          end
        end

        context 'Given a user attempting to add a site with Security Question and Answer MFA' do
          context 'When #put_mfa_request_for_site is called the response' do
            subject {
              api.cobranded_login
              response = api.login_or_register_user "testuser#{rand(100...200)}", 'testpassword143', 'test@test.com'

              response = api.get_site_login_form(16486)
              expect(response).to be_success

              login_form = response.body
              login_form['componentList'][0]['fieldValue'] = 'yodlicious1.site16486.1'
              login_form['componentList'][1]['fieldValue'] = 'site16486.1'

              response = api.add_site_account(16486, login_form)
              expect(response).to be_success

              expect(response.body['siteRefreshInfo']['siteRefreshMode']['refreshMode']).to eq('MFA')
              site_account_id = response.body['siteAccountId']
              response = api.get_mfa_response_for_site_and_wait site_account_id, 2
              expect(response.body['isMessageAvailable']).to be_truthy

              field_info = response.body['fieldInfo']
              field_info['questionAndAnswerValues'][0]['fieldValue'] = 'Texas'
              field_info['questionAndAnswerValues'][1]['fieldValue'] = 'w3schools'
              api.put_mfa_request_for_site site_account_id, :MFAQuesAnsResponse, field_info
            }

            include_examples 'request_response_examples'

            it 'is expected be a valid response' do
              is_expected.to be_kind_of(Yodleeicious::Response)
              is_expected.to be_success
              expect(subject.body['primitiveObj']).to be_truthy
            end

            after { api.unregister_user }
          end
        end

        context 'Given a user attempting to add a site with Captcha MFA' do
          context 'When #put_mfa_request_for_site is called the response' do
            subject {
              api.cobranded_login
              response = api.login_or_register_user "testuser#{rand(100...200)}", 'testpassword143', 'test@test.com'
              expect(response).to be_success

              response = api.get_site_login_form(18769)
              expect(response).to be_success

              login_form = response.body
              login_form['componentList'][0]['fieldValue'] = 'yodlicious1.site18769.1'
              login_form['componentList'][1]['fieldValue'] = 'site18769.1'

              response = api.add_site_account(18769, login_form)
              expect(response).to be_success

              expect(response.body['siteRefreshInfo']['siteRefreshMode']['refreshMode']).to eq('MFA')
              site_account_id = response.body['siteAccountId']
              response = api.get_mfa_response_for_site_and_wait site_account_id, 2
              expect(response.body['isMessageAvailable']).to be_truthy

              field_info = response.body['fieldInfo']
              field_info['fieldValue'] = "monkeys"
              api.put_mfa_request_for_site site_account_id, :MFAImageResponse, field_info
            }

            include_examples 'request_response_examples'

            it 'is expected be a valid response' do
              is_expected.to be_kind_of(Yodleeicious::Response)
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

      context 'when getAllSiteAccounts is called the return' do
        subject { api.get_all_site_accounts }

        include_examples 'request_response_examples'

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

          is_expected.to be_kind_of(Yodleeicious::Response)
          is_expected.to be_success
          expect(subject.body[0]['itemId']).not_to be_nil
        end
      end

      context 'when getItemSummaries is called the return' do
        subject { api.get_item_summaries }

        it 'is expected to return an array of site summaries' do
          # puts JSON.pretty_generate(subject)

          is_expected.to be_kind_of(Yodleeicious::Response)
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
        dag_login_form['componentList'][0]['fieldValue'] = 'yodlicious.site16441.1'
        dag_login_form['componentList'][1]['fieldValue'] = 'site16441.1'
        api.add_site_account(16441, dag_login_form)
      }

      context 'When a transaction search for all transactions is performed the result' do
        subject { api.execute_user_search_request }

        it 'is expected to return a valid search result' do
          # puts JSON.pretty_generate(subject.body)

          is_expected.not_to be_nil
          is_expected.to be_kind_of(Yodleeicious::Response)
          is_expected.to be_success
          expect(subject.body['errorOccurred']).to be_nil
          expect(subject.body['searchIdentifier']).not_to be_nil
          expect(subject.body['searchResult']['transactions']).to be_kind_of(Array)
          expect(subject.body['searchResult']['transactions'].length).to be > 0
        end
      end
    end
  end

  pending 'downloading transaction history'
  pending 'fetching a list of content services'
  pending 'failing to create a new session'
  pending 'failing when running a search for a site'

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
