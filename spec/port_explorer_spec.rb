require File.expand_path('../spec_helper', __FILE__)
require File.expand_path('../../lib/rest-assured/utils/port_explorer', __FILE__)

module RestAssured::Utils
  describe PortExplorer do
    it 'finds unused tcp port'

    it 'knows if port is in use' do
      port = 4566
      Net::HTTP.should_receive(:new).with('localhost', port).and_raise(Errno::ECONNREFUSED)

      PortExplorer.port_in_use?(port).should == true
    end

    it 'knows that port is NOT in use' do
      port = 4566
      Net::HTTP.should_receive(:new).with('localhost', port).and_return(connection = double.as_null_object)

      PortExplorer.port_in_use?(port).should == false
    end
  end
end
