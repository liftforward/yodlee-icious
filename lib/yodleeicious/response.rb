module Yodleeicious
  class Response

    def initialize res, payload=nil
      @res = res
      @payload = payload
    end

    def success?
      !fail?
    end

    def fail?
      body.kind_of?(Hash) && (body['errorOccurred'] == 'true' || body.has_key?('Error'))
    end

    def body
      @body ||= JSON.parse(@res.body)
    end

    def payload
      @payload
    end

    def request_url
      @res.env.url.to_s
    rescue
      nil
    end

    def status
      @res.status
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
