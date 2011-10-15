require 'slave'
require File.expand_path('../spec_helper', __FILE__)
require File.expand_path('../../lib/rest-assured/api', __FILE__)

describe 'ruby api' do
  describe RestAssured::Server do
    context 'when starts' do
      it 'spawns new slave process' do
        Slave.should_receive(:new).with(:object => an_instance_of(RestAssured::Server)).and_return(double.as_null_object)
        RestAssured::Server.start
      end

      it 'starts RestAssured::Application' do
        app_class = mock
        server = RestAssured::Server.new(app_class)
        Slave.stub(:new).and_return(double(:object => server))

        app_class.should_receive(:run!)
        RestAssured::Server.start
      end

      #it 'runs RestAssured::Application' do
        #RestAssured::Application.should_receive(:run!)
        #RestAssured::Server.new
      #end

      #it 'uses free port' do
        #tcp_port = double('tcp_port', :allocate => 1234)
        #AppConfig.should_receive(:[]).with(:port, 1234)

        #RestAssured::Server.new(tcp_port)
      #end

      #it 'uses inmemory database' do
        #AppConfig.should_receive(:[]).with(:database, ':memory:')
        #RestAssured::Server.new
      #end
    end

  end
end
