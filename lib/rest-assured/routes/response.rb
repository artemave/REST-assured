class Response
  def self.perform(app)
    request = app.request

    if d = Double.where(:fullpath => request.fullpath, :active => true, :verb => request.request_method).first
      request.body.rewind
      body   = request.body.read #without temp variable ':body = > body' is always nil. mistery
      env    = request.env.except('rack.input', 'rack.errors')

      d.requests.create!(:rack_env => env.to_json, :body => body, :params => request.params.to_json)

      app.body d.content
    elsif r = Redirect.ordered.find { |r| request.fullpath =~ /#{r.pattern}/ }
      app.redirect( "#{r.to}#{request.fullpath}" )
    else
      app.status 404
    end
  end
end
