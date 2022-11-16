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
      allow(Config).to receive_messages(:to_cmdargs => cmdargs)

      expect(ChildProcess).to receive(:build).with('bin/rest-assured', *cmdargs).and_return(child)

      expect(child).to receive(:cwd=)

      state = ''
      expect(child.io).to receive(:inherit!) do
        expect(state).not_to eq('started')
      end
      expect(child).to receive(:start) do
        state << 'started'
      end

      AppSession.new
    end

  end
end
