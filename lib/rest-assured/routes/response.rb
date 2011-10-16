class Response
  def self.perform(app)
    request = app.request

    if d = Double.where(:fullpath => request.fullpath, :active => true, :verb => request.request_method).first
      app.body d.content
    elsif r = Redirect.ordered.find { |r| request.fullpath =~ /#{r.pattern}/ }
      app.redirect( "#{r.to}#{request.fullpath}" )
    else
      app.status 404
    end
  end
end
