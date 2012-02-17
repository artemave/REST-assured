module RestAssured
  module Utils
    class Subprocess
      attr_reader :pid

      def initialize
        @pid = Kernel.fork do
          trap('USR1') do
            Process.kill('TERM', Process.pid) # unlike 'exit' this one is NOT being intercepted by Webrick
          end

          at_exit { exit! }

          begin
            yield
          rescue => e
            if defined?(EventMachine) && e.is_a?(EventMachine::ConnectionNotBound)
              retry
            end
            puts "#{self} has raised #{e.inspect}:"
            puts e.backtrace.join("\n")
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
        Process.kill('USR1', @pid) rescue Errno::ESRCH # no such process
      end
    end
  end
end
