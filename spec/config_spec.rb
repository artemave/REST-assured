require File.expand_path('../../lib/rest-assured/config', __FILE__)
require 'rack'

describe RestAssured::Config do
  it 'builds config from user options' do
    pending "this is thoroughly covered in cucumber (since there it also serves documentation purposes)"
  end

  it 'initializes logger' do
    logger = double(:logger).as_null_object
    AppConfig.stub(:logfile).and_return('test.log')

    Logger.should_receive(:new).with('test.log').and_return(logger)

    RestAssured::Config.init_logger
  end

  context 'db setup' do
    it 'connects db' do
      RestAssured::Config.stub(:migrate_db) # so it does not complain
      AppConfig.stub(:db_config).and_return('db_config')

      ActiveRecord::Base.should_receive(:establish_connection).with('db_config')

      RestAssured::Config.setup_db
    end

    context 'active_record logging' do
      let(:logger) { double(:logger).as_null_object }

      before do
        RestAssured::Config.stub(:migrate_db)
        RestAssured::Config.stub(:connect_db)
      end

      it 'is silenced in production' do
        AppConfig.stub(:environment).and_return('production')
        Logger.should_receive(:new).with(RestAssured::Config.dev_null).and_return(logger)

        ActiveRecord::Base.should_receive(:logger=).with(logger)

        RestAssured::Config.setup_db
      end

      it 'is set to app logger for non production' do
        AppConfig.stub(:environment).and_return('test')
        AppConfig.stub(:logger).and_return(logger)

        ActiveRecord::Base.should_receive(:logger=).with(logger)

        RestAssured::Config.setup_db
      end
    end

    it 'runs migrations' do
      RestAssured::Config.stub(:connect_db) # so it does not complain

      ActiveRecord::Migrator.should_receive(:migrate)

      RestAssured::Config.setup_db
    end
  end

  context 'when included in RestAssured::Application' do
    let(:app) { mock(:app).as_null_object }

    before do
      RestAssured::Config.build
    end

    it 'initializes resources' do
      RestAssured::Config.should_receive(:init_logger)
      RestAssured::Config.should_receive(:setup_db)

      RestAssured::Config.included(app)
    end

    it 'sets up environment' do
      app.should_receive(:set).with(:environment, AppConfig.environment)
      RestAssured::Config.included(app)
    end

    it 'sets up port' do
      app.should_receive(:set).with(:port, AppConfig.port)
      RestAssured::Config.included(app)
    end

    it 'connects logger' do
      logger = double(:logger).as_null_object
      AppConfig.stub(:logger).and_return(logger)

      app.should_receive(:enable).with(:logging)
      app.should_receive(:use).with(Rack::CommonLogger, logger)

      RestAssured::Config.included(app)
    end

  end
end
