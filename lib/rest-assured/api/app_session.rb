require 'childprocess'

module RestAssured
  class AppSession
    def initialize
      @child = ChildProcess.build('rest-assured', *Config.to_cmdargs)
      @child.io.inherit!
      @child.start
    end

    def method_missing(*args)
      @child.send(*args)
    end
  end
end
