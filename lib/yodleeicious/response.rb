module Yodleeicious
  class Response

    def initialize body
      @body = body
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
