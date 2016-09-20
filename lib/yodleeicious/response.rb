module Yodleeicious
  class Response

    def initialize res, payload=nil
      @body = JSON.parse(res.body)
      @request_url = begin res.env.url.to_s rescue nil end
      @payload = payload
    end

    def success?
      !fail?
    end

    def fail?
      body.kind_of?(Hash) && (body['errorOccurred'] == 'true' || body.has_key?('Error'))
    end

    def body
      @body
    end

    def payload
      @payload
    end

    def request_url
      @request_url
    end

    def response
      body
    end

    def error
      if body.kind_of?(Hash)
        if body.has_key?('Error')
          body['Error'][0]['errorDetail']
        elsif body['errorOccurred'] == 'true'
          body['exceptionType']
        end
      end
    end
  end
end
