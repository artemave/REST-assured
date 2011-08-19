require_relative '../spec_helper'

describe 'Redirects routes' do
  let :redirect do
    { pattern: '/sdf.*', to: 'http://google.com/api' }
  end

  let :valid_params do
    { 'redirect[pattern]' => redirect[:pattern], 'redirect[to]' => redirect[:to] }
  end

  let :invalid_params do
    { 'redirect[to]' => redirect[:to] }
  end

  context 'via ui', ui: true do
    it 'shows list of redirects' do
      r = Redirect.create redirect

      visit '/redirects'

      page.should have_content(r.pattern)
      page.should have_content(r.to)
    end

    it "shows form for creating new redirect" do
      visit '/redirects/new'

      page.should have_css('#redirect_pattern')
      page.should have_css('#redirect_to')
    end

    it "creates redirect" do
      post '/redirects', valid_params
      follow_redirect!

      last_request.fullpath.should == '/redirects'
      last_response.body.should =~ /Redirect created/
      Redirect.exists?(redirect).should be true
    end

    it "reports failure when creating with invalid parameters" do
      post '/redirects', invalid_params

      last_response.should be_ok
      last_response.body.should =~ /Crumps!.*Pattern can't be blank/
    end

    it "brings up redirect edit form" do
      r = Redirect.create redirect
      visit "/redirects/#{r.id}/edit"

      find('#redirect_pattern').value.should == r.pattern
      find('#redirect_to').value.should == r.to
    end

    it "updates redirect" do
      r = Redirect.create redirect

      put "/redirects/#{r.id}", 'redirect[to]' => '/some/other/api'
      follow_redirect!

      last_request.fullpath.should == '/redirects'
      last_response.body.should =~ /Redirect updated/
      r.reload.to.should == '/some/other/api'
    end

    it "reorders redirects" do
      r1 = Redirect.create! redirect
      r2 = Redirect.create! redirect

      put "/redirects/reorder", redirect: [r2.id, r1.id]

      last_response.should be_ok
      last_response.body.should == 'Changed'
      r1.reload.position.should == 1
      r2.reload.position.should == 0
    end

    it "deletes redirect" do
      f = Redirect.create redirect

      delete "/redirects/#{f.id}"
      follow_redirect!

      last_response.should be_ok
      last_response.body.should =~ /Redirect deleted/

      Redirect.exists?(redirect).should be_false
    end
  end

  context 'via api', ui: false do
    it "creates redirect" do
      post '/redirects', redirect

      last_response.should be_ok
      Redirect.count.should == 1
    end

    it "reports failure when creating with invalid parameters" do
      post '/redirects', redirect.except(:pattern)

      last_response.should_not be_ok
      last_response.body.should =~ /Pattern can't be blank/
    end
  end
end
