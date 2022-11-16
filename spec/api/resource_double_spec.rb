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

    it { is_expected.to be_kind_of ActiveResource::Base }

    it 'creates new double' do
      d = Models::Double.create! :fullpath => '/some/api', :content => 'content'
      expect(Models::Double.where(:fullpath => d.fullpath, :content => d.content)).to exist
    end

    it 'finds exising double' do
      d = Models::Double.create! :fullpath => '/some/api', :content => 'content'

      dd = Double.find(d.id)

      expect(dd.fullpath).to eq(d.fullpath)
      expect(dd.content).to eq(d.content)
    end

    it 'shows request history' do
      d = Models::Double.create :fullpath => '/some/api', :content => 'content'
      d.requests << Models::Request.create(:rack_env => 'rack_env json', :body => 'body', :params => 'params')
      d.requests << Models::Request.create(:rack_env => 'different rack_env', :body => 'other body', :params => 'more params')

      dd = Double.find(d.id)
      expect(dd.requests.size).to eq(2)
      expect(dd.requests.first.rack_env).to eq('rack_env json')
      expect(dd.requests.first.params).to eq('params')
      expect(dd.requests.last.body).to eq('other body')
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

        expect(dd.requests.count).to be >= 2
      end

      it 'raises exception if requests have not happened within timeout' do
        d = Models::Double.create :fullpath => '/some/api', :content => 'content'
        dd = Double.find(d.id)
        allow(dd).to receive(:sleep)

        @t = Thread.new do
          2.times do
            d.requests << Models::Request.create(:rack_env => 'rack_env json', :body => 'body', :params => 'params')
          end
        end

        sleep 0.5
        expect { dd.wait_for_requests(3) }.to raise_error(MoreRequestsExpected, 'Expected 3 requests. Got 2.')
      end
    end
  end
end
