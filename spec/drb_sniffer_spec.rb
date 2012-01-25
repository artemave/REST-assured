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

    context 'cucumber' do
      around do |example|
        argv = ARGV.clone
        example.run
        ARGV.clear.push(argv).flatten!
      end

      before do
        RSpec.stub_chain('configuration.drb').and_raise(NameError)
      end

      it 'lets extendee to find out whether current process is using drb' do
        ARGV.delete_if {|a| a =~ /--drb/}
        extendee.drb?.should == false
      end

      it 'lets extendee to find out whether current process is NOT using drb' do
        ARGV << '--drb'
        extendee.drb?.should == true
      end
    end

    context 'rspec' do
      it 'lets extendee to find out whether current process is using drb' do
        RSpec.stub_chain('configuration.drb').and_return(true)
        extendee.drb?.should == true
      end

      it 'lets extendee to find out whether current process is NOT using drb' do
        RSpec.stub_chain('configuration.drb').and_return(false)
        extendee.drb?.should == false
      end
    end
  end
end

