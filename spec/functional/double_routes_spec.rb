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

    let :test_request do
      {
         :rack_env => {}
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
        expect(current_path).to eq('/doubles')
      end

      # this is tested in cucumber
      it "renders doubles index" do
        f  = Models::Double.create test_double
        f1 = Models::Double.create test_double.merge(:verb => 'GET')

        visit '/doubles'

        expect(page).to have_content(f.fullpath)
        expect(page).to have_content(f.description)
        expect(page).to have_content(f.verb)
        expect(page).to have_content(f1.fullpath)
        expect(page).to have_content(f1.description)
        expect(page).to have_content(f1.verb)
      end

      it "renders form for creating new double" do
        visit '/doubles/new'

        expect(page).to have_css('#double_fullpath')
        expect(page).to have_css('#double_content')
        expect(page).to have_css('#double_verb')
        expect(page).to have_css('#double_description')
      end

      it "creates double" do
        post '/doubles', valid_params

        follow_redirect!

        expect(last_request.fullpath).to eq('/doubles')
        expect(last_response.body).to match(/Double created/)

        d = Models::Double.where(test_double.except(:response_headers)).first
        expect(d.response_headers['ACCEPT']).to eq('text/html')
      end

      it "reports failure when creating with invalid parameters" do
        post '/doubles', invalid_params
        expect(last_response).to be_ok
        expect(last_response.body).to match(/Crumps!.*Exactly one of fullpath or pathpattern must be present/)
      end

      it "renders double edit form" do
        f = Models::Double.create test_double
        visit "/doubles/#{f.id}/edit"

        expect(find('#double_fullpath').value).to eq(f.fullpath)
        expect(find('#double_content').value).to eq(f.content)
      end

      it "updates double" do
        f = Models::Double.create test_double

        put "/doubles/#{f.id}", 'double[fullpath]' => '/some/other/api'
        follow_redirect!

        expect(last_request.fullpath).to eq('/doubles')
        expect(last_response.body).to match(/Double updated/)
        expect(f.reload.fullpath).to  eq('/some/other/api')
        expect(f.content).to          eq(test_double[:content])
        expect(f.verb).to             eq(test_double[:verb])
        expect(f.status.to_s).to      eq(test_double[:status])
        expect(f.response_headers).to eq(test_double[:response_headers])
      end

      it "chooses active double" do
        f = Models::Double.create test_double.merge!(:active => false)

        ajax "/doubles/#{f.id}", :as => :put, :active => true

        expect(last_response).to be_ok
        expect(last_response.body).to eq('Changed')
      end

      it "deletes double" do
        f = Models::Double.create test_double

        delete "/doubles/#{f.id}"
        follow_redirect!

        expect(last_response).to be_ok
        expect(last_response.body).to match(/Double deleted/)

        expect(Models::Double.exists?(test_double.except(:response_headers))).to be_falsey
      end
    end

    context "REST api", :ui => false do
      it "creates double" do
        post '/doubles.json', test_double

        expect(last_response).to be_ok

        d = Models::Double.where(test_double.except(:response_headers)).first
        expect(d.response_headers['ACCEPT']).to eq('text/html')
      end

      it "reports failure when creating with invalid parameters" do
        post '/doubles.json', test_double.except(:fullpath)

        expect(last_response).not_to be_ok
        expect(last_response.body).to match(/[\"Exactly one of fullpath or pathpattern must be present\"]/)
      end

      it "deletes double" do
        f = Models::Double.create test_double

        delete "/doubles/#{f.id}.json"

        expect(last_response).to be_ok

        expect(Models::Double.exists?(test_double.except(:response_headers))).to be_falsey
      end

      it "deletes all doubles" do
        Models::Double.create test_double

        delete '/doubles/all'

        expect(last_response).to be_ok
        expect(Models::Double.count).to eq(0)
      end

      it "deletes associated requests" do
        double = Models::Double.create test_double

        double.requests.create test_request

        delete '/doubles/all'

        expect(last_response).to be_ok
        expect(Models::Request.count).to eq(0)
      end
    end

    context 'REST (ActiveResource compatible) json api', :ui => false do
      it "gets list of doubles" do
        Models::Double.create test_double
        Models::Double.create test_double.merge(:verb => 'GET')

        get '/doubles.json'

        json = JSON.load(last_response.body)

        expect(json.first['verb']).to eq('POST')
        expect(json.last['verb']).to eq('GET')
      end

      it "creates double as AR resource" do
        post '/doubles.json', test_double.to_json, 'CONTENT_TYPE' => 'Application/json'

        expect(last_response).to be_ok

        d = Models::Double.where(test_double.except(:response_headers)).first
        expect(d.response_headers['ACCEPT']).to eq('text/html')
        expect(last_response.body).to eq(d.to_json)
      end

      it "reports failure when creating with invalid parameters" do
        post '/doubles.json', test_double.except(:fullpath).to_json, 'CONTENT_TYPE' => 'Application/json'

        expect(last_response).not_to be_ok
        expect(last_response.body).to match("{\"path\":[\"Exactly one of fullpath or pathpattern must be present\"]}")
      end

      it 'loads double as AR resource' do
        d = Models::Double.create test_double

        get "/doubles/#{d.id}.json", 'CONTENT_TYPE' => 'Application/json'

        expect(last_response).to be_ok
        expect(last_response.body).to eq(d.to_json(:include => :requests))
      end

      it '404s if double is not found' do
        get "/doubles/345345.json", 'CONTENT_TYPE' => 'Application/json'

        expect(last_response.status).to eq(404)
      end
    end
  end
end
