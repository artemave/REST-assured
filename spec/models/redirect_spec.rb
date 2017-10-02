require File.expand_path('../../spec_helper', __FILE__)

module RestAssured::Models
  describe Redirect do
    it 'assigns incremental position on create' do
      r1 = Redirect.create :pattern => '.*', :to => 'someurl'
      expect(r1.position).to eq(0)

      r2 = Redirect.create :pattern => '.*', :to => 'someurl'
      expect(r2.position).to eq(1)

      r2.position = 4
      r2.save

      r3 = Redirect.create :pattern => '.*', :to => 'someurl'
      expect(r3.position).to eq(5)
    end

    it 'updates order (with which redirects picked up for matching request)' do
      r1 = Redirect.create :pattern => '.*', :to => 'somewhere', :position => 0
      r2 = Redirect.create :pattern => '.*', :to => 'somewhere', :position => 1

      expect(Redirect.update_order([r2.id, r1.id])).to be true
      expect(r1.reload.position).to eq(1)
      expect(r2.reload.position).to eq(0)

      expect(Redirect.update_order([nil, 34])).to eq(false)
    end

    context 'redirect url' do
      it 'constructs url to redirect to' do
        path = rand(1000)
        Redirect.create :pattern => '/api/(.*)\?.*', :to => 'http://external.com/some/url/\1?p=5'
        expect(Redirect.find_redirect_url_for("/api/#{path}?param=1")).to eq("http://external.com/some/url/#{path}?p=5")
      end

      it 'returns the one that matches the substring' do
        Redirect.create :pattern => '/ai/path', :to => 'someurl'
        Redirect.create :pattern => '/api/path', :to => 'someurl'

        expect(Redirect.find_redirect_url_for('/api/path')).to eq('someurl')
      end

      it 'returns the oldest one that match' do
        Redirect.create :pattern => '/api', :to => 'someurl'
        Redirect.create :pattern => '/api/path', :to => 'otherurl'

        expect(Redirect.find_redirect_url_for('/api/path')).to eq('someurl/path')
      end
    end
  end
end
