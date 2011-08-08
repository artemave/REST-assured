module FakeRestServices
  module FixtureRoutes
    def self.included(router)
      router.get '/' do
        redirect to('/fixtures')
      end

      router.get '/fixtures' do
        @fixtures = Fixture.all
        haml :'fixtures/index'
      end

      router.get '/fixtures/new' do
        @fixture = Fixture.new
        haml :'fixtures/new'
      end

      router.post '/fixtures' do
        @fixture = Fixture.create(url: params['url'], content: params['content'], description: params['description'])

        if params['_ui']
          if @fixture.errors.blank?
            flash[:notice] = "Fixture created"
            redirect '/fixtures'
          else
            flash[:error] = "Errors!"
            haml :'fixtures/new'
          end
        end
      end

      router.delete '/fixtures/all' do
        Fixture.delete_all
      end
    end
  end
end
