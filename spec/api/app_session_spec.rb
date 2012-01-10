require 'childprocess'
require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../../lib/rest-assured/api/app_session', __FILE__)
require File.expand_path('../../../lib/rest-assured/utils/drb_sniffer', __FILE__)

module RestAssured
  describe AppSession do
    context 'starts application' do
      it 'in subprocess if current process does NOT involve Drb (e.g. spork)' do
        AppSession.any_instance.stub(:drb? => false)
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

      it 'in childprocess if current process relies on Drb (e.g. using spork)' do
        AppSession.any_instance.stub(:drb? => true)
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
