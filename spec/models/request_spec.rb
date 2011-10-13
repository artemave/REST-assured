require File.expand_path('../../spec_helper', __FILE__)
require 'rest-assured/models/request'

describe Request do
  it { should belong_to(:double) }
  it { should validate_presence_of(:body) }
  it { should validate_presence_of(:headers) }

  it 'knows when it has been created' do
    now = Time.now
    Time.stub(:now).and_return(now)
    r = Request.create(:body => 'sdfsd', :headers => 'headers')

    r.created_at.should == now
  end
end
