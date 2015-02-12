require 'rest-client'
require 'json'

module Yodlicious
  class YodleeApi

    def initialize config
      if (config)
        configure config
      end
    end

    def configure config
      @base_url = config['base_url']
      @username = config['username']
      @password = config['password']
    end

    def base_url
      @base_url
    end

    def username
      @username
    end

    def password
      @password
    end

    def cobranded_login
      params = {
        cobrandLogin: username,
        cobrandPassword: password
      }
      RestClient.post("#{base_url}/authenticate/coblogin", params) { |response, request, result, &block|
        case response.code
        when 200
          # puts "cobranded_login.response: #{JSON.parse(response)}"
          @cobranded_auth = JSON.parse(response)
        else
          response.return!(request, result, &block)
        end
      }
    end

    def user_login login, pass
      params = {
        login: login,
        password: pass,
        cobSessionToken: session_token
      }

      # puts "user_login.params: #{params}"
      RestClient.post("#{base_url}/authenticate/login", params) { |response, request, result, &block|
        case response.code
        when 200
          # puts "user_login.response: #{JSON.parse(response)}"
          @user_auth = JSON.parse(response)
        else
          response.return!(request, result, &block)
        end
      }
    end

    def site_search search_string
      params = { 
        cobSessionToken: session_token,
        userSessionToken: user_session_token,
        siteSearchString: search_string
      }
      # puts "site_search.params: #{params}"
      RestClient.post("#{base_url}/jsonsdk/SiteTraversal/searchSite", params) { |response, request, result, &block|
        case response.code
        when 200
          # puts "site_search.response: #{JSON.parse(response)}"
          JSON.parse(response)
        else
          response.return!(request, result, &block)
        end
      }
    end


    def add_site_account site_id, site_login_form
      params = { 
        cobSessionToken: session_token,
        userSessionToken: user_session_token,
        siteId: site_id
      }.merge(site_login_form_to_add_site_account_params(site_login_form))

      # puts "site_search.params: #{params}"
      RestClient.post("#{base_url}/jsonsdk/SiteAccountManagement/addSiteAccount1", params) { |response, request, result, &block|
        case response.code
        when 200
          # puts "site_search.response: #{JSON.parse(response)}"
          JSON.parse(response)
        else
          response.return!(request, result, &block)
        end
      }
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
      params = {
        cobSessionToken: session_token,
        userSessionToken: user_session_token,
        memSiteAccId: site_account_id
      }

      # puts "get_item_summaries_for_site.params=#{params}"
      RestClient.post("#{base_url}/jsonsdk/DataService/getItemSummariesForSite", params) { |response, request, result, &block|
        # puts "get_item_summaries_for_site.response=#{response.headers}"
        case response.code
        when 200
          # puts "site_search.response: #{JSON.parse(response)}"
          JSON.parse(response)
        else
          response.return!(request, result, &block)
        end
      }
    end

    def get_all_site_accounts
      params = {
        cobSessionToken: session_token,
        userSessionToken: user_session_token
      }

      # puts "get_item_summaries_for_site.params=#{params}"
      RestClient.post("#{base_url}/jsonsdk/SiteAccountManagement/getAllSiteAccounts", params) { |response, request, result, &block|
        # puts "get_item_summaries_for_site.response=#{response.headers}"
        case response.code
        when 200
          # puts "site_search.response: #{JSON.parse(response)}"
          JSON.parse(response)
        else
          response.return!(request, result, &block)
        end
      }
    end

    def execute_user_search_request options = {}
      params = {
        cobSessionToken: session_token,
        userSessionToken: user_session_token,
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
      RestClient.post("#{base_url}/jsonsdk/TransactionSearchService/executeUserSearchRequest", params) { |response, request, result, &block|
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
