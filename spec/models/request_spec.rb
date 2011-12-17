require File.expand_path('../../spec_helper', __FILE__)

module RestAssured::Models
  describe Request do
    it { should belong_to(:double) }
    it { should validate_presence_of(:rack_env) }

    it 'knows when it has been created' do
      now = Time.now
      Time.stub(:now).and_return(now)
      r = Request.create(:body => 'sdfsd', :rack_env => 'headers')

      r.created_at.should == now
    end
  end
end
