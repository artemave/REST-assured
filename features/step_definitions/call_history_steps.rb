Given /^there is a double$/ do
  @double = RestAssured::Client::Double.create(:fullpath => '/some/path', :content => 'some content', :verb => 'POST')
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
