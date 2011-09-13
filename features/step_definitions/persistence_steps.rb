Given /^I (?:re)?start service without \-\-database option$/ do
  AppConfig[:database] = ':memory:' #default value
  load 'rest-assured/init.rb'
end

Then /^I should get (#{CAPTURE_A_NUMBER}) in response status$/ do |status|
  last_response.status.should == status
end

Given /^I (?:re)?start service with \-\-database "([^"]*)" option$/ do |db_path|
  AppConfig[:database] = db_path
  load 'rest-assured/init.rb'
end
