require 'rest-client'
require 'json'

module Yodlicious
  class YodleeApi

    def initialize config = {}
      unless (config.empty?)
        configure config
      end
    end

    def configure config
      @base_url = config['base_url']
      @cobranded_username = config['cobranded_username']
      @cobranded_password = config['cobranded_password']
    end

    def base_url
      @base_url
    end

    def cobranded_username
      @cobranded_username
    end

    def cobranded_password
      @cobranded_password
    end

    def cobranded_login
      params = {
        cobrandLogin: cobranded_username,
        cobrandPassword: cobranded_password
      }
      
      #TODO validate response before setting
      @cobranded_auth = execute_api '/authenticate/coblogin', params
      @cobranded_auth
    end

    def user_login login, pass
      params = {
        login: login,
        password: pass,
        cobSessionToken: session_token
      }

      # puts "user_login.params: #{params}"
      response = execute_api '/authenticate/login', params

      #validate response before setting
      @user_auth = response
    end

    def site_search search_string
      # puts "site_search.params: #{params}"
      authenticated_execute_api "/jsonsdk/SiteTraversal/searchSite", { siteSearchString: search_string }
    end


    def add_site_account site_id, site_login_form
      params = { 
        siteId: site_id
      }.merge(site_login_form_to_add_site_account_params(site_login_form))

      # puts "site_search.params: #{params}"
      authenticated_execute_api '/jsonsdk/SiteAccountManagement/addSiteAccount1', params
    end


    def site_login_form_to_add_site_account_params site_login_form
      
      params = { "credentialFields.enclosedType" => "com.yodlee.common.FieldInfoSingle" }

      i = 0
      site_login_form[:componentList].each { |field|
        # puts "field=#{field}"
        params["credentialFields[#{i}].displayName"] = field[:displayName]
        params["credentialFields[#{i}].fieldType.typeName"] = field[:fieldType][:typeName]
        params["credentialFields[#{i}].helpText"] = field[:helpText]
        params["credentialFields[#{i}].maxlength"] = field[:maxlength]
        params["credentialFields[#{i}].name"] = field[:name]
        params["credentialFields[#{i}].size"] = field[:size]
        params["credentialFields[#{i}].value"] = field[:value]
        params["credentialFields[#{i}].valueIdentifier"] = field[:valueIdentifier]
        params["credentialFields[#{i}].valueMask"] = field[:valueMask]
        params["credentialFields[#{i}].isEditable"] = field[:isEditable]
        params["credentialFields[#{i}].value"] = field[:value]

        i += 1
      }

      params
    end

    def get_item_summaries_for_site site_account_id
      authenticated_execute_api '/jsonsdk/DataService/getItemSummariesForSite', { memSiteAccId: site_account_id }
    end

    def get_all_site_accounts
      authenticated_execute_api '/jsonsdk/SiteAccountManagement/getAllSiteAccounts'
    end

    def execute_user_search_request options = {}
      params = {
        'transactionSearchRequest.containerType' => 'All',
        'transactionSearchRequest.lowerFetchLimit' => 1,
        'transactionSearchRequest.higherFetchLimit' => 500,
        'transactionSearchRequest.resultRange.startNumber' => 1,
        'transactionSearchRequest.resultRange.endNumber' => 10,
        'transactionSearchRequest.searchClients.clientId' => 1,
        'transactionSearchRequest.searchClients.clientName' => 'DataSearchService',
        'transactionSearchRequest.ignoreUserInput' => true,
        #todo make it so that we can pass a simpler hash of arguments
        # 'transactionSearchRequest.userInput' => nil,
        # 'transactionSearchRequest.searchFilter.currencyCode' => nil,
        # 'transactionSearchRequest.searchFilter.postDateRange.fromDate' => nil,
        # 'transactionSearchRequest.searchFilter.postDateRange.toDate' => nil,
        # 'transactionSearchRequest.searchFilter.itemAccountId.identifier' => nil,
        'transactionSearchRequest.searchFilter.transactionSplitType' => 'ALL_TRANSACTION'
      }.merge(options)

      # puts "execute_user_search_request.params=#{params}"
      authenticated_execute_api "/jsonsdk/TransactionSearchService/executeUserSearchRequest", params
    end

    # def register
    #   params = {
    #     cobSessionToken: session_token,
    #     userCredentials: {
    #       loginName: 
    #       password: 
    #       objectInstanceType: 'com.yodlee.ext.login.PasswordCredentials'
    #     },

    #   }
    #   "#{base_url}/jsonsdk/UserRegistration/register3"
    # end
    def authenticated_execute_api uri, params = {}
      params = {
        cobSessionToken: session_token,
        userSessionToken: user_session_token
      }.merge(params)

      execute_api uri, params
    end

    def execute_api uri, params = {}
      RestClient.post("#{base_url}#{uri}", params) { |response, request, result, &block|
        # puts "execute_user_search_request.response=#{response}"
        case response.code
        when 200
          # puts "site_search.response: #{JSON.parse(response)}"
          JSON.parse(response)
        else
          response.return!(request, result, &block)
        end
      }
    end

    def cobranded_auth
      @cobranded_auth
    end

    def user_auth
      @user_auth
    end

    def session_token
      cobranded_auth['cobrandConversationCredentials']['sessionToken']
    end

    def user_session_token
      user_auth['userContext']['conversationCredentials']['sessionToken']
    end

    # def logger
    #   Rails.logger
    # end
  end
end
