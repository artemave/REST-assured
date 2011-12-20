require 'active_resource'

module RestAssured
  class MoreRequestsExpected < StandardError; end

  class Double < ActiveResource::Base
    def response_headers
      attributes[:response_headers].attributes
    end

    def wait_for_requests(n, opts = {})
      timeout = opts[:timeout] || 5

      timeout.times do
        sleep 1
        reload
        return if requests.count >= n
      end
      raise MoreRequestsExpected.new("Expected #{n} requests. Got #{requests.count}.")
    end
  end
end
