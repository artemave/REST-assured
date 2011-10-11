When /^I request call history for that double$/ do
  @requests = @double.reload.requests
end
