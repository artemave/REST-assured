module Sinatra
  class Base
    class << self
      def run!(options={})
        set options
        handler      = detect_rack_handler
        handler_name = handler.name.gsub(/.*::/, '')
        # handler specific options use the lower case handler name as hash key, if present
        handler_opts = begin
                         send(handler_name.downcase)
                       rescue NoMethodError
                         {}
                       end
        puts "== Sinatra/#{Sinatra::VERSION} has taken the stage " +
          "on #{port} for #{environment} with backup from #{handler_name}" unless handler_name =~/cgi/i
        handler.run self, handler_opts.merge(:Host => bind, :Port => port) do |server|
          [:INT, :TERM].each { |sig| trap(sig) { quit!(server, handler_name) } }
          set :running, true
        end
      rescue Errno::EADDRINUSE => e
        puts "== Someone is already performing on port #{port}!"
      end
    end
  end
end
