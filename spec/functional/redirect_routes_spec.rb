require File.expand_path('../../spec_helper', __FILE__)

module RestAssured
  describe 'Redirects routes' do
    let :redirect do
      { :pattern => '/sdf.*', :to => 'http://google.com/api' }
    end

    let :valid_params do
      { 'redirect[pattern]' => redirect[:pattern], 'redirect[to]' => redirect[:to] }
    end

    let :invalid_params do
      { 'redirect[to]' => redirect[:to] }
    end

    context 'via ui', :ui => true do
      it 'shows list of redirects' do
        r = Models::Redirect.create redirect

        visit '/redirects'

        expect(page).to have_content(r.pattern)
        expect(page).to have_content(r.to)
      end

      it "shows form for creating new redirect" do
        visit '/redirects/new'

        expect(page).to have_css('#redirect_pattern')
        expect(page).to have_css('#redirect_to')
      end

      it "creates redirect" do
        post '/redirects', valid_params
        follow_redirect!

        expect(last_request.fullpath).to eq('/redirects')
        expect(last_response.body).to match(/Redirect created/)
        expect(Models::Redirect.exists?(redirect)).to be true
      end

      it "reports failure when creating with invalid parameters" do
        post '/redirects', invalid_params

        expect(last_response).to be_ok
        expect(last_response.body).to match(/Crumps!.*Pattern can't be blank/)
      end

      it "brings up redirect edit form" do
        r = Models::Redirect.create redirect
        visit "/redirects/#{r.id}/edit"

        expect(find('#redirect_pattern').value).to eq(r.pattern)
        expect(find('#redirect_to').value).to eq(r.to)
      end

      it "updates redirect" do
        r = Models::Redirect.create redirect

        put "/redirects/#{r.id}", 'redirect[to]' => '/some/other/api'
        follow_redirect!

        expect(last_request.fullpath).to eq('/redirects')
        expect(last_response.body).to match(/Redirect updated/)
        expect(r.reload.to).to eq('/some/other/api')
      end

      it "reorders redirects" do
        r1 = Models::Redirect.create! redirect
        r2 = Models::Redirect.create! redirect

        put "/redirects/reorder", :redirect => [r2.id, r1.id]

        expect(last_response).to be_ok
        expect(last_response.body).to eq('Changed')
        expect(r1.reload.position).to eq(1)
        expect(r2.reload.position).to eq(0)
      end

      it "deletes redirect" do
        f = Models::Redirect.create redirect

        delete "/redirects/#{f.id}"
        follow_redirect!

        expect(last_response).to be_ok
        expect(last_response.body).to match(/Redirect deleted/)

        expect(Models::Redirect.exists?(redirect)).to be_falsey
      end
    end

    context 'via api', :ui => false do
      it "creates redirect" do
        post '/redirects.json', redirect

        expect(last_response).to be_ok
        expect(Models::Redirect.count).to eq(1)
      end

      it "reports failure when creating with invalid parameters" do
        post '/redirects.json', redirect.except(:pattern)

        expect(last_response).not_to be_ok
        expect(last_response.body).to match(/Pattern can't be blank/)
      end

      it "deletes all redirects" do
        Models::Redirect.create redirect

        delete '/redirects/all'

        expect(last_response).to be_ok
        expect(Models::Redirect.count).to eq(0)
      end
    end
  end
end
