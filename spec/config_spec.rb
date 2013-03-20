require File.expand_path('../../lib/rest-assured/config', __FILE__)

module RestAssured
  describe Config do
    before do
      Config.build
    end

    context 'builds config from user options' do
      #this is thoroughly covered in cucumber (since there it also serves documentation purposes)
    end

    describe 'cmd args array conversion' do
      it 'converts true values in form of "value" => ["--#{value}"]' do
        Config.build(:ssl => true)
        Config.to_cmdargs.should == ['--ssl']
      end

      it 'does not include false values' do
        Config.build(:ssl => false)
        Config.to_cmdargs.should_not include('--ssl')
      end

      it 'converts key value pairs in form of "key => value" => ["--#{key}", "value"]' do
        Config.build(:port => 1234, :database => ':memory:')
        Config.to_cmdargs.each_slice(2) do |a|
          (a == ['--port', '1234'] || a == ['--database', ':memory:']).should == true
        end
      end
    end
  end
end
