require File.expand_path('../../lib/rest-assured/config', __FILE__)
require 'rack'
require 'openssl'
require 'webrick'

describe RestAssured::Config do
  #this is thoroughly covered in cucumber (since there it also serves documentation purposes)
  #it 'builds config from user options'

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

    context 'when ssl true' do
      before do
        AppConfig.stub(:use_ssl).and_return(true)
      end

      it 'makes sure only webrick can be used' do
        app.should_receive(:set).with(:server, %[webrick])
        RestAssured::Config.included(app)
      end

      it 'sets up webrick ssl' do
        OpenSSL::X509::Certificate.stub(:new).with( File.read( AppConfig.ssl_cert ) ).and_return('ssl_cert')
        OpenSSL::PKey::RSA.stub(:new).with( File.read( AppConfig.ssl_key ) ).and_return('ssl_key')

        ssl_config = {
          :SSLEnable => true,
          :SSLCertificate => 'ssl_cert',
          :SSLPrivateKey  => 'ssl_key',
          :SSLCertName => [ ["CN", WEBrick::Utils::getservername] ],
          :SSLVerifyClient => OpenSSL::SSL::VERIFY_NONE 
        }

        app.should_receive(:set).with(:webrick, hash_including(ssl_config))
        RestAssured::Config.included(app)
      end

      it 'does all that only if ssl true' do
        AppConfig.stub(:use_ssl).and_return(false)
        
        app.should_not_receive(:set).with(:webrick, anything)
        RestAssured::Config.included(app)
      end
    end
  end
end
