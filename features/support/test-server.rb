require 'net/http'

# This is only needed till I get ActiveResource going through rack-test
class TestServer
  @pid_file = "./rest-assured.pid"

  def self.start(opts = {})
    @server_port = opts[:port] || 9876

    print 'Starting TestServer server... '

    p = Process.fork do
      if get_pid
        print "\nPrevious TestServer instance appears to be running. Will be using it."
      else
        Process.exec("bundle exec rest-assured -p #{@server_port}")
      end
    end

    Process.detach(p)
    puts 'Done.'
  end

  def self.stop
    print 'Shutting down TestServer server... '
    Process.kill('TERM', get_pid.to_i) rescue puts( "Failed to kill TestServer server: #{$!}" )
    puts 'Done.'
  end

  def self.server_address
    "http://localhost:#{@server_port}"
  end

  def self.up?
    Net::HTTP.new('localhost', @server_port).head('/')
    true
  rescue Errno::ECONNREFUSED
    false
  end

  private

    def self.get_pid
      `ps -eo pid,args`.split("\n").grep( /rest-assured -p #{@server_port}/ ).map{|p| p.split.first }.first
    end
end
