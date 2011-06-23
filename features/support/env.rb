require 'rspec/expectations'
require 'rack/test'
require 'rake'
require 'sinatra/activerecord/rake'
require File.expand_path('../../../fake_api_server', __FILE__)

set :database, 'sqlite://test.db'
Rake::Task['db:migrate'].invoke

World(Rack::Test::Methods)

def app
  Sinatra::Application
end
