require 'active_resource'
require 'uri'

module RestAssured::Client
  class Double < ActiveResource::Base
    def self.site
      URI.parse RestAssured::Client.config.server_address
    end
  end
end
