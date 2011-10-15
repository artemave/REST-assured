When /^I request call history for that double$/ do
  @requests = @double.reload.requests
end

Then /^it should be empty$/ do
  @requests.size.should == 0
end
