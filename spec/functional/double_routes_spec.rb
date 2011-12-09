require File.expand_path('../../spec_helper', __FILE__)

module RestAssured
  describe 'Double routes' do
    let :test_double do
      {
        :fullpath         => '/api/google?a=5',
        :content          => 'some awesome content',
        :verb             => 'POST',
        :status           => '201',
        :response_headers => { 'ACCEPT' => 'text/html' }
      }
    end

    # stupid ActiveResource packs keys for hash attributes (:response_headers in this case) twice
    # so we have to emulate this behavior in tests
    let :ar_test_double do
      rh = test_double.delete(:response_headers)
      test_double.merge!({ :response_headers => { :response_headers => rh } })
    end

    let :valid_params do
      params = {
        'double[fullpath]'         => test_double[:fullpath],
        'double[content]'          => test_double[:content],
        'double[verb]'             => test_double[:verb],
        'double[status]'           => test_double[:status],
        'double[response_headers]' => test_double[:response_headers]
      }

      params
    end

    let :invalid_params do
      valid_params.except('double[fullpath]')
    end

    describe "through ui", :ui => true do
      it "shows doubles page by default" do
        visit '/'
        current_path.should == '/doubles'
      end

      it "shows list of doubles" do
        f = Models::Double.create test_double

        visit '/doubles'

        page.should have_content(f.fullpath)
      end

      it "shows form for creating new double" do
        visit '/doubles/new'

        page.should have_css('#double_fullpath')
        page.should have_css('#double_content')
        page.should have_css('#double_description')
      end

      it "creates double" do
        post '/doubles', valid_params
        follow_redirect!

        last_request.fullpath.should == '/doubles'
        last_response.body.should =~ /Double created/

        d = Models::Double.where(test_double.except(:response_headers)).first
        d.response_headers['ACCEPT'].should == 'text/html'
      end

      it "reports failure when creating with invalid parameters" do
        post '/doubles', invalid_params

        last_response.should be_ok
        last_response.body.should =~ /Crumps!.*Fullpath can't be blank/
      end

      it "brings up double edit form" do
        f = Models::Double.create test_double
        visit "/doubles/#{f.id}/edit"

        find('#double_fullpath').value.should == f.fullpath
        find('#double_content').value.should == f.content
      end

      it "updates double" do
        f = Models::Double.create test_double

        put "/doubles/#{f.id}", 'double[fullpath]' => '/some/other/api'
        follow_redirect!

        last_request.fullpath.should == '/doubles'
        last_response.body.should =~ /Double updated/
        f.reload.fullpath.should == '/some/other/api'
      end

      it "chooses active double" do
        f = Models::Double.create test_double.merge!(:active => false)

        ajax "/doubles/#{f.id}", :as => :put, :active => true

        last_response.should be_ok
        last_response.body.should == 'Changed'
      end

      it "deletes double" do
        f = Models::Double.create test_double

        delete "/doubles/#{f.id}"
        follow_redirect!

        last_response.should be_ok
        last_response.body.should =~ /Double deleted/

        Models::Double.exists?(test_double.except(:response_headers)).should be_false
      end
    end

    describe "through REST api", :ui => false do
      it "creates double" do
        post '/doubles', test_double

        last_response.should be_ok

        d = Models::Double.where(test_double.except(:response_headers)).first
        d.response_headers['ACCEPT'].should == 'text/html'
      end

      it "reports failure when creating with invalid parameters" do
        post '/doubles', test_double.except(:fullpath)

        last_response.should_not be_ok
        last_response.body.should =~ /\{"fullpath":\["can't be blank"\]\}/
      end

      it "deletes all doubles" do
        Models::Double.create test_double

        delete '/doubles/all'

        last_response.should be_ok
        Models::Double.count.should == 0
      end
    end

    describe 'through REST (ActiveResource compatible) json api', :ui => false do
      it "creates double as AR resource" do
        post '/doubles.json', { :double => ar_test_double }.to_json, 'CONTENT_TYPE' => 'Application/json'

        last_response.should be_ok

        d = Models::Double.where(test_double.except(:response_headers)).first
        d.response_headers['ACCEPT'].should == 'text/html'
        last_response.body.should == d.to_json
      end

      it "reports failure when creating with invalid parameters" do
        post '/doubles.json', { :double => ar_test_double.except(:fullpath) }.to_json, 'CONTENT_TYPE' => 'Application/json'

        last_response.should_not be_ok
        last_response.body.should =~ /\{"fullpath":\["can't be blank"\]\}/
      end

      it 'loads double as AR resource' do
        d = Models::Double.create test_double

        get "/doubles/#{d.id}.json", 'CONTENT_TYPE' => 'Application/json'

        last_response.should be_ok
        last_response.body.should == d.to_json(:include => :requests)
      end

      it '404s if double is not found' do
        get "/doubles/345345.json", 'CONTENT_TYPE' => 'Application/json'

        last_response.status.should == 404
      end
    end
  end
end
