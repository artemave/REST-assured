module RestAssured
  module Utils
    module DrbSniffer
      def drb?
        begin
          !!RSpec.configuration.drb
        rescue NameError
          ARGV.include?('--drb')
        end
      end
    end
  end
end
