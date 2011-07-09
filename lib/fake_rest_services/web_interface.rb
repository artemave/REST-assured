require 'haml'
require 'sass'

module FakeRestServices
  module WebInterface
    def self.included(router)
      router.set :haml, format: :html5

      router.get '/fixtures' do
        @fixtures = Fixture.all
        haml :'fixtures/index'
      end

      router.get '/stylesheet.css' do
        scss :stylesheet
      end
    end
  end
end
