require "yodlicious"

describe 'the yodlee api client integration test', integration: true do
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
        context 'When /jsonsdk/UserRegistration/register3 endpoint is called' do
          describe 'the response' do
            subject {
              api.cobranded_login
              api.user_login 'testuser', 'testpassword143'
              api.unregister_user
              api.register_user 'testuser', 'testpassword143', 'test@test.com'
            }

            it { is_expected.to be_kind_of(Hash) }
            it { is_expected.not_to be_empty }

            it 'is expected to not return an error' do
              expect(subject['errorOccurred']).to be_nil
            end

            it 'is expected to contain a new sessionToken' do
              #{"userContext":{"conversationCredentials":{"sessionToken":"12162013_1:ca362b46803f7ff4ea73e413a0341b6cdf895f51831d01856bfd4daaa5f816810b36252569cd7b4fd8e115b00c674e7162d01a008802c10aec3af48096e74005"},"valid":true,"isPasswordExpired":false,"cobrandId":15910008380,"channelId":-1,"locale":"en_US","tncVersion":2,"applicationId":"270772870CDC1786FFEDECFDA1FDBC00","cobrandConversationCredentials":{"sessionToken":"12162013_1:55a575777b5509749442b93651ca1400936d3562e30f82fbfb561f29abab7e129086259e1ac30d0247f5fbc25aed9752fb9bd287e7ccedbb65dfc8ec98841cc6"},"preferenceInfo":{"currencyCode":"USD","timeZone":"PST","dateFormat":"MM/dd/yyyy","currencyNotationType":{"currencyNotationType":"SYMBOL"},"numberFormat":{"decimalSeparator":".","groupingSeparator":",","groupPattern":"###,##0.##"}}},"lastLoginTime":1424115740,"loginCount":0,"passwordRecovered":false,"emailAddress":"test@test.com","loginName":"testuser","userId":19843605,"isConfirmed":false} headers={"x-powered-by"=>"Unknown", "set-cookie"=>"JSESSIONID=A3099AF04A71E6237973B2AAC7B21F8F; Path=/yodsoap; Secure", "content-type"=>"application/json", "vary"=>"Accept-Encoding", "date"=>"Mon, 16 Feb 2015 19:42:20 GMT", "connection"=>"close", "server"=>"Unknown"}
              expect(subject['userContext']['conversationCredentials']['sessionToken']).to be_kind_of(String)
              expect(subject['userContext']['conversationCredentials']['sessionToken'].length).to be > 0

              expect(api.user_session_token).not_to be_nil
            end

            after {
              api.unregister_user
            }
          end
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

      after {
        begin
          api.unregister_user
        rescue
        end
      }

      let(:chase_login_form) {
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
              value: 'ILoveTheGrammys'
            }
          ],
          defaultHelpText: 324
        }
      }

      context 'When a invalid username and password for an account is added' do
        subject { api.add_site_account_and_wait(643, chase_login_form) }

        it 'is expected to respond with siteRefreshStatus=LOGIN_FAILURE and refreshMode=NORMAL a siteAccountId' ,focus: true do
          expect(subject['siteRefreshInfo']['siteRefreshStatus']['siteRefreshStatus']).to eq('LOGIN_FAILURE')
          expect(subject['siteRefreshInfo']['siteRefreshMode']['refreshMode']).to eq('NORMAL')
          expect(subject['siteAccountId']).not_to be_nil
          # puts JSON.pretty_generate(subject)
        end
      end
    end
  end

  describe 'the yodlee apis fetching summary data about registered accounts endpoints' do
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

      context 'when getItemSummaries is called the return' do
        subject { api.get_item_summaries }

        it { is_expected.not_to be_nil }
        it { is_expected.to be_kind_of(Array) }

        it 'is expected to return more than 0 sites' do
          expect(subject.length).to be > 0
        end
      end
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

  describe 'the yodlee apis site info' do
    context 'Given a registered cobranded session' do
      before { 
        api.cobranded_login
        # api.user_login 'sbMemandrewnichols2', 'sbMemandrewnichols2#123'
      }

      context 'When a request for site info is performed the result' do
        subject { api.get_site_info 643 }

        it { is_expected.to be_kind_of(Hash) }
        it 'is expected to not contain an error' do
          puts JSON.pretty_generate subject
          expect(subject['errorOccurred']).to be_nil
        end
        it { is_expected.not_to be_nil }

        it 'is expected to contain login form details' do
          expect(subject['loginForms']).not_to be_nil
          expect(subject['loginForms']).to be_kind_of(Array)
          expect(subject['loginForms'].length).to be > 0
        end

        # it 'is expected to contain an array of transactions larger then 0' do
        #   expect(subject['searchResult']['transactions']).to be_kind_of(Array)
        #   expect(subject['searchResult']['transactions'].length).to be > 0
        # end
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

end
