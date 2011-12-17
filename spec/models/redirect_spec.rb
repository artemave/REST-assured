require File.expand_path('../../spec_helper', __FILE__)
require 'shoulda-matchers'

module RestAssured::Models
  describe Redirect do
    # this is solely to get through 'Can't find first XXX' shoulda crap
    #before do
    #Redirect.create :pattern => 'sdfsdf', :to => 'sdfsffdf'
    #end

    it { should validate_presence_of(:pattern) }
    it { should validate_presence_of(:to) }
    it { should allow_mass_assignment_of(:pattern) }
    it { should allow_mass_assignment_of(:to) }
    it { should allow_mass_assignment_of(:position) }

    it 'assigns incremental position on create' do
      r1 = Redirect.create :pattern => '.*', :to => 'someurl'
      r1.position.should == 0

      r2 = Redirect.create :pattern => '.*', :to => 'someurl'
      r2.position.should == 1

      r2.position = 4
      r2.save

      r3 = Redirect.create :pattern => '.*', :to => 'someurl'
      r3.position.should == 5
    end

    it 'updates order (with which redirects picked up for matching request)' do
      r1 = Redirect.create :pattern => '.*', :to => 'somewhere', :position => 0
      r2 = Redirect.create :pattern => '.*', :to => 'somewhere', :position => 1

      Redirect.update_order([r2.id, r1.id]).should be true
      r1.reload.position.should == 1
      r2.reload.position.should == 0

      Redirect.update_order([nil, 34]).should == false
    end
  end
end
