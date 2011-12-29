require File.expand_path('../spec_helper', __FILE__)
require File.expand_path('../../lib/rest-assured/utils/port_explorer', __FILE__)

module RestAssured::Utils
  describe PortExplorer do
    it 'finds free tcp port' do
      free_port = PortExplorer.free_port
      lambda { Net::HTTP.get('127.0.0.1', '/', free_port) }.should raise_error(Errno::ECONNREFUSED)
    end

    it 'knows if port is in use' do
      port = PortExplorer.free_port

      Thread.new do
        TCPServer.open('127.0.0.1', port) do |serv|
          s = serv.accept
          s.puts 'Hello from test'
          s.close
        end
      end
      sleep 0.5

      PortExplorer.port_free?(port).should == false
    end

    it 'knows that port is free' do
      port = PortExplorer.free_port

      PortExplorer.port_free?(port).should == true
    end
  end
end
