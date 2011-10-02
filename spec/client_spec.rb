require File.expand_path('../spec_helper', __FILE__)
require File.expand_path('../../lib/rest-assured/client', __FILE__)

describe RestAssured::Client do
  it 'starts server on free port with in-memory database' do
    free_port = 4545
    RestAssured::Client.stub(:free_tcp_port).and_return(free_port)
    Kernel.should_receive(:system).with("bundle exec rest-assured -d :memory: -p #{free_port}")

    RestAssured::Client.start_server
  end
  #it 'starts server in separate process (so that it does not block main thread)' do
    #pid = 1234
    #Process.should_receive(:fork).and_return(pid)
    #RestAssured::Client.start_server
  #end

end
