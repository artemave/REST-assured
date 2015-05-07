require 'childprocess'
require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../../lib/rest-assured/api/app_session', __FILE__)

module RestAssured
  describe AppSession do
    let(:child) do
      double(io: double, :cwd= => double)
    end

    it 'starts application in childprocess' do
      cmdargs = %w{-d :memory: -p 6666}
      Config.stub(:to_cmdargs => cmdargs)

      ChildProcess.should_receive(:build).with('bin/rest-assured', *cmdargs).and_return(child)

      expect(child).to receive(:cwd=)

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
