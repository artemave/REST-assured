Given /^rest\-assured is running locally:$/ do |code|
  eval code
end

When /^that double gets requested:$/ do |code|
  eval code
end

When /^I request call history for that double:$/ do |code|
  eval code
end

Then /^I should see history records for those requests:$/ do |code|
  eval code
end

Then /^it should be empty:$/ do |code|
  eval code
end

Given /^I created? a double:$/ do |string|
  # expected string is:
  # @double = RestAssured::Double.create(:fullpath => '/some/api', :verb => 'POST')
  eval string
end

When /^that double gets requested (#{CAPTURE_A_NUMBER}) times$/ do |num|
  num.times do
    sleep 0.5
    send(@double.verb.downcase, @double.fullpath)
  end
end

When /^I wait for (\d+) requests:$/ do |num, string|
  # expected string
  # @double.wait_for_requests(3)

  @wait_start = Time.now
  @t = Thread.new do
    begin
      eval string
    rescue RestAssured::MoreRequestsExpected => e
      @more_reqs_exc = e
    end
  end
end

Then /^it should let me through$/ do
  @t.join
  @more_reqs_exc.should == nil
end

Then /^it should wait for (#{CAPTURE_A_NUMBER}) seconds(?: \(default timeout\))?$/ do |timeout|
  @t.join
  wait_time = Time.now - @wait_start
  #(timeout..(timeout+1)).should cover(wait_time) # cover() only avilable in 1.9
  wait_time.should >= timeout - 0.5
  wait_time.should < timeout + 1.5
end

Then /^it should raise MoreRequestsExpected error after with the following message:$/ do |string|
  @more_reqs_exc.should be_instance_of RestAssured::MoreRequestsExpected
  @more_reqs_exc.message.should =~ /#{string}/
end

Then /^the following should be true:$/ do |code|
  eval code
end

Given /^there is free tcp port$/ do
  @free_tcp_port = RestAssured::Utils::PortExplorer.free_port
end

When /^I start rest-assured server via client library:$/ do |code|
  eval code
end

Then /^rest\-assured server should be running:$/ do |code|
  eval code
end

When /^I start rest\-assured asyncronously:$/ do |code|
  eval code
end

Then /^rest\-assured server should not be running:$/ do |code|
  eval code
end

When /^it finally comes up$/ do
  timeout(5) do
    loop do
      begin
        Net::HTTP.new('localhost', @free_tcp_port).head('/')
        break
      rescue Errno::ECONNREFUSED
        sleep 1
      end
    end
  end
end

Given /^rest\-assured has been started via client library$/ do
  RestAssured::Server.start(:port => RestAssured::Utils::PortExplorer.free_port)
end

When /^I stop it:$/ do |code|
  eval code
end

Then /^it should be stopped:$/ do |code|
  eval code
end
