require 'singleton'
require 'rest-assured/config'
require 'rest-assured/api/resources'
require 'rest-assured/api/app_session'
require 'rest-assured/utils/port_explorer'

module RestAssured
  class Server
    attr_reader :address

    include Singleton

    def start!(opts = {})
      stop if up?

      Config.build(opts)

      self.address = "http#{AppConfig.use_ssl ? 's' : ''}://127.0.0.1:#{AppConfig.port}"

      @session = AppSession.new
    end

    def start(*args)
      start!(*args)

      begin
        sleep 0.5
      end while not up?
    end

    def address=(address)
      Double.site = @address = address
    end

    def stop
      @session.stop
    end

    def up?
      !@session.nil? && @session.alive? && !Utils::PortExplorer.port_free?(AppConfig.port)
    end

    def self.method_missing(*args)
      instance.send(*args)
    end
  end
end
