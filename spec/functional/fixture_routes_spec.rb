require_relative '../spec_helper'

describe 'Fixture routes' do
  it "shows fixtures page by default" do
    visit '/'
    current_path.should == '/fixtures'
  end
end
