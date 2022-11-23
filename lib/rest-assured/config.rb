require 'logger'

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
      @user_conf = opts
      AppConfig.merge!(@user_conf)

      AppConfig.logfile ||= if AppConfig.environment == 'production'
                              './rest-assured.log'
                            else
                              File.expand_path("../../../#{AppConfig.environment}.log", __FILE__)
                            end
      build_db_config
      build_ssl_config
    end

    def self.included(klass)
      init_logger
      setup_db

      klass.set :port, AppConfig.port
      klass.set :environment, AppConfig.environment

      klass.enable :logging
      klass.use Rack::CommonLogger, AppConfig.logger
    end

    def self.to_cmdargs
      @user_conf.inject([]) do |acc, (k,v)|
        if v == true
          acc << "--#{k}"
        elsif v.is_a?(String) || v.is_a?(Integer)
          acc << "--#{k}" << v.to_s
        else
          acc
        end
      end
    end

    private

      def self.setup_db
        require 'active_record'
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
        migrate = lambda { ActiveRecord::MigrationContext.new(File.expand_path('../../../db/migrate', __FILE__)).migrate }
        silence_stdout = lambda do |&thing|
          original_stdout = $stdout
          $stdout = File.open(File::NULL, "w")
          thing.call
          $stdout = original_stdout
        end

        if AppConfig[:environment] == 'production'
          silence_stdout.call(&migrate)
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
                                adapter = RUBY_PLATFORM == "java" ? 'jdbcsqlite3' : 'sqlite3'
                                {
                                  :adapter => adapter,
                                  :database => AppConfig.database || default_database,
                                  :timeout => 1000
                                }
                              elsif AppConfig.adapter =~ /postgres|mysql/i
                                adapter = $&.downcase

                                default_database = if AppConfig.environment != 'production'
                                                     "rest_assured_#{AppConfig.environment}"
                                                   else
                                                     'rest_assured'
                                                   end

                                opts = {
                                  :adapter  => 'postgresql',
                                  :username => AppConfig.dbuser || 'root',
                                  :database => AppConfig.database || default_database,
                                  :pool     => 20
                                }
                                if adapter =~ /mysql/
                                  adapter = RUBY_PLATFORM == "java" ? 'jdbcmysql' : 'mysql2'
                                  opts.merge!(
                                    :adapter   => adapter,
                                    :reconnect => true,
                                    :pool      => 20
                                  )
                                  opts[:socket] = AppConfig.dbsocket if AppConfig.dbsocket
                                end

                                opts[:password] = AppConfig.dbpass if AppConfig.dbpass
                                opts[:host]     = AppConfig.dbhost if AppConfig.dbhost
                                opts[:port]     = AppConfig.dbport if AppConfig.dbport
                                opts[:encoding] = AppConfig.dbencoding if AppConfig.dbencoding
                                opts
                              else
                                raise "Unsupported db adapter '#{AppConfig.adapter}'. Valid adapters are sqlite and mysql"
                              end
      end

      def self.build_ssl_config
        AppConfig.ssl ||= false
        AppConfig.ssl_cert ||= File.expand_path('../../../ssl/localhost.crt', __FILE__)
        AppConfig.ssl_key ||= File.expand_path('../../../ssl/localhost.key', __FILE__)
      end
  end
end


