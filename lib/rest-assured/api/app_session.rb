require 'rest-assured/utils/subprocess'
require 'rest-assured/utils/env_awareness'
require 'rest-assured/api/app_runner'
require 'childprocess'

module RestAssured
  class AppSession
    include Utils::EnvAwareness

    def initialize
      @child = if can_fork?
                 Utils::Subprocess.new do
                   AppRunner.run!
                 end
               else
                 child = ChildProcess.build('rest-assured', *Config.to_cmdargs)
                 child.io.inherit!
                 child.start
                 child
               end
    end

    def method_missing(*args)
      @child.send(*args)
    end
  end
end
