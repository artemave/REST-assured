# REST api steps

Given /^there are no doubles$/ do
  RestAssured::Models::Double.destroy_all
end

When /^I create a double with "([^""]*)" as fullpath, "([^""]*)" as response content, "([^""]*)" as request verb, status as "([^""]*)" and delay as "([^""]*)"$/ do |fullpath, content, verb, status, delay|
  post '/doubles.json', { :fullpath => fullpath, :content => content, :verb => verb, :status => status, :delay => delay}
  last_response.should be_ok
end

When /^I create a double with "([^""]*)" as pathpattern, "([^""]*)" as response content, "([^""]*)" as request verb, status as "([^""]*)" and delay as "([^""]*)"$/ do |pathpattern, content, verb, status, delay|
  post '/doubles.json', { :pathpattern => pathpattern, :content => content, :verb => verb, :status => status, :delay => delay}
  last_response.should be_ok
end

When /^I create a double$/ do
  post '/doubles.json', { :fullpath => '/api/something' }
  @create_a_double_response = last_response.body
end

Then /^I should be able to get json representation of that double from response$/ do
  d = RestAssured::Models::Double.last
  JSON.load( @create_a_double_response ).should == JSON.load( d.to_json )
end

Then /^I should get {int} in response status$/ do |status|
  last_response.status.should == status
end

Then "there should be {int} double with {string} as fullpath, {string} as response content, {string} as request verb, status as {string} and delay as {string}" do |n, fullpath, content, verb, status, delay|
  RestAssured::Models::Double.where(:fullpath => fullpath, :content => content, :verb => verb, :status => status.to_i, :delay => delay.to_i).count.should == n
end

Then "there should be {int} double with {string} as pathpattern, {string} as response content, {string} as request verb, status as {string} and delay as {string}" do |n, pathpattern, content, verb, status, delay|
  RestAssured::Models::Double.where(:pathpattern => pathpattern, :content => content, :verb => verb, :status => status.to_i, :delay => delay.to_i).count.should == n
end

Given /^there is double with "([^"]*)" as fullpath and "([^"]*)" as response content$/ do |fullpath, content|
  RestAssured::Models::Double.create(:fullpath => fullpath, :content => content)
end

Given /^there is double with "([^"]*)" as pathpattern and "([^"]*)" as response content$/ do |pathpattern, content|
  RestAssured::Models::Double.create(:pathpattern => pathpattern, :content => content)
end

Given /^there is double with "([^"]*)" as fullpath, "([^"]*)" as response content, "([^"]*)" as request verb and "([^"]*)" as status$/ do |fullpath, content, verb, status|
  RestAssured::Models::Double.create(:fullpath => fullpath, :content => content, :verb => verb, :status => status)
end

Given /there is double with "([^"]*)" as pathpattern, "([^"]*)" as response content, "([^"]*)" as request verb and "([^"]*)" as status$/ do |pathpattern, content, verb, status|
  RestAssured::Models::Double.create(:pathpattern => pathpattern, :content => content, :verb => verb, :status => status)
end

When /^I request "([^"]*)"$/ do |fullpath|
  get fullpath
end

When /sleep (\d+)/ do |n|
  sleep n
end

When /^I "([^"]*)" "([^"]*)"$/ do |verb, fullpath|
  send(verb.downcase, fullpath)
end

Then "I should get {string} in response content" do |content|
  last_response.body.should == content
end

Then "I should get {int} in response status" do |status|
  last_response.status.should == status
end

Then "I should get {int} as response status and {string} in response content" do |status, content|
  last_response.status.should == status
  last_response.body.should == content
end

Given /^there are some doubles$/ do
  [['fullpath1', 'content1'], ['fullpath2', 'content2'], ['fullpath3', 'content3']].each do |double|
    RestAssured::Models::Double.create(:fullpath => double[0], :content => double[1])
  end
end

When /^I delete all doubles$/ do
  delete '/doubles/all'
  last_response.should be_ok
end

Then /^there should be no doubles$/ do
  RestAssured::Models::Double.count.should == 0
end

# UI steps

Given /^the following doubles exist:$/ do |doubles|
  doubles.hashes.each do |row|
    RestAssured::Models::Double.create(
      :fullpath    => row['fullpath'],
      :pathpattern    => row['pathpattern'],
      :description => row['description'],
      :content     => row['content'],
      :verb        => row['verb'],
      :status      => row['status']
    )
  end
end

Then /^I should see existing doubles:$/ do |doubles|
  doubles.hashes.each do |row|
    page.should have_content(row[:fullpath]) unless row[:fullpath].blank?
    page.should have_content(row[:pathpattern]) unless row[:pathpattern].blank?
    page.should have_content(row[:description])
    page.should have_content(row[:verb])
    page.should have_content(row[:status])
  end
end

Given /^I am on "([^"]*)" page$/ do |page|
  step "I visit \"#{page}\" page"
end

When /^I choose to create a double$/ do
  find(:xpath, '//a[text()="New double"]').click
end

When /^I enter double details:$/ do |details|
  double = details.hashes.first
  fill_in 'Request fullpath', :with => double['fullpath']
  fill_in 'Request path pattern', :with => double['pathpattern']
  fill_in 'Content', :with => double['content']
  select  double['verb'], :from => 'Verb'
  fill_in 'Description', :with => double['description']
  select  double['status'], :from => 'Status'
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
  @first = RestAssured::Models::Double.create :fullpath => '/api/something', :content => 'some content'
  @second = RestAssured::Models::Double.create :fullpath => '/api/something', :content => 'other content'
end

When /^I make (first|second) double active$/ do |ord|
  within "#double_row_#{instance_variable_get('@' + ord).id}" do
    find('input[type="radio"]').click
  end
end

Then /^(first|second) double should be served$/ do |ord|
  f = instance_variable_get('@' + ord)
  sleeping(0.1).seconds.between_tries.failing_after(20).tries do
    get f.fullpath
    last_response.body.should == f.content
  end
end

Given /^I choose to edit (?:double|redirect)$/ do
  all('.edit-link a').first.click
end

When /^I change "([^"]*)" "([^"]*)" to "([^"]*)"$/ do |obj, prop, value|
  fill_in "#{obj}_#{prop}", :with => value
end

Given /^I choose to delete double with fullpath "([^"]*)"$/ do |fullpath|
  find(:xpath, "//tr[td[a[text()='#{fullpath}']]]//a[text()='Delete']").click
end

Then /^I should be asked to confirm delete$/ do
  js_confirm
end

Given /^there are the following doubles:$/ do |table|
  table.hashes.each do |row|
    RestAssured::Models::Double.create :fullpath => row['fullpath']
  end
end
