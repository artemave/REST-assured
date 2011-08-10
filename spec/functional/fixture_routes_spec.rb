require_relative '../spec_helper'

describe 'Fixture routes' do
  it "shows fixtures page by default" do
    visit '/'
    current_path.should == '/fixtures'
  end

  it "creates fixture", ui: true do
    post '/fixtures', { url: '/api/google?a=5', content: 'some awesome content' }
    follow_redirect!

    last_response.should be_ok
    last_response.body.should =~ /Fixture created/
  end

  it "creates fixture", ui: false do
    post '/fixtures', { url: '/api/google?a=5', content: 'some awesome content' }

    last_response.should be_ok
    Fixture.count.should == 1
  end
end
