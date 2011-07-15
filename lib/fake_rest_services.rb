require 'sinatra/base'
require 'sinatra/static_assets'
require 'sinatra/reloader'
require 'fake_rest_services/init'
require 'fake_rest_services/models/fixture'
require 'fake_rest_services/models/redirect'
require 'fake_rest_services/web_interface'

module FakeRestServices
  class Application < Sinatra::Base
    set :environment, AppConfig[:environment]
    enable :logging
    set :port, AppConfig[:port]
    register Sinatra::StaticAssets

    configure(:development) do
      register Sinatra::Reloader
    end

    delete '/fixtures/all' do
      Fixture.delete_all
    end

    post '/redirects' do
      Redirect.create(pattern: params['pattern'], to: params['to'])
    end

    get /.*/ do
      Fixture.where(url: request.fullpath).last.try(:content) or try_redirect(request) or status 404
    end

    private
      def try_redirect(request)
        r = Redirect.all.find do |r|
          request.fullpath =~ /#{r.pattern}/
        end

        r && redirect( "#{r.to}#{request.fullpath}" )
      end
  end
end

