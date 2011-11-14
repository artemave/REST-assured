Given /^there is a double$/ do
  @double = RestAssured::Double.create(:fullpath => '/some/path', :content => 'some content', :verb => 'POST')
end

When /^that double gets requested$/ do
  post @double.fullpath, { :foo => 'bar' }.to_json, "CONTENT_TYPE" => "application/json"
  post @double.fullpath, { :fooz => 'baaz'}, 'SOME_HEADER' => 'header_data'
end

When /^I request call history for that double$/ do
  @requests = @double.reload.requests
end

Then /^I should see history records for those requests$/ do
  @requests.first.body.should == { :foo => 'bar' }.to_json
  JSON.parse( @requests.first.rack_env )["CONTENT_TYPE"].should == 'application/json'

  JSON.parse( @requests.last.params ).should == { 'fooz' => 'baaz' }
  JSON.parse( @requests.last.rack_env )["SOME_HEADER"].should == 'header_data'
end

Then /^it should be empty$/ do
  @requests.size.should == 0
end

Given /^I created a double:$/ do |string|
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
  wait_time.should >= timeout
  wait_time.should < timeout + 1
end

Then /^it should raise MoreRequestsExpected error after with the following message:$/ do |string|
  @more_reqs_exc.should be_instance_of RestAssured::MoreRequestsExpected
  @more_reqs_exc.message.should =~ /#{string}/
end
