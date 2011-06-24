require 'bundler/setup'
require 'sinatra/activerecord'

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: File.expand_path('../production.db', __FILE__)
)

