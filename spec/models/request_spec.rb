require File.expand_path('../../spec_helper', __FILE__)

module RestAssured::Models
  describe Request do
    it { is_expected.to belong_to(:double) }
    it { is_expected.to validate_presence_of(:rack_env) }

    it 'knows when it has been created' do
      now = Time.now
      allow(Time).to receive(:now).and_return(now)
      r = Request.create(:body => 'sdfsd', :rack_env => 'headers')

      expect(r.created_at).to eq(now)
    end
  end
end
