Given /^the following fixtures exist:$/ do |fixtures|
  fixtures.hashes.each do |row|
    Fixture.create(url: row['url'], description: row['description'], content: row['content'])
  end
end

When /^I visit fixtures page$/ do
  visit '/fixtures'
end

Then /^I should see that I am on "([^""]*)" page$/ do |name|
  find('title').text.should == name
  find('h1').text.should == name.capitalize
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

Then /^I should see "([^"]*)"$/ do |text|
  page.should have_content(text)
end
