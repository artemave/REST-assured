require 'net/http'
require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../../lib/rest-assured/api/server', __FILE__)

module RestAssured
  describe Server do
    after do
      Server.reset_instance
    end

    context 'when starts' do
      it 'runs RestAssured::Application in subprocess' do
        Utils::Subprocess.should_receive(:new) do |&block|
          block.call
        end
        # XXX I don't know how to test that run! happens
        # only as part of block passed to Subprocess. Code smell?
        Application.should_receive(:run!)

        Server.start!

        #started = false
        #10.times do
          #begin
            #Net::HTTP.new('localhost', Config.port).head('/')
            #started = true
          #rescue Errno::ECONNREFUSED
            #sleep 1
          #end
          #break if started
        #end

        #started.should be_true
      end

      it 'picks free tcp port' do
        Utils::Subprocess.stub(:new)
        Utils::PortExplorer.stub(:free_tcp_port).and_return(3489)

        Config.should_receive(:build).with(hash_including(:port => 3489))
        Server.start!
      end

      it 'uses in-memory sqlite database' do
        Utils::Subprocess.stub(:new)

        Config.should_receive(:build).with(hash_including(:database => ':memory:', :adapter => 'sqlite'))
        Server.start!
      end

      it 'khows when it is up' do
        Utils::Subprocess.stub(:new).and_return(child = stub(:alive? => true))
        Utils::PortExplorer.stub(:port_in_use? => true, :free_tcp_port => 4578)
        Server.start

        Server.up?.should == true
      end

      context 'it is NOT up' do
        it 'if it has not been started' do
          Server.up?.should == false
        end
        
        it 'if it starting at the moment' do
          Utils::Subprocess.stub(:new).and_return(child = stub(:alive? => false))
          Utils::PortExplorer.stub(:port_in_use? => false, :free_tcp_port => 4578)
          Server.start!

          Server.up?.should == false
        end
      end

      describe 'async/sync start' do
        before do
          Utils::Subprocess.stub(:new).and_return(child = stub(:alive? => false))
          Utils::PortExplorer.stub(:port_in_use? => false, :free_tcp_port => 4578)

          @t = Thread.new do
            sleep 0.5
            child.stub(:alive?).and_return(true)
            Utils::PortExplorer.stub(:port_in_use? => true)
          end
        end

        after do
          @t.join
        end

        it 'does not wait for Application to come up' do
          Server.start!
          Server.up?.should == false
        end

        it 'can wait optionally wait until Application is up before passing control' do
          Server.start
          Server.up?.should == true
        end
      end
    end

    it 'stops application subprocess' do
      Utils::Subprocess.stub(:new).and_return(child = mock)
      Server.start!

      child.should_receive(:stop)
      Server.stop
    end
  end
end
