require File.expand_path('../../spec_helper', __FILE__)
require 'rest-assured/routes/response'

module RestAssured
  describe Response do
    [:get, :post, :put, :delete].each do |verb|
      it "processes an unknown request" do

        Response.should_receive(:perform).with(an_instance_of(RestAssured::Application))
        send verb, '/some/path'
      end
    end

    let(:env) { double(:to_json => 'env').as_null_object }
    let(:request) {
      double('Request',
        :request_method => 'GET',
        :fullpath       => '/api',
        :env            => env,
        :body           => double(:read    => 'body').as_null_object,
        :params         => double(:to_json => 'params')
      )
    }
    let(:rest_assured_app) { double('App', :request => request).as_null_object }

    context 'when double matches request' do
      before do
        @double = Models::Double.create \
          :fullpath         => '/some/path',
          :content          => 'content',
          :response_headers => { 'ACCEPT' => 'text/html' },
          :status           => 201

        request.stub(:fullpath).and_return(@double.fullpath)
      end

      it "returns double content" do
        rest_assured_app.should_receive(:body).with(@double.content)

        Response.perform(rest_assured_app)
      end

      it 'sets response status to the one from double' do
        rest_assured_app.should_receive(:status).with(@double.status)

        Response.perform(rest_assured_app)
      end

      it 'sets response headers to those in Double#response_headers' do
        rest_assured_app.should_receive(:headers).with(@double.response_headers)

        Response.perform(rest_assured_app)
      end

      it 'records request' do
        requests = double
        Models::Double.stub_chain('where.first').and_return(double(:requests => requests).as_null_object)

        requests.should_receive(:create!).with(:rack_env => 'env', :body => 'body', :params => 'params')

        Response.perform(rest_assured_app)
      end
    
      it "returns double when redirect matches double" do
        fullpath = '/some/other/path'
        request.stub(:fullpath).and_return(fullpath)
        Models::Redirect.stub(:find_redirect_url_for).with(fullpath).and_return('/some/path')

        rest_assured_app.should_receive(:body).with(@double.content)
        rest_assured_app.should_receive(:status).with(@double.status)
        rest_assured_app.should_receive(:headers).with(@double.response_headers)

        Response.perform(rest_assured_app)
      end

    end

    it "redirects if double not hit but there is redirect that matches request" do
      #r = Models::Redirect.create :to => 'http://exmple.com/api', :pattern => '.*'
      #
      fullpath = '/some/other/path'
      request.stub(:fullpath).and_return(fullpath)
      Models::Redirect.stub(:find_redirect_url_for).with(fullpath).and_return('new_url')

      rest_assured_app.should_receive(:redirect).with('new_url')

      Response.perform(rest_assured_app)
    end

    it "returns 404 if neither double nor redirect matches the request" do
      rest_assured_app.should_receive(:status).with(404)

      Response.perform(rest_assured_app)
    end

    # TODO change to instead exclude anything that does not respond_to?(:to_s)
    it 'excludes "rack.input" and "rack.errors" as they break with "IOError - not opened for reading:" on consequent #to_json (as they are IO and StringIO)' do
      requests = double.as_null_object
      Models::Double.stub_chain('where.first').and_return(double(:requests => requests).as_null_object)

      env.should_receive(:except).with('rack.input', 'rack.errors', 'rack.logger')

      Response.perform(rest_assured_app)
    end

  end
end
