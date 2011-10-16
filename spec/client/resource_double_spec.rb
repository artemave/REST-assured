require 'uri'
require File.expand_path('../../spec_helper', __FILE__)

module RestAssured::Client
  describe Double do
    before do
      @orig_addr = RestAssured::Client.config.server_address
    end

    after do
      RestAssured::Client.config.server_address = @orig_addr
    end

    it { should be_kind_of ActiveResource::Base }

    it 'knows where rest-assured server is' do
      RestAssured::Client.config.server_address = 'http://localhost:1234'
      Double.site.should == URI.parse('http://localhost:1234')
    end

    it 'creates new double' do
      d = Double.create :fullpath => '/some/api', :content => 'content'
      ::Double.where(:id => d.id).should exist
    end

    it 'finds exising double' do
      d = ::Double.create :fullpath => '/some/api', :content => 'content'

      Double.find(d.id).id.should be d.id
    end

    it 'shows request history' do
      d = ::Double.create :fullpath => '/some/api', :content => 'content'
      d.requests << Request.create(:rack_env => 'rack_env json', :body => 'body', :params => 'params')
      d.requests << Request.create(:rack_env => 'different rack_env', :body => 'other body', :params => 'more params')

      dd = Double.find(d.id)
      dd.requests.size.should == 2
      dd.requests.first.rack_env.should == 'rack_env json'
      dd.requests.first.params.should == 'params'
      dd.requests.last.body.should == 'other body'
    end
  end
end
