require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../../lib/rest-assured/api/app_session', __FILE__)

module RestAssured
  describe AppSession do
    context 'starts application' do
      it 'in subprocess if current process does NOT involve Drb (e.g. spork)' do
        Utils::Subprocess.should_receive(:new) do |&block|
          block.call
        end
        AppRunner.should_receive(:run!)

        AppSession.new
      end

      it 'in childprocess if current process relies on Drb (e.g. using spork)'
    end
  end
end
