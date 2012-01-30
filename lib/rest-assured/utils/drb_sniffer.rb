require 'drb'

module RestAssured
  module Utils
    module DrbSniffer
      def running_in_drb?
        defined?(Spork) and Spork.using_spork?
      end
    end
  end
end
