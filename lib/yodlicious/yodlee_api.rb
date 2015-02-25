require 'json'


module Yodlicious
  class YodleeApi
    attr_reader :base_url, :cobranded_username, :cobranded_password, :proxy_url, :logger

    def initialize config = {}
      configure config
    end

    def configure config = {}
      validate config
      @base_url = config[:base_url] || Yodlicious::Config.base_url
      @cobranded_username = config[:cobranded_username] || Yodlicious::Config.cobranded_username
      @cobranded_password = config[:cobranded_password] || Yodlicious::Config.cobranded_password
      @proxy_url = config[:proxy_url] || Yodlicious::Config.proxy_url
      @logger = config[:logger] || Yodlicious::Config.logger
      
      info_log "YodleeApi configured with base_url=#{base_url} cobranded_username=#{cobranded_username} proxy_url=#{proxy_url} logger=#{logger}"
    end

    def validate config
      [:proxy_url, :base_url, :cobranded_username, :cobranded_password, :logger].each { |key|
        if config.has_key?(key) && config[key].nil?
          raise "Invalid config provided to YodleeApi. Values may not be nil or blank."
        end
      }
    end

    def proxy_opts
      proxy_opts = {}

      unless proxy_url == nil
        proxy_opts[:uri] = URI.parse(proxy_url) 
        proxy_opts[:socks] = use_socks?
      end

      proxy_opts
    end

    def use_socks?
      return proxy_url != nil && proxy_url.start_with?('socks') 
    end

    def cobranded_login
      params = {
        cobrandLogin: cobranded_username,
        cobrandPassword: cobranded_password
      }

      response = execute_api '/authenticate/coblogin', params

      if response.success?
        @cobranded_auth = response.body
      else
        @cobranded_auth = nil
      end

      response
    end

    def user_login login, pass
      params = {
        login: login,
        password: pass
      }

      response = cobranded_session_execute_api '/authenticate/login', params

      if response.success?
        @user_auth = response.body
      else
        @user_auth = nil
      end

      response
    end

    def logout_user
      user_session_execute_api '/jsonsdk/Login/logout'
    end

    def register_user username, password, emailAddress, options = {}
      params = {
        'userCredentials.loginName' => username,
        'userCredentials.password' => password,
        'userCredentials.objectInstanceType' => 'com.yodlee.ext.login.PasswordCredentials',
        'userProfile.emailAddress' => emailAddress
        #todo add in user preferences
      }.merge(options)

      response = cobranded_session_execute_api "/jsonsdk/UserRegistration/register3", params

      if response.success?
        @user_auth = response.body
      else
        @user_auth = nil
      end

      response
    end

    def login_or_register_user  username, password, email
      info_log "attempting to login #{username}"
      response = user_login(username, password)

      #TODO look into what other errors could occur here
      if response.fail? && response.error == "Invalid User Credentials"
        info_log "invalid credentials for #{username} attempting to register"
        response = register_user username, password, email
      end

      if response.success?
        @user_auth = response.body
      else
        @user_auth = nil
      end

      response
    end

    def unregister_user
      user_session_execute_api '/jsonsdk/UserRegistration/unregister'
    end

    def site_search search_string
      user_session_execute_api "/jsonsdk/SiteTraversal/searchSite", { siteSearchString: search_string }
    end

    def search_content_services search_string
      user_session_execute_api "/jsonsdk/Search/searchContentServices", { keywords: search_string }
    end

    def add_site_account site_id, site_login_form
      params = { 
        siteId: site_id
      }.merge(translator.site_login_form_to_add_site_account_params(site_login_form))

      user_session_execute_api '/jsonsdk/SiteAccountManagement/addSiteAccount1', params
    end


    def add_site_account_and_wait site_id, site_login_form, refresh_interval = 0.5, refresh_trys = 5
      response = add_site_account(site_id, site_login_form)

      #TODO validate response with assert
      if response.success?

         if response.body['siteRefreshInfo']['siteRefreshStatus']['siteRefreshStatus'] == 'REFRESH_TRIGGERED' &&
            response.body['siteRefreshInfo']['siteRefreshMode']['refreshMode'] == 'NORMAL'

          site_account_id = response.body['siteAccountId']
          trys = 1
          begin
            info_log "try #{trys} to get refresh_info for #{site_id}"
            trys += 1
            sleep(refresh_interval)
            refresh_info_response = get_site_refresh_info site_account_id
            response.body['siteRefreshInfo'] = refresh_info_response.body unless refresh_info_response.fail?
          end until (refresh_info_response.success? && refresh_info_response.body['siteRefreshStatus']['siteRefreshStatus'] != 'REFRESH_TRIGGERED') || trys > refresh_trys
        end

        response
      end
    end

    def get_site_refresh_info site_account_id
      user_session_execute_api '/jsonsdk/Refresh/getSiteRefreshInfo', { memSiteAccId: site_account_id }
    end

    def get_item_summaries
      user_session_execute_api '/jsonsdk/DataService/getItemSummaries', { 'bridgetAppId' => '10003200' }
    end

    def get_item_summaries_for_site site_account_id
      user_session_execute_api '/jsonsdk/DataService/getItemSummariesForSite', { memSiteAccId: site_account_id }
    end

    def get_all_site_accounts
      user_session_execute_api '/jsonsdk/SiteAccountManagement/getAllSiteAccounts'
    end

    def get_site_info site_id
      params = {
        'siteFilter.siteId' => site_id,
        'siteFilter.reqSpecifier' => 16
      }
      cobranded_session_execute_api '/jsonsdk/SiteTraversal/getSiteInfo', params
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

      user_session_execute_api "/jsonsdk/TransactionSearchService/executeUserSearchRequest", params
    end

    def cobranded_session_execute_api uri, params = {}
      params = {
        cobSessionToken: cobranded_session_token,
      }.merge(params)

      execute_api uri, params
    end

    def user_session_execute_api uri, params = {}
      params = {
        userSessionToken: user_session_token
      }.merge(params)

      cobranded_session_execute_api uri, params
    end

    def execute_api uri, params = {}
      debug_log "calling #{uri} with #{params}"
      ssl_opts = { verify: false }
      connection = Faraday.new(url: base_url, ssl: ssl_opts, request: { proxy: proxy_opts })

      response = connection.post("#{base_url}#{uri}", params)
      debug_log "response=#{response.status} body=#{response.body} headers=#{response.headers}"

      case response.status
      when 200
        Response.new(JSON.parse(response.body))
      else
      end
    end

    def translator
      @translator ||= ParameterTranslator.new
    end

    def cobranded_auth
      @cobranded_auth
    end

    def user_auth
      @user_auth
    end

    def cobranded_session_token
      return nil if cobranded_auth.nil?
      cobranded_auth.fetch('cobrandConversationCredentials',{}).fetch('sessionToken','dude')
    end

    def user_session_token
      return nil if user_auth.nil?
      user_auth.fetch('userContext',{}).fetch('conversationCredentials',{}).fetch('sessionToken',nil)
    end

    def debug_log msg
      logger.info msg
    end

    def info_log msg
      logger.info msg
    end

  end
end
