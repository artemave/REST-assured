module FakeRestServices
  module RedirectRoutes
    def self.included(router)
      router.get '/redirects' do
        @redirects = Redirect.all
        haml :'redirects/index'
      end

      router.get '/redirects/new' do
        @redirect = Redirect.new
        haml :'redirects/new'
      end

      router.post '/redirects' do
        @redirect = Redirect.create(params['redirect'] || { pattern: params['pattern'], to: params['to'] })

        if browser?
          if @redirect.errors.blank?
            flash[:notice] = "Redirect created"
            redirect '/redirects'
          else
            flash[:error] = "Crumps! " + @redirect.errors.full_messages.join("; ")
            haml :'redirects/new'
          end
        else
          if @redirect.errors.present?
            status 400
            body @redirect.errors.full_messages.join("\n")
          end
        end
      end

      router.get %r{/redirects/(\d+)/edit} do |id|
        @redirect = Redirect.find(id)
        haml :'redirects/edit'
      end

      router.put %r{/redirects/(\d+)} do |id|
        @redirect = Redirect.find(id)

        if request.xhr?
          if params['active']
            @redirect.active = params['active']
            @redirect.save
            'Changed'
          end
        elsif params['redirect']
          @redirect.update_attributes(params['redirect'])

          if @redirect.save
            flash[:notice] = 'Redirect updated'
            redirect '/redirects'
          else
            flash[:error] = 'Crumps! ' + @redirect.errors.full_messages.join("\n")
            haml :'redirects/edit'
          end
        end
      end

      router.delete %r{/redirects/(\d+)} do |id|
        if Redirect.destroy(id)
          flash[:notice] = 'Redirect deleted'
          redirect '/redirects'
        end
      end

    end
  end
end
