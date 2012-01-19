require File.expand_path('../spec_helper', __FILE__)
require File.expand_path('../../lib/rest-assured/utils/drb_sniffer', __FILE__)
require 'drb'

module RestAssured::Utils
  describe DrbSniffer do
    let :extendee do
      o = Object.new
      o.extend(DrbSniffer)
      o
    end

    context 'with DRb' do
      before do
        DRb.start_service("druby://127.0.0.1:#{PortExplorer.free_port}")
      end
      after do
        DRb.stop_service
      end

      it 'lets extendee to find out whether current process is using drb' do
        extendee.drb?.should == true
      end
    end

    context 'without DRb' do
      it 'lets extendee to find out whether current process is NOT using drb' do
        extendee.drb?.should == false
      end
    end
  end
end

