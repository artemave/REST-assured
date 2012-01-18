require 'childprocess'
require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../../lib/rest-assured/api/app_session', __FILE__)
require File.expand_path('../../../lib/rest-assured/utils/drb_sniffer', __FILE__)

module RestAssured
  describe AppSession do
    context 'current process does NOT involve Drb (e.g. spork)' do
      before do
        AppSession.any_instance.stub(:drb? => false)
      end

      it 'start application in subprocess' do
        state = ''
        Utils::Subprocess.should_receive(:new) do |&block|
          state << 'called from block'
          block.call
          state.clear
        end
        AppRunner.should_receive(:run!) do
          state.should == 'called from block'
        end

        AppSession.new
      end
    end

    context 'current process relies on Drb (e.g. spork)' do
      before do
        AppSession.any_instance.stub(:drb? => true)
      end

      it 'starts application in childprocess' do
        cmdargs = %w{-d :memory: -p 6666}
        Config.stub(:to_cmdargs => cmdargs)

        ChildProcess.should_receive(:build).with('rest-assured', *cmdargs).and_return(child = mock(:io => mock))

        state = ''
        child.io.should_receive(:inherit!) do
          state.should_not == 'started'
        end
        child.should_receive(:start) do
          state << 'started'
        end

        AppSession.new
      end

    end
  end
end
