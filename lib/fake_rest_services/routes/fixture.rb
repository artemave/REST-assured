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
        @fixture = Fixture.create(params['fixture'] || { url: params['url'], content: params['content'], description: params['description'] })

        if browser?
          if @fixture.errors.blank?
            flash[:notice] = "Fixture created"
            redirect '/fixtures'
          else
            flash[:error] = "Crumps! " + @fixture.errors.full_messages.join("; ")
            haml :'fixtures/new'
          end
        else
          if @fixture.errors.present?
            status 400
            body @fixture.errors.full_messages.join("\n")
          end
        end
      end

      router.get %r{/fixtures/(\d+)/edit} do |id|
        @fixture = Fixture.find(id)
        haml :'fixtures/edit'
      end

      router.put %r{/fixtures/(\d+)} do |id|
        @fixture = Fixture.find(id)

        if request.xhr?
          if params['active']
            @fixture.active = params['active']
            @fixture.save
            'Changed'
          end
        elsif params['fixture']
          @fixture.update_attributes(params['fixture'])

          if @fixture.save
            flash[:notice] = 'Fixture updated'
            redirect '/fixtures'
          else
            flash[:error] = 'Crumps! ' + @fixture.errors.full_messages.join("\n")
            haml :'fixtures/edit'
          end
        end
      end

      router.delete %r{/fixtures/(\d+)} do |id|
        if Fixture.destroy(id)
          flash[:notice] = 'Fixture deleted'
          redirect '/fixtures'
        end
      end

      router.delete '/fixtures/all' do
        Fixture.delete_all
      end
    end
  end
end
