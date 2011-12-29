require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../../lib/rest-assured/api/server', __FILE__)

module RestAssured
  describe Server do
    after do
      Server.reset_instance
    end

    it 'passes configuration to underlying application' do
      Utils::Subprocess.stub(:new)

      opts = { :port => 34545, :database => ':memory:' }

      Config.should_receive(:build).with(opts)
      Server.start!(opts)
    end

    it 'khows when it is up' do
      Utils::Subprocess.stub(:new).and_return(child = stub(:alive? => true))
      Utils::PortExplorer.stub(:port_free? => false)
      Server.start

      Server.up?.should == true
    end

    context 'knows that it is NOT up' do
      it 'if it has not been started' do
        Server.up?.should == false
      end

      it 'if it starting at the moment' do
        Utils::Subprocess.stub(:new).and_return(child = stub(:alive? => true))
        Utils::PortExplorer.stub(:port_free? => true)
        Server.start!

        Server.up?.should == false
      end
    end

    context 'when started' do
      it 'starts RestAssured::Application in subprocess' do
        Utils::Subprocess.should_receive(:new) do |&block|
          block.call
        end
        # XXX I don't know how to test that run! happens
        # only as part of block passed to Subprocess. Code smell?
        Application.should_receive(:run!)

        Server.start!
      end

      describe 'async/sync start' do
        before do
          Utils::Subprocess.stub(:new).and_return(child = stub(:alive? => false))
          Utils::PortExplorer.stub(:port_free? => true)

          @t = Thread.new do
            sleep 0.5
            child.stub(:alive?).and_return(true)
            Utils::PortExplorer.stub(:port_free? => false)
          end
        end

        after do
          @t.join
        end

        it 'does not wait for Application to come up' do
          Server.start!
          Server.up?.should == false
        end

        it 'can wait until Application is up before passing control' do
          Server.start
          Server.up?.should == true
        end
      end
    end

    context 'when stopped' do
      it 'stops application subprocess' do
        Utils::Subprocess.stub(:new).and_return(child = mock)
        Server.start!

        child.should_receive(:stop)
        Server.stop
      end
    end
  end
end
