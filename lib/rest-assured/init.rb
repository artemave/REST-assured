require 'active_record'
require 'active_record/leak_connection_patch'
require 'rest-assured/config'
require 'logger'
require 'active_support/core_ext/kernel/reporting'

$app_logger = Logger.new(AppConfig[:log_file])
$app_logger.level = Logger::DEBUG

# active record logging is purely internal
# thus disabling it for production
ActiveRecord::Base.logger = if AppConfig[:environment] == 'production'
                              Logger.new(test('e', '/dev/null') ? '/dev/null' : 'NUL:')
                            else
                              $app_logger
                            end

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => AppConfig[:database],
  :timeout => 10000
)

migrate = lambda { ActiveRecord::Migrator.migrate(File.expand_path('../../../db/migrate', __FILE__)) }

if AppConfig[:environment] == 'production'
  silence(:stdout, &migrate)
else
  migrate.call
end
