require File.expand_path('../spec_helper', __FILE__)
require File.expand_path('../../lib/rest-assured/api', __FILE__)
require File.expand_path('../../lib/rest-assured/port_explorer', __FILE__)
require File.expand_path('../../lib/rest-assured/satellite_process', __FILE__)

describe 'ruby api' do
  describe RestAssured::Server do
    let(:server) { RestAssured::Server.new(port_explorer) }
    let(:port_explorer) { PortExplorer.new }

    before do
      port_explorer.stub(:free_tcp_port => 1234)

      Kernel.stub(:system)
      SatelliteProcess.stub(:new) do |to_process|
        to_process.call
      end
    end

    context 'when starts' do
      it 'launches rest-assured executable' do
        Kernel.should_receive(:system).with(/^bundle exec rest-assured/)
        server.start
      end

      it 'uses free port' do
        Kernel.should_receive(:system).with(/ -p 1234/)
        server.start
      end

      it 'uses inmemory database' do
        Kernel.should_receive(:system).with(/ -d :memory:/)
        server.start
      end

      it 'spawns satellite process (check out satellite_process_spec for what it is)' do
        SatelliteProcess.should_receive(:new)
        server.start
      end
    end

    it 'knows what port it is running on' do
      server.port.should be nil
      server.start
      server.port.should == 1234
    end

  end
end
