require 'drb'

module RestAssured
  module Utils
    module DrbSniffer
      def running_in_spork?
        defined?(Spork) && Spork.using_spork?
      end
    end
  end
end
