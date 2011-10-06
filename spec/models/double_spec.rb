require File.expand_path('../../spec_helper', __FILE__)

describe Double do
  let :valid_params do
    { :fullpath => '/some/api', :content => 'some content', :method => 'GET' }
  end

  it { should validate_presence_of(:fullpath) }
  it { should validate_presence_of(:content) }
  #it { should ensure_inclusion_of(:method).in(Double::METHODS) }

  it "defaults method to GET" do
    f = Double.create valid_params.except(:method)
    f.method.should == 'GET'
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
