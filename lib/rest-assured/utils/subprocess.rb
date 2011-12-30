module RestAssured
  module Utils
    class Subprocess
      attr_reader :pid

      def initialize
        @pid = Kernel.fork do
          at_exit{ exit! }
          begin
            yield
          rescue SignalException
            puts "being killed from parent..."
          rescue => e
            puts "#{self} has raised #{e.inspect}. Shutting down parent..."
            Process.kill('TERM', Process.ppid)
          else
            puts "#{self} has quit. Shutting down parent..."
            Process.kill('TERM', Process.ppid)
          end
        end

        Process.detach(@pid)
        at_exit { stop }
      end

      def alive?
        Process.kill(0, @pid)
        true
      rescue Errno::ESRCH
        false
      end

      def stop
        Process.kill('TERM', @pid) rescue Errno::ESRCH # no such process
      end
    end
  end
end
