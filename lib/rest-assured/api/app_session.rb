require 'childprocess'

module RestAssured
  class AppSession
    def initialize
      @child = ChildProcess.build('bin/rest-assured', *Config.to_cmdargs)
      @child.cwd = File.expand_path '../../../..', __FILE__
      @child.io.inherit!
      @child.start
    end

    def stop
      @child.poll_for_exit(5)
    rescue ChildProcess::TimeoutError
      @child.stop # tries increasingly harsher methods to kill the process.
    end

    def method_missing(*args)
      @child.send(*args)
    end
  end
end
