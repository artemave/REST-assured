require 'socket'

module RestAssured
  module Utils
    class PortExplorer
      def self.free_port
        server = TCPServer.new('127.0.0.1', 0)
        free_port = server.addr[1]
        server.close
        free_port
      end

      def self.port_free?(port)
        Net::HTTP.get('127.0.0.1', '/', port)
      rescue => e
        e.is_a?(Errno::ECONNREFUSED)
      else
        false
      end
    end
  end
end
