require File.expand_path('../spec_helper', __FILE__)
require File.expand_path('../../lib/rest-assured/utils/port_explorer', __FILE__)

module RestAssured::Utils
  describe PortExplorer do
    it 'finds free tcp port' do
      free_port = PortExplorer.free_port
      expect { Net::HTTP.get('127.0.0.1', '/', free_port) }.to raise_error(Errno::ECONNREFUSED)
    end

    context 'port is taken' do
      let(:port) { PortExplorer.free_port }
      server = nil

      before :each do
        server = TCPServer.new port
      end

      after :each do
        server.close
      end

      it 'knows if port is in use' do
        Thread.new do
          loop do
            Thread.start(server.accept) do |client|
              client.puts "Hello!"
              client.close
            end
          end
        end

        expect(PortExplorer.port_free?(port)).to eq(false)
      end
    end

    it 'knows that port is free' do
      port = PortExplorer.free_port

      expect(PortExplorer.port_free?(port)).to eq(true)
    end
  end
end
