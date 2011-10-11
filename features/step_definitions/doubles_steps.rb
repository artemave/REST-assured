# REST api steps

Given /^there is a double$/ do
  @double = Resource::Double.create(:fullpath => '/some/path', :content => 'some conetent')
end

Given /^there are no doubles$/ do
  Double.destroy_all
end

When /^I create a double with "([^"]*)" as fullpath and "([^"]*)" as response content$/ do |fullpath, content|
  post '/doubles', { :fullpath => fullpath, :content => content }
  last_response.should be_ok
end

When /^I create a double with "([^"]*)" as fullpath, "([^"]*)" as response content and "([^"]*)" as request method$/ do |fullpath, content, method|
  post '/doubles', { :fullpath => fullpath, :content => content, :method => method }
  last_response.should be_ok
end

Then /^there should be (#{CAPTURE_A_NUMBER}) double with "([^"]*)" as fullpath and "([^"]*)" as response content$/ do |n, fullpath, content|
  Double.where(:fullpath => fullpath, :content => content).count.should == 1
end

Then /^there should be (#{CAPTURE_A_NUMBER}) double with "([^"]*)" as fullpath, "([^"]*)" as response content and "([^"]*)" as request method$/ do |n, fullpath, content, method|
  Double.where(:fullpath => fullpath, :content => content, :method => method).count.should == n
end

Given /^there is double with "([^"]*)" as fullpath and "([^"]*)" as response content$/ do |fullpath, content|
  Double.create(:fullpath => fullpath, :content => content)
end

Given /^there is double with "([^"]*)" as fullpath, "([^"]*)" as response content and "([^"]*)" as request method$/ do |fullpath, content, method|
  Double.create(:fullpath => fullpath, :content => content, :method => method)
end

Given /^I register "([^"]*)" as fullpath and "([^"]*)" as response content$/ do |fullpath, content|
  post '/doubles', { :fullpath => fullpath, :content => content }
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

Given /^there are some doubles$/ do
  [['fullpath1', 'content1'], ['fullpath2', 'content2'], ['fullpath3', 'content3']].each do |double|
    Double.create(:fullpath => double[0], :content => double[1])
  end
end

When /^I delete all doubles$/ do
  delete '/doubles/all'
  last_response.should be_ok
end

Then /^there should be no doubles$/ do
  Double.count.should == 0
end

# UI steps

Given /^the following doubles exist:$/ do |doubles|
  doubles.hashes.each do |row|
    Double.create(:fullpath => row['fullpath'], :description => row['description'], :content => row['content'])
  end
end

Then /^I should see that I am on "([^""]*)" page$/ do |name|
  find('title').text.should =~ /#{name} -/
end

Then /^I should see existing doubles:$/ do |doubles|
  doubles.hashes.each do |row|
    page.should have_content(row[:fullpath])
    page.should have_content(row[:description])
  end
end

Given /^I am on "([^"]*)" page$/ do |page|
  When "I visit \"#{page}\" page"
end

When /^I choose to create a double$/ do
  find(:xpath, '//a[text()="New double"]').click
end

When /^I enter double details:$/ do |details|
  double = details.hashes.first

  fill_in 'Request fullpath', :with => double['fullpath']
  fill_in 'Content', :with => double['content']
  fill_in 'Description', :with => double['description']
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

Given /^there are two doubles for the same fullpath$/ do
  @first = Double.create :fullpath => '/api/something', :content => 'some content'
  @second = Double.create :fullpath => '/api/something', :content => 'other content'
end

When /^I make (first|second) double active$/ do |ord|
  within "#double_row_#{instance_variable_get('@' + ord).id}" do
    find('input[type="radio"]').click
  end
end

Then /^(first|second) double should be served$/ do |ord|
  f = instance_variable_get('@' + ord)
  get f.fullpath
  last_response.body.should == f.content
end

Given /^I choose to edit (?:double|redirect)$/ do
  find('.edit-link a').click
end

When /^I change "([^"]*)" "([^"]*)" to "([^"]*)"$/ do |obj, prop, value|
  fill_in "#{obj}_#{prop}", :with => value
end

Given /^I choose to delete double with fullpath "([^"]*)"$/ do |fullpath|
  find(:xpath, "//tr[td[text()='#{fullpath}']]//a[text()='Delete']").click
end

Then /^I should be asked to confirm delete$/ do
  page.driver.browser.switch_to.alert.accept
end
