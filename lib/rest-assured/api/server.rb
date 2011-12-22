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
      Config.build(opts)

      @child = Utils::Subprocess.new do
        RestAssured::Application.run!
      end
    end

    def start(*args)
      start!(*args)

      until up?
        sleep 1
      end
    end

    def stop
      @child.stop
    end

    def up?
      !@child.nil? && @child.alive?
    end

    def self.method_missing(*args)
      instance.send(*args)
    end
  end
end
