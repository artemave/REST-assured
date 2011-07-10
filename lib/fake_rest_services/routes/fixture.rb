module FakeRestServices
  module FixtureRoutes
    def self.included(router)
      router.get '/fixtures' do
        @fixtures = Fixture.all
        haml :'fixtures/index'
      end

      router.post '/fixtures' do
        Fixture.create(url: params['url'], content: params['content'])
      end

      router.delete '/fixtures/all' do
        Fixture.delete_all
      end
    end
  end
end
