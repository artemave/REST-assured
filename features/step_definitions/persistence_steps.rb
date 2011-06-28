Given /^I (?:re)?start service without \-\-database option$/ do
  FakeRestServices::Options.database = nil
  load 'fake_rest_services/config.rb'
end

Then /^I should get "([^""]*)" in response status$/ do |status|
  last_response.status.to_s.should == status
end

Given /^I (?:re)?start service with \-\-database "([^"]*)" option$/ do |db_path|
  FakeRestServices::Options.database = db_path
  load 'fake_rest_services/config.rb'
end
