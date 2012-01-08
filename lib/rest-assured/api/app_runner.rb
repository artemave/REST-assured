require 'singleton'

module RestAssured
  class AppRunner
    include Singleton

    def run!
      unless Kernel.require 'rest-assured/application'
        RestAssured::Application.send(:include, Config)
      end
      RestAssured::Application.run!
    end

    def self.method_missing(*args)
      instance.send(*args)
    end
  end
end
