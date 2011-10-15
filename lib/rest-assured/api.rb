require 'rest-assured/port_explorer'
require 'slave'

# XXX hack to fix "too long unix socket path (max: 103bytes)" on Mac
def Dir.tmpdir
  '/tmp'
end

module RestAssured
  class Server
    attr_reader :app

    def self.start
      slave = Slave.new(:object => RestAssured::Server.new)
      server = slave.object

      server.app.run!
    end

    def initialize(app = RestAssured::Application)
      @app = app
    end
  end
end
