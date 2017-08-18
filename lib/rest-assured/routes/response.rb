module RestAssured
  class Response

    def self.perform(app)
      request = app.request
      if d = Models::Double.where(:fullpath => request.fullpath, :active => true, :verb => request.request_method).first
        return_double app, d
      elsif redirect_url = Models::Redirect.find_redirect_url_for(request.fullpath)
        if d = Models::Double.where(:fullpath => redirect_url, :active => true, :verb => request.request_method).first
          return_double app, d
        else
          app.redirect redirect_url
        end
      else
        app.status 404
      end
    end

    def self.find_matching_double(method, fullpath)
      active_doubles_for_verb = Models::Double.where(:active => true, :verb => method)
      active_doubles_for_verb.select {|d| !d.fullpath.blank? && d.fullpath == fullpath}.sort_by { |d| d[:id] }.last ||
          active_doubles_for_verb.select {|d| !d.pathpattern.blank? && Regexp.new(d.pathpattern).match(fullpath)}.sort_by { |d| d[:id] }.last
    end

    def self.return_double(app, d)
      request = app.request
      request.body.rewind
      body = request.body.read #without temp variable ':body = > body' is always nil. mistery
      env  = request.env.except('rack.input', 'rack.errors', 'rack.logger')

      d.requests.create!(:rack_env => env.to_json, :body => body, :params => request.params.to_json)

      sleep d.delay

      app.headers d.response_headers
      app.body d.content
      app.status d.status
    end

  end
end
