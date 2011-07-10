require 'sinatra/base'
require 'haml'
require 'sass'
#require 'sinatra/static_assets'
require 'fake_rest_services/init'
require 'fake_rest_services/models/fixture'
require 'fake_rest_services/models/redirect'
require 'fake_rest_services/routes/fixture'
require 'fake_rest_services/routes/redirect'

module FakeRestServices
  class Application < Sinatra::Base
    enable :logging
    set :port, AppConfig[:port]
    set :public, File.expand_path('../../public', __FILE__)
    set :haml, format: :html5

    #register Sinatra::StaticAssets

    include FixtureRoutes
    include RedirectRoutes

    get '/css/base.css' do
      scss :base
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
