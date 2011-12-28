require File.expand_path('../spec_helper', __FILE__)
require File.expand_path('../../lib/rest-assured/utils/port_explorer', __FILE__)

module RestAssured::Utils
  describe PortExplorer do
    it 'finds unused tcp port' do
      pending %{I don't see how to test this without basically
        reimplementing the same thing. So I am going to rely
        on the tests below (that use free_tcp_port) for the time being

        TODO try:
        lsof -i -P | grep -i "listen"
      }
    end

    it 'knows if port is in use' do
      port = PortExplorer.free_tcp_port

      Thread.new do
        TCPServer.open('127.0.0.1', port) do |serv|
          s = serv.accept
          s.puts 'Hello from test'
          s.close
        end
      end
      sleep 0.5

      PortExplorer.port_in_use?(port).should == true
    end

    it 'knows that port is NOT in use' do
      port = PortExplorer.free_tcp_port

      PortExplorer.port_in_use?(port).should == false
    end
  end
end
