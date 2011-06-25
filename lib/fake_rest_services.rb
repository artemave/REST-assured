require 'sinatra/base'
require 'fake_rest_services/config'
require 'fake_rest_services/models/fixture'
require 'fake_rest_services/models/redirect'

module FakeRestServices
  class Application < Sinatra::Base
    post '/fixtures' do
      Fixture.create(url: params['url'], content: params['content']) and status 200
    end

    delete '/fixtures/all' do
      Fixture.destroy_all and status 200
    end

    post '/redirects' do
      Redirect.create(pattern: params['pattern'], to: params['to'])
    end

    get /.*/ do
      Fixture.where(url: request.fullpath).last.try(:content) or perform_redirect(request) or status 404
    end

    private
      def perform_redirect(request)
        r = Redirect.all.find do |r|
          request.fullpath =~ /#{r.pattern}/
        end

        r && redirect( "#{r.to}#{request.fullpath}" )
      end
  end
end
