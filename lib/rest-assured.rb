require 'rubygems'
require 'sinatra/base'
require 'haml'
require 'rack-flash'
require 'sinatra/partials'
require 'active_record'
require 'rest-assured/init'
require 'rest-assured/models/double'
require 'rest-assured/models/redirect'
require 'rest-assured/models/request'
require 'rest-assured/routes/double'
require 'rest-assured/routes/redirect'
require 'rest-assured/routes/response'

module RestAssured
  class Application < Sinatra::Base
    set :environment, AppConfig[:environment]
    set :port, AppConfig[:port]

    enable :method_override

    Logger.class_eval do
      alias_method :write, :<<
    end
    enable :logging
    use Rack::CommonLogger, $app_logger

    enable :sessions
    use Rack::Flash, :sweep => true

    set :public_folder, File.expand_path('../../public', __FILE__)
    set :views, File.expand_path('../../views', __FILE__)
    set :haml, :format => :html5

    helpers Sinatra::Partials

    helpers do
      def browser?
        request.user_agent =~ /Safari|Firefox|Opera|MSIE|Chrome/
      end
    end

    include DoubleRoutes
    include RedirectRoutes

    #before do
      #ActiveRecord::Base.clear_reloadable_connections!
      #ActiveRecord::Base.clear_cache! 
    #end

    %w{get post put delete}.each do |verb|
      send verb, /.*/ do
        Response.perform(self)
      end
    end
  end
end
