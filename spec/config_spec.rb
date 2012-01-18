require File.expand_path('../../lib/rest-assured/config', __FILE__)
require 'rack'
require 'openssl'
require 'webrick'

module RestAssured
  describe Config do
    before do
      Config.build
    end

    context 'builds config from user options' do
      #this is thoroughly covered in cucumber (since there it also serves documentation purposes)
    end

    context 'when included in Application' do
      let(:app) { mock(:app).as_null_object }

      it 'initializes logger' do
        Config.stub(:setup_db)
        logger = double(:logger).as_null_object
        AppConfig.stub(:logfile).and_return('test.log')

        Logger.should_receive(:new).with('test.log').and_return(logger)

        Config.included(app)
      end

      context 'db setup' do
        it 'connects db' do
          Config.stub(:init_logger)
          Config.stub(:migrate_db) # so it does not complain
          AppConfig.stub(:db_config).and_return('db_config')

          ActiveRecord::Base.should_receive(:establish_connection).with('db_config')

          Config.included(app)
        end

        context 'active_record logging' do
          let(:logger) { double(:logger).as_null_object }

          before do
            Config.stub(:migrate_db)
            Config.stub(:connect_db)
          end

          it 'is silenced in production' do
            AppConfig.stub(:environment).and_return('production')
            Logger.should_receive(:new).with(Config.dev_null).and_return(logger)

            ActiveRecord::Base.should_receive(:logger=).with(logger)

            Config.setup_db
          end

          it 'is set to app logger for non production' do
            AppConfig.stub(:environment).and_return('test')
            AppConfig.stub(:logger).and_return(logger)

            ActiveRecord::Base.should_receive(:logger=).with(logger)

            Config.setup_db
          end
        end

        it 'runs migrations' do
          Config.stub(:connect_db) # so it does not complain

          ActiveRecord::Migrator.should_receive(:migrate)

          Config.setup_db
        end
      end

      it 'sets up environment' do
        app.should_receive(:set).with(:environment, AppConfig.environment)
        Config.included(app)
      end

      it 'sets up port' do
        app.should_receive(:set).with(:port, AppConfig.port)
        Config.included(app)
      end

      it 'connects logger to application' do
        logger = double(:logger).as_null_object
        AppConfig.stub(:logger).and_return(logger)

        app.should_receive(:enable).with(:logging)
        app.should_receive(:use).with(Rack::CommonLogger, logger)

        Config.included(app)
      end

      context 'when ssl true' do
        before do
          AppConfig.stub(:ssl).and_return(true)
        end

        it 'makes sure only webrick can be used' do
          app.should_receive(:set).with(:server, %[webrick])
          Config.included(app)
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
          Config.included(app)
        end

        it 'does all that only if ssl true' do
          AppConfig.stub(:ssl).and_return(false)

          app.should_not_receive(:set).with(:webrick, anything)
          Config.included(app)
        end
      end
    end
    
    context 'cmd args array conversion' do
      it 'converts true values in form of "value" => ["--#{value}"]' do
        Config.build(:ssl => true)
        Config.to_cmdargs.should == ['--ssl']
      end

      it 'does not include false values' do
        Config.build(:ssl => false)
        Config.to_cmdargs.should_not include('--ssl')
      end

      it 'converts key value pairs in form of "key => value" => ["--#{key}", "value"]' do
        Config.build(:port => 1234, :database => ':memory:')
        Config.to_cmdargs.should == ['--port', '1234', '--database', ':memory:']
      end
    end
  end
end
