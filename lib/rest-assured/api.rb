require 'rest-assured/port_explorer'
require 'rest-assured/satellite_process'

module RestAssured
  class Server
    attr_reader :port

    def initialize(port_explorer = PortExplorer.new)
      @port_explorer = port_explorer
    end

    def start
      port = @port_explorer.free_tcp_port

      SatelliteProcess.new do
        Kernel.system("bundle exec rest-assured -d :memory: -p #{port}")
      end

      @port = port
    end
  end
end
