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
  Fixture.all.each do |f|
    page.should have_content(f.url)
    page.should have_content(f.description)
  end
end
