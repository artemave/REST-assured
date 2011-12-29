module RestAssured
  module Utils
    class Subprocess
      def initialize(&block)
        @pid = Kernel.fork &block
        Process.detach(@pid)
      end

      def alive?
        begin
          Process.kill(0, @pid)
          true
        rescue Errno::ESRCH
          false
        end 
      end
    end
  end
end
