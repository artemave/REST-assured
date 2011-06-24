require 'bundler'
Bundler::GemHelper.install_tasks
require_relative './lib/fake_rest_services/config'
require 'rake'
require 'sinatra/activerecord/rake'

task default: :post_install_hook

task :post_install_hook do
  Rake::Task['db:migrate'].invoke
end
