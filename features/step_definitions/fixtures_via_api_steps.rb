Given /^I register "([^"]*)" as url and "([^"]*)" as response content$/ do |url, content|
  n = Fixture.where(url: url, content: content).count
  post '/fixtures', { url: url, content: content }
  Fixture.where(url: url, content: content).count.should == n + 1
end

When /^I request "([^"]*)"$/ do |url|
  get url
  @last_response = last_response
end

Then /^I should get "([^"]*)" in response content$/ do |content|
  @last_response.body.should == content
end

Given /^there is no fixtures for "([^"]*)"$/ do |url|
  Fixture.where(url: url).destroy_all
end

Then /^it should redirect to "([^"]*)"$/ do |real_api_url|
  follow_redirect!
  last_response.header['Location'].should == real_api_url
end
