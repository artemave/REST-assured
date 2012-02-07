require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../../lib/rest-assured/api/app_runner', __FILE__)

module RestAssured
  describe AppRunner do
    before do
      Application.stub(:run!)
      Config.stub(:included)
    end

    it 'requires Application' do
      Kernel.should_receive(:require).with('rest-assured/application').and_return(true)
      AppRunner.run!
    end
    it 'reloads config if Application has already been loaded' do
      Kernel.stub(:require).and_return(false)

      Application.should_receive(:send).with(:include, Config)
      AppRunner.run!
    end
    it 'runs Application' do
      Application.should_receive(:run!)
      AppRunner.run!
    end
  end
end

