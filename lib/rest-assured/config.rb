require 'logger'
require 'active_record'
require 'active_support/core_ext/kernel/reporting'

module RestAssured
  module Config
    class ConfigHash < Hash
      def initialize(default_values = {})
        super()
        self.merge!(default_values)
      end

      def method_missing(meth, *args)
        meth = meth.to_s

        if meth.sub!(/=/, '')
          self[meth.to_sym] = args.first
        else
          self[meth.to_sym]
        end
      end
    end

    ::AppConfig = ConfigHash.new({
      :port => 4578,
      :environment => ENV['RACK_ENV'] || 'production',
      :adapter => 'sqlite'
    })

    # this is meant to be called prior to include
    def self.build(opts = {})
      AppConfig.merge!(opts)

      AppConfig.logfile ||= if AppConfig.environment == 'production'
                              './rest-assured.log'
                            else
                              File.expand_path("../../../#{AppConfig.environment}.log", __FILE__)
                            end
      build_db_config
    end

    def self.included(klass)
      init_logger
      setup_db

      klass.set :port, AppConfig.port
      klass.set :environment, AppConfig.environment

      klass.enable :logging
      klass.use Rack::CommonLogger, AppConfig.logger
    end

    private

      def self.setup_db
        setup_db_logging
        connect_db
        migrate_db
      end

      def self.init_logger
        Logger.class_eval do
          alias_method :write, :<<
        end

        AppConfig.logger = Logger.new(AppConfig.logfile)
        AppConfig.logger.level = Logger::DEBUG
      end

      def self.setup_db_logging
        raise "Init logger first" unless AppConfig.logger

        # active record logging is purely internal
        # thus disabling it for production
        ActiveRecord::Base.logger = if AppConfig.environment == 'production'
                                      Logger.new(dev_null)
                                    else
                                      AppConfig.logger
                                    end
      end

      def self.dev_null
        test('e', '/dev/null') ? '/dev/null' : 'NUL:'
      end

      def self.connect_db
        ActiveRecord::Base.establish_connection AppConfig.db_config
      end

      def self.migrate_db
        migrate = lambda { ActiveRecord::Migrator.migrate(File.expand_path('../../../db/migrate', __FILE__)) }

        if AppConfig[:environment] == 'production' && Kernel.respond_to?(:silence)
          silence(:stdout, &migrate)
        else
          migrate.call
        end
      end

      def self.build_db_config
        AppConfig.db_config = if AppConfig.adapter =~ /sqlite/i
                                default_database = if AppConfig.environment == 'production'
                                                     './rest-assured.db'
                                                   else
                                                     File.expand_path("../../../db/#{AppConfig.environment}.db", __FILE__)
                                                   end
                                {
                                  :adapter => 'sqlite3',
                                  :database => AppConfig.database || default_database
                                }
                              elsif AppConfig.adapter =~ /mysql/i
                                default_database = if AppConfig.environment != 'production'
                                                     "rest_assured_#{AppConfig.environment}"
                                                   else
                                                     'rest_assured'
                                                   end

                                opts = {
                                  :adapter => 'mysql',
                                  :reconnect => true,
                                  :user => AppConfig.user || 'root',
                                  :database => AppConfig.database || default_database
                                }

                                opts[:password] = AppConfig.dbpass if AppConfig.dbpass
                                opts[:host] = AppConfig.dbhost if AppConfig.dbhost
                                opts[:port] = AppConfig.dbport if AppConfig.dbport
                                opts[:encoding] = AppConfig.dbencoding if AppConfig.dbencoding
                                opts[:socket] = AppConfig.dbsocket if AppConfig.dbsocket
                                opts
                              else
                                raise "Unsupported db adapter '#{AppConfig.adapter}'. Valid adapters are sqlite and mysql"
                              end
      end
  end
end


