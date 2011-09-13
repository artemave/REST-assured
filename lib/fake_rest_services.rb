require 'rubygems'
require 'sinatra/base'
require 'haml'
require 'sass'
require 'sinatra/static_assets'
#require 'sinatra/reloader'
require 'rack-flash'
require 'sinatra/partials'
require 'fake_rest_services/init'
require 'fake_rest_services/models/double'
require 'fake_rest_services/models/redirect'
require 'fake_rest_services/routes/double'
require 'fake_rest_services/routes/redirect'

module FakeRestServices
  class Application < Sinatra::Base
    set :environment, AppConfig[:environment]
    set :port, AppConfig[:port]

    enable :method_override

    enable :logging

    enable :sessions
    use Rack::Flash, :sweep => true

    set :public, File.expand_path('../../public', __FILE__)
    set :views, File.expand_path('../../views', __FILE__)
    set :haml, :format => :html5

    helpers Sinatra::Partials
    register Sinatra::StaticAssets

    helpers do
      def browser?
        request.user_agent =~ /Safari|Firefox|Opera|MSIE|Chrome/
      end
    end

    include DoubleRoutes
    include RedirectRoutes

    get '/css/base.css' do
      scss :base
    end

    %w{get post put delete}.each do |method|
      send method, /.*/ do
        Double.where(:fullpath => request.fullpath, :active => true, :method => method.upcase).first.try(:content) or try_redirect(request) or status 404
      end
    end

    #configure(:development) do
      #register Sinatra::Reloader
    #end

    private
      def try_redirect(request)
        r = Redirect.ordered.find do |r|
          request.fullpath =~ /#{r.pattern}/
        end

        r && redirect( "#{r.to}#{request.fullpath}" )
      end
  end
end
