require 'sinatra/activerecord'
require 'fake_rest_services/options'
require 'rake'
require 'sinatra/activerecord/rake'

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: FakeRestServices::Options.database || ':memory:'
)
Rake::Task['db:migrate'].reenable
Rake::Task['db:migrate'].invoke
