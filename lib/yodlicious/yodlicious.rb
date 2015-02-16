require 'json'


module Yodlicious
  class YodleeApi

    def initialize config = {}
      unless (config.empty?)
        configure config
      end
    end

    def configure config
      @base_url = config[:base_url]
      @cobranded_username = config[:cobranded_username]
      @cobranded_password = config[:cobranded_password]
      @proxy_url = config[:proxy_url]
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

    def proxy_url
      @proxy_url
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

      @cobranded_auth = execute_api '/authenticate/coblogin', params
      @cobranded_auth
    end

    def user_login login, pass
      params = {
        login: login,
        password: pass,
        cobSessionToken: session_token
      }

      response = execute_api '/authenticate/login', params

      #TODO validate response before setting
      @user_auth = response
    end

    def site_search search_string
      authenticated_execute_api "/jsonsdk/SiteTraversal/searchSite", { siteSearchString: search_string }
    end

    def search_content_services search_string
      authenticated_execute_api "/jsonsdk/Search/searchContentServices", { keywords: search_string }
    end

    def add_site_account site_id, site_login_form
      params = { 
        siteId: site_id
      }.merge(translator.site_login_form_to_add_site_account_params(site_login_form))

      authenticated_execute_api '/jsonsdk/SiteAccountManagement/addSiteAccount1', params
    end

    def get_item_summaries
      authenticated_execute_api '/jsonsdk/DataService/getItemSummaries', { 'bridgetAppId' => '10003200' }
    end

    def get_item_summaries_for_site site_account_id
      authenticated_execute_api '/jsonsdk/DataService/getItemSummariesForSite', { memSiteAccId: site_account_id }
    end

    def get_all_site_accounts
      authenticated_execute_api '/jsonsdk/SiteAccountManagement/getAllSiteAccounts'
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

      authenticated_execute_api "/jsonsdk/TransactionSearchService/executeUserSearchRequest", params
    end

    def cobranded_session_execute_api uri, params = {}
      params = {
        cobSessionToken: session_token,
      }.merge(params)

      execute_api uri, params
    end

    def authenticated_execute_api uri, params = {}
      params = {
        cobSessionToken: session_token,
        userSessionToken: user_session_token
      }.merge(params)

      execute_api uri, params
    end



    def execute_api uri, params = {}
      # puts "calling #{uri} with #{params}"

        # uri:  URI.parse(proxy_url),
        # user: 'socksuser',
        # password: 'sockspassword',
        # socks: true  # this was because Faraday was barfing when using socks scheme 
                       # (e.g. 'socks://123.45.67.89:1080')
      # }


      ssl_opts = {verify: false}

      connection = Faraday.new(url: base_url,
                               ssl: ssl_opts,
                               request: { proxy: proxy_opts }) #do |c|
        # c.headers[:user_agent] = "Just Some Engineer"
        # c.adapter :net_http
        # c.response :logger 
      # end

      response = connection.post("#{base_url}#{uri}", params)
      # puts "response=#{response.status} body=#{response.body} headers=#{response.headers}"

      case response.status
      when 200
        JSON.parse(response.body)
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

    def session_token
      cobranded_auth['cobrandConversationCredentials']['sessionToken']
    end

    def user_session_token
      user_auth['userContext']['conversationCredentials']['sessionToken']
    end

  end
end
