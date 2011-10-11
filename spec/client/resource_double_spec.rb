require 'uri'
require File.expand_path('../../spec_helper', __FILE__)

module RestAssured::Client
  describe Double do
    it { should be_kind_of ActiveResource::Base }

    it 'should know where rest-assured server is' do
      RestAssured::Client.config.server_address = 'http://localhost:1234'
      subject.class.site.should == URI.parse('http://localhost:1234')
    end
  end
end
