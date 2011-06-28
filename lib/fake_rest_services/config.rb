require 'sinatra/activerecord'
require 'fake_rest_services/options'

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: FakeRestServices::Options.database || ':memory:'
)

ActiveRecord::Migrator.migrate(
  File.expand_path('../../../db/migrate', __FILE__)
)
