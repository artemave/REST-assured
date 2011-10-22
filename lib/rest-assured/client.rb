require 'rest-assured/client/resources'

module RestAssured
  module Client
    class Config
      attr_reader :server_address

      def server_address=(addr)
        @server_address = Double.site = addr
      end
    end

    def self.config
      @config ||= Config.new
    end
  end
end
