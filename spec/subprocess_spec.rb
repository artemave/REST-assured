require File.expand_path('../spec_helper', __FILE__)
require File.expand_path('../../lib/rest-assured/utils/subprocess', __FILE__)

module RestAssured::Utils
  describe Subprocess do

    it 'forks passed block' do
      ppid_file = '/tmp/ra_ppid'
      Process.stub(:kill)

      Subprocess.new do
        File.open(ppid_file, 'w') {|f| f.write Process.ppid }
      end
      sleep 0.5

      File.read(ppid_file).should == Process.pid.to_s
      File.unlink(ppid_file)
    end

    it 'ensures no zombies' do
      Kernel.stub(:fork).and_return(pid = 1)
      Process.should_receive(:detach).with(pid)

      Subprocess.new {1}
    end

    it 'knows when it is running' do
      Process.stub(:kill)
      child = Subprocess.new { sleep 0.5 }
      Process.unstub(:kill)
      child.alive?.should == true
    end

    it 'knows when it is not running' do
      Process.stub(:kill)
      child = Subprocess.new { 1 }
      sleep 0.5
      Process.unstub(:kill)
      child.alive?.should == false
    end

    it 'shuts down child when stopped' do
      child = Subprocess.new { sleep 2 }
      child.stop
      sleep 0.5
      child.alive?.should == false
    end

    describe 'commits seppuku' do
      it 'if child raises exception'

      it 'if child just quits' do
        pending "in the code below stub works but mocking the same method - does not. I am puzzled"

        #Process.should_receive(:kill).with('INT', Process.pid)
        #Process.stub(:kill).with do
        #puts "FUUUUCK"
        #end

        Subprocess.new { 1 }
        sleep 0.5
      end
    end

    it 'makes sure child process does not oulive current one'
  end
end
