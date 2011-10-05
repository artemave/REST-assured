require 'sinatra/activerecord'
require 'meta_where'
require 'rest-assured/config'

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

ActiveRecord::Migrator.migrate(
  File.expand_path('../../../db/migrate', __FILE__)
)
