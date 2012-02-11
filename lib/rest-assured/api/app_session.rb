require 'rest-assured/utils/subprocess'
require 'rest-assured/utils/drb_sniffer'
require 'rest-assured/api/app_runner'
require 'childprocess'

module RestAssured
  class AppSession
    include Utils::DrbSniffer

    def initialize
      @child = if not running_in_spork? and Process.respond_to?(:fork)
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

    def alive?
      @child.alive?
    rescue Errno::ECHILD
      false
    end

    def method_missing(*args)
      @child.send(*args)
    end
  end
end
