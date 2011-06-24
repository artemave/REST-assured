require 'sinatra/base'
require 'fake_rest_services/initialize'
require 'fake_rest_services/models/fixture'

module FakeRestServices
  class Application < Sinatra::Base
    post '/fixtures' do
      Fixture.create(url: params['url'], content: params['content'])
    end

    get /.*/ do
      Fixture.where(url: request.fullpath).last.try(:content) or redirect real_api_url(request)
    end

    private
      def real_api_url(request)
        "#{request.path_info =~ /esp-service/ ? 'http://open' : 'https://api' }.int.bbc.co.uk#{request.fullpath}"
      end
  end
end
