require 'uri'
require File.expand_path('../../spec_helper', __FILE__)

module RestAssured
  describe Double, 'ruby-api' => true do
    before(:all) do
      Server.start(DB_OPTS.merge(:port => 9877))
    end
    after(:all) do
      Server.stop
    end

    it { should be_kind_of ActiveResource::Base }

    it 'creates new double' do
      d = Double.create :fullpath => '/some/api', :content => 'content'
      Models::Double.where(:fullpath => d.fullpath, :content => d.content).should exist
    end

    it 'finds exising double' do
      d = Models::Double.create :fullpath => '/some/api', :content => 'content'

      dd = Double.find(d.id)

      dd.fullpath.should == d.fullpath
      dd.content.should == d.content
    end

    it 'shows request history' do
      d = Models::Double.create :fullpath => '/some/api', :content => 'content'
      d.requests << Models::Request.create(:rack_env => 'rack_env json', :body => 'body', :params => 'params')
      d.requests << Models::Request.create(:rack_env => 'different rack_env', :body => 'other body', :params => 'more params')

      dd = Double.find(d.id)
      dd.requests.size.should == 2
      dd.requests.first.rack_env.should == 'rack_env json'
      dd.requests.first.params.should == 'params'
      dd.requests.last.body.should == 'other body'
    end

    context 'when waits requests' do
      after do
        @t.join if @t.respond_to?(:join)
      end

      it 'waits for specified number of requests' do
        d = Models::Double.create :fullpath => '/some/api', :content => 'content'
        dd = Double.find(d.id)

        @t = Thread.new do
          3.times do
            sleep 1
            d.requests << Models::Request.create(:rack_env => 'rack_env json', :body => 'body', :params => 'params')
          end
        end

        dd.wait_for_requests(2)

        dd.requests.count.should >= 2
      end

      it 'raises exception if requests have not happened within timeout' do
        d = Models::Double.create :fullpath => '/some/api', :content => 'content'
        dd = Double.find(d.id)
        dd.stub(:sleep)

        @t = Thread.new do
          2.times do
            d.requests << Models::Request.create(:rack_env => 'rack_env json', :body => 'body', :params => 'params')
          end
        end

        sleep 0.5
        lambda { dd.wait_for_requests(3) }.should raise_error(MoreRequestsExpected, 'Expected 3 requests. Got 2.')
      end
    end
  end
end
