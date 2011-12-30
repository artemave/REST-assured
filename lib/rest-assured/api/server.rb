require 'singleton'
require 'rest-assured/config'
require 'rest-assured/api/resources'
require 'rest-assured/application'
require 'rest-assured/utils/subprocess'
require 'rest-assured/utils/port_explorer'

module RestAssured
  class Server
    include Singleton

    def start!(opts = {})
      stop if up?

      Config.build(opts)

      Double.site = "http#{AppConfig.use_ssl ? 's' : ''}://127.0.0.1:#{AppConfig.port}"

      @child = Utils::Subprocess.new do
        RestAssured::Application.send(:include, Config)
        RestAssured::Application.run!
      end
    end

    def start(*args)
      start!(*args)

      begin
        sleep 0.5
      end while not up?
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
