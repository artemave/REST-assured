require 'active_record'
#require 'active_record/leaky_connections_patch'
#require 'active_record/sqlite_transaction_hell_patch'
require 'rest-assured/config'
require 'logger'
require 'active_support/core_ext/kernel/reporting'

module RestAssured
  class Init
    def self.init!
      setup_logger
      connect_db
      migrate_db
    end

    private
      def self.build_db_config
        if AppConfig[:adapter] =~ /sqlite/i
          AppConfig[:database] ||= if AppConfig[:environment] == 'production'
                                     './rest-assured.db'
                                   else
                                     File.expand_path("../../../db/#{AppConfig[:environment]}.db", __FILE__)
                                   end
          {
            :adapter => 'sqlite3',
            :database => AppConfig[:database]
          }
        elsif AppConfig[:adapter] =~ /mysql/i
          AppConfig[:database] ||= if AppConfig[:environment] != 'production'
                                     "rest_assured_#{AppConfig[:environment]}"
                                   else
                                     'rest_assured'
                                   end
          AppConfig[:db_user] ||= 'root'
          AppConfig[:db_password] ||= 'root'

          {
            :adapter => 'mysql',
            :reconnect => true,
            :user => AppConfig[:db_user],
            :password => AppConfig[:db_password],
            :database => AppConfig[:database]
          }
        else
          raise "Unsupported db adapter '#{AppConfig[:adapter]}'. Valid adapters are sqlite and mysql"
        end
      end

      def self.connect_db
        config = build_db_config
        ActiveRecord::Base.establish_connection config
      end

      def self.migrate_db
        migrate = lambda { ActiveRecord::Migrator.migrate(File.expand_path('../../../db/migrate', __FILE__)) }

        if AppConfig[:environment] == 'production' && Kernel.respond_to?(:silence)
          silence(:stdout, &migrate)
        else
          migrate.call
        end
      end

      def self.setup_logger
        $app_logger = Logger.new(AppConfig[:log_file])
        $app_logger.level = Logger::DEBUG

        # active record logging is purely internal
        # thus disabling it for production
        ActiveRecord::Base.logger = if AppConfig[:environment] == 'production'
                                      Logger.new(test('e', '/dev/null') ? '/dev/null' : 'NUL:')
                                    else
                                      $app_logger
                                    end
      end
  end

  Init.init!
end
