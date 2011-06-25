Given /^I register "([^"]*)" as url and "([^"]*)" as response content$/ do |url, content|
  post '/fixtures', { url: url, content: content }
  last_response.should be_ok
end

When /^I request "([^"]*)"$/ do |url|
  get url
end

Then /^I should get "([^"]*)" in response content$/ do |content|
  last_response.body.should == content
end

Given /^there are some fixtures$/ do
  [['url1', 'content1'], ['url2', 'content2'], ['url3', 'content3']].each do |fixture|
    Fixture.create(url: fixture[0], content: fixture[1])
  end
end

When /^I delete all fixtures$/ do
  delete '/fixtures/all'
  last_response.should be_ok
end

Then /^there should be no fixtures$/ do
  Fixture.count.should == 0
end
