require File.expand_path('../../spec_helper', __FILE__)

module RestAssured::Models
  describe Double do
    let :valid_params do
      {
        :fullpath         => '/some/api',
        :content          => 'some content',
        :verb             => 'GET',
        :status           => '303',
        :response_headers => { 'ACCEPT' => 'text/html' },
        :delay => 5
      }
    end

    let :valid_params_with_pattern do
      valid_params.except(:fullpath).merge(:pathpattern => /^\/api\/.*\/[a-zA-Z]\?nocache=true/)
    end

    it 'rejects double with neither fullpath or pathpattern' do
      d = Double.new valid_params.except(:fullpath)
      expect(d).to_not be_valid
    end

    it 'rejects double with both fullpath or pathpattern' do
      d = Double.new valid_params.merge(valid_params_with_pattern)
      expect(d).to_not be_valid
    end

    it 'creates double with valid params' do
      d = Double.new valid_params
      expect(d).to be_valid
    end

    it 'creates double with pathpattern' do
      d = Double.new valid_params_with_pattern
      expect(d).to be_valid
    end

    it 'rejects double with invalid pathpattern regex string' do
      # Probably a common mistake - not escaping forward slashes
      d = Double.new valid_params_with_pattern.merge(:pathpattern => '**')
      expect(d).to_not be_valid
    end

    it "defaults verb to GET" do
      f = Double.create valid_params.except(:verb)
      expect(f.verb).to eq('GET')
    end

    it "defaults status to 200" do
      f = Double.create valid_params.except(:status)
      expect(f.status).to eq(200)
    end

    it "makes double active by default" do
      f = Double.create valid_params.except(:active)
      expect(f.active).to be true
    end

    it "defaults delay to 0" do
      f = Double.create valid_params.except(:delay)
      expect(f.delay).to be 0
    end

    it "defaults delay of greater than 30 seconds to 30 seconds" do
      f = Double.create valid_params.merge(:delay => 99)
      expect(f.delay).to be 30
    end

    describe 'when created' do
      it "toggles active double for the same fullpath and verb" do
        f1 = Double.create valid_params
        f2 = Double.create valid_params
        f3 = Double.create valid_params.merge(:fullpath => '/some/other/api')
        f4 = Double.create valid_params.merge(:verb => 'POST')

        expect(f1.reload.active).to be false
        expect(f2.reload.active).to be true
        expect(f3.reload.active).to be true
        expect(f4.reload.active).to be true
      end
    end

    describe 'when saved' do
      it "toggles active double for the same fullpath and verb" do
        f1 = Double.create valid_params
        f2 = Double.create valid_params
        f3 = Double.create valid_params.merge(:fullpath => '/some/other/api')
        f4 = Double.create valid_params.merge(:verb => 'POST')

        f1.active = true
        f1.save

        expect(f2.reload.active).to be false
        expect(f3.reload.active).to be true
        expect(f4.reload.active).to be true
      end

      it "makes other doubles inactive only when active bit set to true" do
        f1 = Double.create valid_params
        f2 = Double.create valid_params
        f3 = Double.create valid_params.merge(:fullpath => '/some/other/api')
        f4 = Double.create valid_params.merge(:verb => 'POST')

        f1.reload.save
        f2.reload.save

        expect(f1.reload.active).to be false
        expect(f2.reload.active).to be true
        expect(f3.reload.active).to be true
        expect(f4.reload.active).to be true
      end

      it "handles long paths (more than 255 characters)" do
        long_path = 'a' * 260
        f1 = Double.create valid_params.merge(:fullpath => long_path)
        f1.reload.save
        expect(f1.reload.fullpath).to eq(long_path)
      end
    end

    describe 'when destroying' do
      context 'active double' do
        it "makes another double for the same fullpath active" do
          f1 = Double.create valid_params
          f2 = Double.create valid_params
          f3 = Double.create valid_params.merge(:fullpath => '/some/other/api')

          f2.destroy
          expect(f1.reload.active).to be true
          expect(f3.reload.active).to be true
        end
      end
    end
  end
end
