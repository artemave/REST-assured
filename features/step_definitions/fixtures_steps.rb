# REST api steps

When /^I create a fixture with "([^"]*)" as url and "([^"]*)" as response content$/ do |url, content|
  post '/fixtures', { url: url, content: content }
  last_response.should be_ok
end

Then /^there should be (#{CAPTURE_A_NUMBER}) fixture with "([^"]*)" as url and "([^"]*)" as response content$/ do |n, url, content|
  Fixture.count.should == n
  Fixture.where(url: url, content: content).count.should == 1
end

Given /^there is fixture with "([^"]*)" as url and "([^"]*)" as response content$/ do |url, content|
  Fixture.create(url: url, content: content)
end

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

# UI steps

Given /^the following fixtures exist:$/ do |fixtures|
  fixtures.hashes.each do |row|
    Fixture.create(url: row['url'], description: row['description'], content: row['content'])
  end
end

When /^I visit fixtures page$/ do
  visit '/'
  find(:xpath, "//a[text()='Fixtures']").click
end

Then /^I should see that I am on "([^""]*)" page$/ do |name|
  find('title').text.should =~ /#{name} -/
end

Then /^I should see existing fixtures:$/ do |fixtures|
  fixtures.hashes.each do |row|
    page.should have_content(row[:url])
    page.should have_content(row[:description])
  end
end

Given /^I am on fixtures page$/ do
  When "I visit fixtures page"
end

When /^I choose to create a fixture$/ do
  find(:xpath, '//a[text()="New fixture"]').click
end

When /^I enter fixture details:$/ do |details|
  fixture = details.hashes.first

  fill_in 'Url', with: fixture['url']
  fill_in 'Content', with: fixture['content']
  fill_in 'Description', with: fixture['description']
end

When /^I save it$/ do
  find('input[type="submit"]').click
end

Then /^I should (not)? ?see "([^"]*)"$/ do |see, text|
  if see == 'not'
    page.should_not have_content(text)
  else
    page.should have_content(text)
  end
end

Given /^there are two fixtures for the same url$/ do
  @first = Fixture.create url: '/api/something', content: 'some content'
  @second = Fixture.create url: '/api/something', content: 'other content'
end

When /^I make (first|second) fixture active$/ do |ord|
  within "#fixture_row_#{instance_variable_get(?@ + ord).id}" do
    find('input[type="radio"]').click
  end
end

Then /^(first|second) fixture should be served$/ do |ord|
  f = instance_variable_get(?@ + ord)
  get f.url
  last_response.body.should == f.content
end

Given /^I choose to edit fixture$/ do
  find('.edit-link a').click
end

When /^I change "([^"]*)" to "([^"]*)"$/ do |prop, value|
  fill_in "fixture_#{prop}", with: value
end

Given /^I choose to delete fixture with url "([^"]*)"$/ do |url|
  find(:xpath, "//tr[td[text()='#{url}']]//a[text()='Delete']").click
end

Then /^I should be asked to confirm delete$/ do
  page.driver.browser.switch_to.alert.accept
end
