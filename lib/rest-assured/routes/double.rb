require 'json'
require 'active_support/core_ext/hash/slice'

module RestAssured
  module DoubleRoutes
    def self.included(router)
      router.helpers do
        def verbs
          RestAssured::Models::Double::VERBS
        end

        def statuses
          RestAssured::Models::Double::STATUSES.sort
        end
      end

      router.get '/' do
        redirect to('/doubles')
      end

      router.get %r{^/doubles(\.json)?$} do |is_json|
        @doubles = Models::Double.all
        if not is_json
          haml :'doubles/index'
        else
          body @doubles.to_json
        end
      end

      router.get '/doubles/new' do
        @double = Models::Double.new
        haml :'doubles/new'
      end

      router.get '/doubles/:id.json' do |id|
        begin
          double = Models::Double.find(id)
          body double.to_json(:include => :requests)
        rescue ActiveRecord::RecordNotFound
          status 404
        end
      end

      router.post /^\/doubles(\.json)?$/ do
        begin
          data = request.body.read
          d = JSON.parse(data)['double']

          # fix acitve resource dumbness
          if d['response_headers'] and d['response_headers']['response_headers']
            d['response_headers'] = d['response_headers']['response_headers']
          end
        rescue
          d = params['double'] ||
            params.slice(*%w[fullpath content description verb status response_headers])
        end

        @double = Models::Double.create(d) 

        if browser?
          if @double.errors.blank?
            flash[:notice] = "Double created"
            redirect '/doubles'
          else
            flash.now[:error] = "Crumps! " + @double.errors.full_messages.join("; ")
            haml :'doubles/new'
          end
        else
          if @double.errors.present?
            status 422
            body @double.errors.to_json
          else
            body @double.to_json
          end
        end
      end

      router.get %r{/doubles/(\d+)/edit} do |id|
        @double = Models::Double.find(id)
        haml :'doubles/edit'
      end

      router.put %r{/doubles/(\d+)} do |id|
        @double = Models::Double.find(id)

        if request.xhr?
          if params['active']
            @double.active = params['active']
            @double.save
            'Changed'
          end
        elsif params['double']
          @double.update_attributes(params['double'])

          if @double.save
            flash[:notice] = 'Double updated'
            redirect '/doubles'
          else
            flash[:error] = 'Crumps! ' + @double.errors.full_messages.join("\n")
            haml :'doubles/edit'
          end
        end
      end

      router.delete %r{/doubles/(\d+)(\.json)?$} do |id, is_json|
        if Models::Double.destroy(id)
          flash[:notice] = 'Double deleted'
          redirect '/doubles' unless is_json
        end
      end

      router.delete '/doubles/all' do
        status Models::Double.delete_all ? 200 : 500
      end
    end
  end
end
