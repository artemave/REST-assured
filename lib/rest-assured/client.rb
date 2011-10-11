module RestAssured
  module Client
    def self.config
      @config ||= OpenStruct.new(:server_address => 'http://localhost:4567')
    end
  end
end

require 'rest-assured/client/resources'
