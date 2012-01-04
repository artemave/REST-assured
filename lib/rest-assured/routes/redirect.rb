module RestAssured
  module RedirectRoutes
    def self.included(router)
      router.get '/redirects' do
        @redirects = Models::Redirect.ordered
        haml :'redirects/index'
      end

      router.get '/redirects/new' do
        @redirect = Models::Redirect.new
        haml :'redirects/new'
      end

      router.post '/redirects' do
        @redirect = Models::Redirect.create(params['redirect'] || { :pattern => params['pattern'], :to => params['to'] })

        if browser?
          if @redirect.errors.blank?
            flash[:notice] = "Redirect created"
            redirect '/redirects'
          else
            flash.now[:error] = "Crumps! " + @redirect.errors.full_messages.join("; ")
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
        @redirect = Models::Redirect.find(id)
        haml :'redirects/edit'
      end

      router.put %r{/redirects/(\d+)} do |id|
        @redirect = Models::Redirect.find(id)

        @redirect.update_attributes(params['redirect'])

        if @redirect.save
          flash[:notice] = 'Redirect updated'
          redirect '/redirects'
        else
          flash[:error] = 'Crumps! ' + @redirect.errors.full_messages.join("\n")
          haml :'redirects/edit'
        end
      end

      router.put '/redirects/reorder' do
        if params['redirect']
          if Models::Redirect.update_order(params['redirect'])
            'Changed'
          else
            'Crumps! It broke'
          end
        end
      end

      router.delete %r{/redirects/(\d+)} do |id|
        if Models::Redirect.destroy(id)
          flash[:notice] = 'Redirect deleted'
          redirect '/redirects'
        end
      end

      router.delete '/redirects/all' do
        status Models::Redirect.delete_all ? 200 : 500
      end
    end
  end
end
