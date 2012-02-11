require 'singleton'
require 'rest-assured/config'
require 'rest-assured/api/resources'
require 'rest-assured/api/app_session'
require 'rest-assured/utils/port_explorer'

module RestAssured
  class Server
    attr_reader :address

    include Singleton

    at_exit do
      instance.stop if instance
    end

    def start!(opts = {})
      stop if up?

      Config.build(opts)

      self.address = "http#{AppConfig.ssl ? 's' : ''}://127.0.0.1:#{AppConfig.port}"

      @session = AppSession.new
    end

    def start(*args)
      start!(*args)

      while not up?
        sleep 0.5
      end
    end

    def address=(address)
      Double.site = @address = address
    end

    def stop
      @session.try(:stop)

      10.times do
        if up?
          sleep 0.5
          next
        else
          return
        end
      end
      raise "Failed to stop RestAssured server"
    end

    def up?
      !!@session && @session.alive? && !Utils::PortExplorer.port_free?(AppConfig.port) 
    end

    def self.method_missing(*args)
      instance.send(*args)
    end
  end
end
