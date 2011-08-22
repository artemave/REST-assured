require File.expand_path('../../spec_helper', __FILE__)

describe Fixture do
  let :valid_params do
    { :url => '/some/api', :content => 'some content' }
  end

  it { should validate_presence_of(:url) }
  it { should validate_presence_of(:content) }

  it "makes fixture active by default" do
    f = Fixture.create valid_params.except(:active)
    f.active.should be true
  end

  describe 'when created' do
    it "toggles active fixture for the same url" do
      f1 = Fixture.create valid_params
      f2 = Fixture.create valid_params
      f3 = Fixture.create valid_params.merge(:url => '/some/other/api')

      f1.reload.active.should be false
      f3.reload.active.should be true
    end
  end

  describe 'when saved' do
    it "toggles active fixture for the same url" do
      f1 = Fixture.create valid_params
      f2 = Fixture.create valid_params
      f3 = Fixture.create valid_params.merge(:url => '/some/other/api')

      f1.active = true
      f1.save

      f2.reload.active.should be false
      f3.reload.active.should be true
    end

    it "makes other fixtures inactive only when active bit set to true" do
      f1 = Fixture.create valid_params
      f2 = Fixture.create valid_params
      f3 = Fixture.create valid_params.merge(:url => '/some/other/api')

      f1.reload.save
      f2.reload.save

      f1.reload.active.should be false
      f2.reload.active.should be true
      f3.reload.active.should be true
    end
  end

  describe 'when destroying' do
    context 'active fixture' do
      it "makes another fixture for the same url active" do
        f1 = Fixture.create valid_params
        f2 = Fixture.create valid_params
        f3 = Fixture.create valid_params.merge(:url => '/some/other/api')

        f2.destroy
        f1.reload.active.should be true
        f3.reload.active.should be true
      end
    end
  end
end
