require 'sinatra/activerecord'
require 'fake_rest_services/config'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => AppConfig[:database]
)

ActiveRecord::Migrator.migrate(
  File.expand_path('../../../db/migrate', __FILE__)
)
