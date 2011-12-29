module RestAssured
  module Utils
    class Subprocess
      def initialize
        @pid = Kernel.fork do
          at_exit{ exit! }

          yield

          puts "#{self} has quit. Shutting down parent..."
          Process.kill('INT', Process.ppid)
        end
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

      def stop
        Process.kill('TERM', @pid) if alive?
      end
    end
  end
end
