require File.expand_path('../spec_helper', __FILE__)
require File.expand_path('../../lib/rest-assured/utils/subprocess', __FILE__)

module RestAssured::Utils
  describe Subprocess do
    it 'forks passed block' do
      block = Proc.new {}
      Process.stub(:detach) # so it does not complain about nil pid
      Kernel.should_receive(:fork).with(&block)

      Subprocess.new &block
    end

    it 'ensures no zombies' do
      Kernel.stub(:fork).and_return(pid = 1)
      Process.should_receive(:detach).with(pid)

      Subprocess.new {1}
    end

    it 'knows when it is running' do
      child = Subprocess.new { sleep 0.2 }
      child.alive?.should == true
    end

    it 'knows when it is not running' do
      child = Subprocess.new {1}
      sleep 0.5
      child.alive?.should == false
    end
  end
end
