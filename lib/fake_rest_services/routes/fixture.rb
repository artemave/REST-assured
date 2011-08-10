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

        if browser?
          if @fixture.errors.blank?
            flash[:notice] = "Fixture created"
            redirect '/fixtures'
          else
            flash[:error] = "Errors! " + @fixture.errors.full_messages.join("; ")
            haml :'fixtures/new'
          end
        else
          if @fixture.errors.present?
            status 400
            body @fixture.errors.full_messages.join("\n")
          end
        end
      end

      router.delete '/fixtures/all' do
        Fixture.delete_all
      end
    end
  end
end
