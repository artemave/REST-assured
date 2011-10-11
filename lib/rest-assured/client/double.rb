require 'active_resource'

module RestAssured
  module Client
    class Double < ActiveResource::Base
      self.site = RestAssured.config.server_address
    end
  end
end
