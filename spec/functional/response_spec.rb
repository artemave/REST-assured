require File.expand_path('../../spec_helper', __FILE__)
require 'rest-assured/routes/response'

describe Response do
  [:get, :post, :put, :delete].each do |verb|
    it "processes an unknown request" do

      Response.should_receive(:perform).with(an_instance_of(RestAssured::Application))
      send verb, '/some/path'
    end
  end

  let(:request) { double('Request', :request_method => 'GET', :fullpath => '/api') }
  let(:rest_assured_app) { double('App', :request => request) }

  it "returns double content if an active one found with the same fullpath and the same method as request" do
    d = Double.create :fullpath => '/some/path', :content => 'content' 
    request.stub(:fullpath).and_return(d.fullpath)

    rest_assured_app.should_receive(:body).with(d.content)
    Response.perform(rest_assured_app)
  end

  it "redirects if double not hit but there is redirect that matches request" do
    r = Redirect.create :to => 'http://exmple.com/api', :pattern => '.*'
    fullpath = '/some/other/path'
    request.stub(:fullpath).and_return(fullpath)

    rest_assured_app.should_receive(:redirect).with(r.to + fullpath)

    Response.perform(rest_assured_app)
  end

  it "returns 404 if neither double nor redirect matches the request" do
    rest_assured_app.should_receive(:status).with(404)
    
    Response.perform(rest_assured_app)
  end
end
