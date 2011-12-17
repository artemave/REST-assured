require 'net/http'
require 'childprocess'

# This is only needed till I get ActiveResource going through rack-test
class TestServer
  def self.start(opts = {})
    @server_port = opts[:port] || 9876
    db_user = opts[:db_user] || 'root'

    print "Starting TestServer server... "

    @child = ChildProcess.build("bundle exec rest-assured -p #@server_port -a mysql -u #{db_user}")
    @child.start

    puts 'Done.'
  end

  def self.stop
    print 'Shutting down TestServer server... '
    @child.stop
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
end
