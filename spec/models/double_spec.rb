require File.expand_path('../../spec_helper', __FILE__)
require 'shoulda-matchers'

module RestAssured::Models
  describe Double do
    let :valid_params do
      {
        :fullpath         => '/some/api',
        :content          => 'some content',
        :verb             => 'GET',
        :status           => '303',
        :response_headers => { 'ACCEPT' => 'text/html' }
      }
    end

    it { should validate_presence_of(:fullpath) }
    it { should validate_inclusion_of(:verb, Double::VERBS) }
    it { should validate_inclusion_of(:status, Double::STATUSES) }
    it { should allow_mass_assignment_of(:fullpath) }
    it { should allow_mass_assignment_of(:content) }
    it { should allow_mass_assignment_of(:verb) }
    it { should allow_mass_assignment_of(:status) }
    it { should allow_mass_assignment_of(:response_headers) }

    it { should have_many(:requests) }

    it 'creates double with valid params' do
      d = Double.new valid_params
      d.should be_valid
    end

    it "defaults verb to GET" do
      f = Double.create valid_params.except(:verb)
      f.verb.should == 'GET'
    end

    it "defaults status to 200" do
      f = Double.create valid_params.except(:status)
      f.status.should == 200
    end

    it "makes double active by default" do
      f = Double.create valid_params.except(:active)
      f.active.should be true
    end

    describe 'when created' do
      it "toggles active double for the same fullpath" do
        f1 = Double.create valid_params
        f2 = Double.create valid_params
        f3 = Double.create valid_params.merge(:fullpath => '/some/other/api')

        f1.reload.active.should be false
        f2.reload.active.should be true
        f3.reload.active.should be true
      end
    end

    describe 'when saved' do
      it "toggles active double for the same fullpath" do
        f1 = Double.create valid_params
        f2 = Double.create valid_params
        f3 = Double.create valid_params.merge(:fullpath => '/some/other/api')

        f1.active = true
        f1.save

        f2.reload.active.should be false
        f3.reload.active.should be true
      end

      it "makes other doubles inactive only when active bit set to true" do
        f1 = Double.create valid_params
        f2 = Double.create valid_params
        f3 = Double.create valid_params.merge(:fullpath => '/some/other/api')

        f1.reload.save
        f2.reload.save

        f1.reload.active.should be false
        f2.reload.active.should be true
        f3.reload.active.should be true
      end
    end

    describe 'when destroying' do
      context 'active double' do
        it "makes another double for the same fullpath active" do
          f1 = Double.create valid_params
          f2 = Double.create valid_params
          f3 = Double.create valid_params.merge(:fullpath => '/some/other/api')

          f2.destroy
          f1.reload.active.should be true
          f3.reload.active.should be true
        end
      end
    end
  end
end
