require 'sinatra/base'
require 'fake_rest_services/config'
require 'fake_rest_services/models/fixture'

module FakeRestServices
  class Application < Sinatra::Base
    post '/fixtures' do
      Fixture.create(url: params['url'], content: params['content']) and status 200
    end

    delete '/fixtures/all' do
      Fixture.destroy_all and status 200
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
