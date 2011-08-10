require_relative '../spec_helper'

describe 'Fixture routes' do
  let :valid_params do
    { url: '/api/google?a=5', content: 'some awesome content' }
  end
  let :invalid_params do
    { url: '/api/google?a=5' }
  end

  it "shows fixtures page by default" do
    visit '/'
    current_path.should == '/fixtures'
  end

  describe "through ui", ui: true do
    it "creates fixture" do
      post '/fixtures', valid_params
      follow_redirect!

      last_response.should be_ok
      last_response.body.should =~ /Fixture created/
    end

    it "reports failure" do
      post '/fixtures', invalid_params

      last_response.should be_ok
      last_response.body.should =~ /Errors!.*Content can't be blank/
    end
  end

  describe "through REST api", ui: false do
    it "creates fixture" do
      post '/fixtures', valid_params

      last_response.should be_ok
      Fixture.count.should == 1
    end

    it "reports failure" do
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
