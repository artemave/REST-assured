Given /^rest\-assured is not up$/ do
end

When /^I start rest\-assured$/ do
  @server = RestAssured::Client.start_server
end

Then /^rest\-assured should be up$/ do
  (1..60).times do
    if @server.up?
      break
    else
      sleep 1
    end
  end

  @server.should be_up
  `ps a | grep rest-assured`[/#{@server.port}/].should_not be_nil
end
