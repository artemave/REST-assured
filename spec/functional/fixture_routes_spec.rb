require_relative '../spec_helper'

describe 'Fixture routes' do
  let :fixture do
    { url: '/api/google?a=5', content: 'some awesome content' }
  end
  let :valid_params do
    { 'fixture[url]' =>  fixture[:url], 'fixture[content]' => fixture[:content] }
  end
  let :invalid_params do
    { 'fixture[url]' =>  fixture[:url] }
  end

  describe "through ui", ui: true do
    it "shows fixtures page by default" do
      visit '/'
      current_path.should == '/fixtures'
    end

    it "shows list of fixtures" do
      f = Fixture.create fixture

      visit '/fixtures'

      page.should have_content(f.url)
    end

    it "shows form for creating new fixture" do
      visit '/fixtures/new'

      page.should have_css('#fixture_url')
      page.should have_css('#fixture_content')
      page.should have_css('#fixture_description')
    end

    it "creates fixture" do
      post '/fixtures', valid_params
      follow_redirect!

      last_request.fullpath.should == '/fixtures'
      last_response.body.should =~ /Fixture created/
      Fixture.exists?(fixture).should be true
    end

    it "reports failure when creating with invalid parameters" do
      post '/fixtures', invalid_params

      last_response.should be_ok
      last_response.body.should =~ /Dude!.*Content can't be blank/
    end

    it "brings up fixture edit form" do
      f = Fixture.create fixture
      visit "/fixtures/#{f.id}/edit"

      find('#fixture_url').value.should == f.url
      find('#fixture_content').value.should == f.content
    end

    it "updates fixture" do
      f = Fixture.create fixture

      put "/fixtures/#{f.id}", 'fixture[url]' => '/some/other/api'
      follow_redirect!
      
      last_request.fullpath.should == '/fixtures'
      last_response.body.should =~ /Fixture updated/
      f.reload.url.should == '/some/other/api'
    end

    it "chooses active fixture" do
      f = Fixture.create fixture.merge!(active: false)

      ajax "/fixtures/#{f.id}", as: :put, active: true

      last_response.should be_ok
      last_response.body.should == 'Changed'
    end
  end

  describe "through REST api", ui: false do
    it "creates fixture" do
      post '/fixtures', fixture

      last_response.should be_ok
      Fixture.count.should == 1
    end

    it "reports failure when creating with invalid parameters" do
      post '/fixtures', fixture.except(:content)

      last_response.should_not be_ok
      last_response.body.should =~ /Content can't be blank/
    end

    it "deletes all fixtures" do
      Fixture.create fixture

      delete '/fixtures/all'

      last_response.should be_ok
      Fixture.count.should == 0
    end
  end
end
