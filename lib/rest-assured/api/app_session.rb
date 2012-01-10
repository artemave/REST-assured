require 'rest-assured/utils/subprocess'
require 'rest-assured/utils/drb_sniffer'
require 'rest-assured/api/app_runner'
require 'childprocess'

module RestAssured
  class AppSession
    include Utils::DrbSniffer

    def initialize
      @child = if drb?
                 child = ChildProcess.build('rest-assured', *Config.to_cmdargs)
                 child.io.inherit!
                 child.start
                 child
               else
                 Utils::Subprocess.new do
                   AppRunner.run!
                 end
               end
    end

    def method_missing(*args)
      @child.send(*args)
    end
  end
end
