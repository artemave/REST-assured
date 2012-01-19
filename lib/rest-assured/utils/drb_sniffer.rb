require 'drb'

module RestAssured
  module Utils
    module DrbSniffer
      def drb? # stolen from rspec
        (DRb.current_server rescue false) &&
          !!(DRb.current_server.uri =~ %r{druby://127\.0\.0\.1:})
      end
    end
  end
end
