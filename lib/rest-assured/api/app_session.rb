require 'rest-assured/utils/subprocess'
require 'rest-assured/api/app_runner'

module RestAssured
  class AppSession
    def initialize
      @child = Utils::Subprocess.new do
        AppRunner.run!
      end
    end

    def method_missing(*args)
      @child.send(*args)
    end
  end
end
