require_relative '../spec_helper'

describe 'Fixture routes' do
  let :valid_params do
    { url: '/api/google?a=5', content: 'some awesome content' }
  end
  let :invalid_params do
    { url: '/api/google?a=5' }
  end

  describe "through ui", ui: true do
    it "shows fixtures page by default" do
      visit '/'
      current_path.should == '/fixtures'
    end

    it "shows list of fixtures" do
      Fixture.create valid_params

      visit '/fixtures'

      page.should have_content(valid_params[:url])
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
      last_response.should be_ok
      last_response.body.should =~ /Fixture created/
    end

    it "reports failure when creating with invalid parameters" do
      post '/fixtures', invalid_params

      last_response.should be_ok
      last_response.body.should =~ /Dude!.*Content can't be blank/
    end

    it "brings up fixture edit form" do
      f = Fixture.create valid_params
      visit "/fixtures/#{f.id}/edit"

      find('#fixture_url').value.should == f.url
      find('#fixture_content').value.should == f.content
    end

    it "updates fixture" do
      f = Fixture.create valid_params

      put "/fixtures/#{f.id}", url: '/some/other/api'
      follow_redirect!
      
      last_request.fullpath.should == '/fixtures'
      last_response.should be_ok
      last_response.body.should =~ /Fixture updated/
    end

    it "chooses active fixture" do
      f = Fixture.create valid_params.merge!(active: false)

      ajax "/fixtures/#{f.id}", as: :put, active: true

      last_response.should be_ok
      last_response.body.should == 'Changed'
    end
  end

  describe "through REST api", ui: false do
    it "creates fixture" do
      post '/fixtures', valid_params

      last_response.should be_ok
      Fixture.count.should == 1
    end

    it "reports failure when creating with invalid parameters" do
      post '/fixtures', invalid_params

      last_response.should_not be_ok
      last_response.body.should =~ /Content can't be blank/
    end

    it "deletes all fixtures" do
      Fixture.create valid_params

      delete '/fixtures/all'

      last_response.should be_ok
      Fixture.count.should == 0
    end
  end
end
