# REST api steps

Given /^there are no fixtures$/ do
  Fixture.destroy_all
end

When /^I create a fixture with "([^"]*)" as fullpath and "([^"]*)" as response content$/ do |fullpath, content|
  post '/fixtures', { :fullpath => fullpath, :content => content }
  last_response.should be_ok
end

When /^I create a fixture with "([^"]*)" as fullpath, "([^"]*)" as response content and "([^"]*)" as request method$/ do |fullpath, content, method|
  post '/fixtures', { :fullpath => fullpath, :content => content, :method => method }
  last_response.should be_ok
end

Then /^there should be (#{CAPTURE_A_NUMBER}) fixture with "([^"]*)" as fullpath and "([^"]*)" as response content$/ do |n, fullpath, content|
  Fixture.where(:fullpath => fullpath, :content => content).count.should == 1
end

Then /^there should be (#{CAPTURE_A_NUMBER}) fixture with "([^"]*)" as fullpath, "([^"]*)" as response content and "([^"]*)" as request method$/ do |n, fullpath, content, method|
  Fixture.where(:fullpath => fullpath, :content => content, :method => method).count.should == n
end

Given /^there is fixture with "([^"]*)" as fullpath and "([^"]*)" as response content$/ do |fullpath, content|
  Fixture.create(:fullpath => fullpath, :content => content)
end

Given /^there is fixture with "([^"]*)" as fullpath, "([^"]*)" as response content and "([^"]*)" as request method$/ do |fullpath, content, method|
  Fixture.create(:fullpath => fullpath, :content => content, :method => method)
end

Given /^I register "([^"]*)" as fullpath and "([^"]*)" as response content$/ do |fullpath, content|
  post '/fixtures', { :fullpath => fullpath, :content => content }
  last_response.should be_ok
end

When /^I request "([^"]*)"$/ do |fullpath|
  get fullpath
end

When /^I "([^"]*)" "([^"]*)"$/ do |method, fullpath|
  send(method.downcase, fullpath)
end

Then /^I should get "([^"]*)" in response content$/ do |content|
  last_response.body.should == content
end

Given /^there are some fixtures$/ do
  [['fullpath1', 'content1'], ['fullpath2', 'content2'], ['fullpath3', 'content3']].each do |fixture|
    Fixture.create(:fullpath => fixture[0], :content => fixture[1])
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
    Fixture.create(:fullpath => row['fullpath'], :description => row['description'], :content => row['content'])
  end
end

Then /^I should see that I am on "([^""]*)" page$/ do |name|
  find('title').text.should =~ /#{name} -/
end

Then /^I should see existing fixtures:$/ do |fixtures|
  fixtures.hashes.each do |row|
    page.should have_content(row[:fullpath])
    page.should have_content(row[:description])
  end
end

Given /^I am on "([^"]*)" page$/ do |page|
  When "I visit \"#{page}\" page"
end

When /^I choose to create a fixture$/ do
  find(:xpath, '//a[text()="New fixture"]').click
end

When /^I enter fixture details:$/ do |details|
  fixture = details.hashes.first

  fill_in 'Request fullpath', :with => fixture['fullpath']
  fill_in 'Content', :with => fixture['content']
  fill_in 'Description', :with => fixture['description']
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

Given /^there are two fixtures for the same fullpath$/ do
  @first = Fixture.create :fullpath => '/api/something', :content => 'some content'
  @second = Fixture.create :fullpath => '/api/something', :content => 'other content'
end

When /^I make (first|second) fixture active$/ do |ord|
  within "#fixture_row_#{instance_variable_get('@' + ord).id}" do
    find('input[type="radio"]').click
  end
end

Then /^(first|second) fixture should be served$/ do |ord|
  f = instance_variable_get('@' + ord)
  get f.fullpath
  last_response.body.should == f.content
end

Given /^I choose to edit (?:fixture|redirect)$/ do
  find('.edit-link a').click
end

When /^I change "([^"]*)" "([^"]*)" to "([^"]*)"$/ do |obj, prop, value|
  fill_in "#{obj}_#{prop}", :with => value
end

Given /^I choose to delete fixture with fullpath "([^"]*)"$/ do |fullpath|
  find(:xpath, "//tr[td[text()='#{fullpath}']]//a[text()='Delete']").click
end

Then /^I should be asked to confirm delete$/ do
  page.driver.browser.switch_to.alert.accept
end
