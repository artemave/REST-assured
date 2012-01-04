require 'singleton'
require 'rest-assured/config'
require 'rest-assured/api/resources'
require 'rest-assured/utils/subprocess'
require 'rest-assured/utils/port_explorer'

module RestAssured
  class Server
    attr_reader :address

    include Singleton

    def start!(opts = {})
      stop if up?

      Config.build(opts)

      self.address = "http#{AppConfig.use_ssl ? 's' : ''}://127.0.0.1:#{AppConfig.port}"

      @child = Utils::Subprocess.new do
        if defined?(RestAssured::Application)
          RestAssured::Application.send(:include, Config)
        else
          require 'rest-assured/application'
        end

        RestAssured::Application.run!
      end
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
      @child.stop
    end

    def up?
      !@child.nil? && @child.alive? && !Utils::PortExplorer.port_free?(AppConfig.port)
    end

    def self.method_missing(*args)
      instance.send(*args)
    end
  end
end
