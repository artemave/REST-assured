Given /^there are no redirect rules$/ do
  Redirect.destroy_all
end

Then /^I should get (\d+)$/ do |code|
  last_response.status.should.to_s == code
end

When /^I register redirect with pattern "([^"]*)" and uri "([^"]*)"$/ do |pattern, uri|
  post '/redirects', { pattern: pattern, to: uri }
  last_response.should be_ok
end

Then /^it should redirect to "([^"]*)"$/ do |real_api_url|
  follow_redirect!
  last_response.header['Location'].should == real_api_url
end

Given /^the following redirects exist:$/ do |redirects|
  redirects.hashes.each do |row|
    Redirect.create(pattern: row['pattern'], to: row['to'])
  end
end

When /^I visit "([^"]+)" page$/ do |page|
  visit '/'
  find(:xpath, "//a[text()='#{page.capitalize}']").click
end

When /^I choose to create a redirect$/ do
  find(:xpath, '//a[text()="New redirect"]').click
end

When /^I enter redirect details:$/ do |details|
  redirect = details.hashes.first

  fill_in 'Pattern', with: redirect['pattern']
  fill_in 'Redirect to', with: redirect['to']
end

Then /^I should see existing redirects:$/ do |redirects|
  redirects.hashes.each do |row|
    page.should have_content(row[:pattern])
    page.should have_content(row[:to])
  end
end

Given /^I choose to delete redirect with pattern "([^"]*)"$/ do |pattern|
  find(:xpath, "//tr[td[text()='#{pattern}']]//a[text()='Delete']").click
end
