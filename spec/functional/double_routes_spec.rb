require File.expand_path('../../spec_helper', __FILE__)

module RestAssured
  describe 'Double routes' do
    let :test_double do
      {
        :fullpath         => '/api/google?a=5',
        :content          => 'some awesome content',
        :description      => 'awesome double',
        :verb             => 'POST',
        :status           => '201',
        :response_headers => { 'ACCEPT' => 'text/html' }
      }
    end

    let :valid_params do
      params = {
        'double[fullpath]'         => test_double[:fullpath],
        'double[content]'          => test_double[:content],
        'double[verb]'             => test_double[:verb],
        'double[status]'           => test_double[:status],
        'double[description]'      => test_double[:description],
        'double[response_headers]' => test_double[:response_headers]
      }

      params
    end

    let :invalid_params do
      valid_params.except('double[fullpath]')
    end

    context "Web UI", :ui => true do
      it "makes doubles index root page" do
        visit '/'
        current_path.should == '/doubles'
      end

      # this is tested in cucumber
      it "renders doubles index" do
        f  = Models::Double.create test_double
        f1 = Models::Double.create test_double.merge(:verb => 'GET')

        visit '/doubles'

        page.should have_content(f.fullpath)
        page.should have_content(f.description)
        page.should have_content(f.verb)
        page.should have_content(f1.fullpath)
        page.should have_content(f1.description)
        page.should have_content(f1.verb)
      end

      it "renders form for creating new double" do
        visit '/doubles/new'

        page.should have_css('#double_fullpath')
        page.should have_css('#double_content')
        page.should have_css('#double_verb')
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

      it "renders double edit form" do
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
        f.reload.fullpath.should  == '/some/other/api'
        f.content.should          == test_double[:content]
        f.verb.should             == test_double[:verb]
        f.status.to_s.should      == test_double[:status]
        f.response_headers.should == test_double[:response_headers]
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

    context "REST api", :ui => false do
      it "creates double" do
        post '/doubles.json', test_double

        last_response.should be_ok

        d = Models::Double.where(test_double.except(:response_headers)).first
        d.response_headers['ACCEPT'].should == 'text/html'
      end

      it "reports failure when creating with invalid parameters" do
        post '/doubles.json', test_double.except(:fullpath)

        last_response.should_not be_ok
        last_response.body.should =~ /\{"fullpath":\["can't be blank"\]\}/
      end

      it "deletes double" do
        f = Models::Double.create test_double

        delete "/doubles/#{f.id}.json"

        last_response.should be_ok

        Models::Double.exists?(test_double.except(:response_headers)).should be_false
      end

      it "deletes all doubles" do
        Models::Double.create test_double

        delete '/doubles/all'

        last_response.should be_ok
        Models::Double.count.should == 0
      end
    end

    context 'REST (ActiveResource compatible) json api', :ui => false do
      it "gets list of doubles" do
        f  = Models::Double.create test_double
        f1 = Models::Double.create test_double.merge(:verb => 'GET')

        get '/doubles.json'

        json = MultiJson.load(last_response.body)

        json.first['double']['verb'].should == 'POST'
        json.last['double']['verb'].should == 'GET'
      end

      it "creates double as AR resource" do
        post '/doubles.json', { :double => test_double }.to_json, 'CONTENT_TYPE' => 'Application/json'

        last_response.should be_ok

        d = Models::Double.where(test_double.except(:response_headers)).first
        d.response_headers['ACCEPT'].should == 'text/html'
        last_response.body.should == d.to_json
      end

      it "reports failure when creating with invalid parameters" do
        post '/doubles.json', { :double => test_double.except(:fullpath) }.to_json, 'CONTENT_TYPE' => 'Application/json'

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
