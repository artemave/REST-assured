require File.expand_path('../spec_helper', __FILE__)
require File.expand_path('../../lib/rest-assured/utils/drb_sniffer', __FILE__)

module RestAssured::Utils
  describe DrbSniffer do
    let :extendee do
      o = Object.new
      o.extend(DrbSniffer)
      o
    end

    it 'lets extendee to find out whether current process is using drb' do
      extendee.drb?.should == true
    end
    it 'lets extendee to find out whether current process is NOT using drb'
  end
end

