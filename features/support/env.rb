$:.push File.expand_path('../../../lib', __FILE__)
require 'rspec/expectations'
require 'rack/test'
require 'rake'
require 'sinatra/activerecord/rake'
require 'fake_rest_services'

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ':memory:'
)

Rake::Task['db:migrate'].invoke

World(Rack::Test::Methods)

def app
  FakeRestServices::Application
end
