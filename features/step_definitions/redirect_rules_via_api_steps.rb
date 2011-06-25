Given /^there are no redirect rules$/ do
  Redirect.destroy_all
end

Given /^there are no fixtures$/ do
  Fixture.destroy_all
end

Then /^I should get (\d+)$/ do |code|
  last_response.status.should.to_s == code
end

When /^I register redirect rule "([^"]*)" "([^"]*)"$/ do |pattern, url|
  post '/redirects', { pattern: pattern, to: url }
  last_response.should be_ok
end

Then /^it should redirect to "([^"]*)"$/ do |real_api_url|
  follow_redirect!
  last_response.header['Location'].should == real_api_url
end

