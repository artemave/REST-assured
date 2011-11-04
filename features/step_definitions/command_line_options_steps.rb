When /^I start rest\-assured with (.*)$/ do |options|
  @app_config = fake_start_rest_assured(options)
end

Then /^it should run on port (\d+)$/ do |port|
  @app_config[:port].should == port
end

Then /^the log file should be (.*)$/ do |logfile|
  @app_config[:logfile].should == logfile
  `rm #{logfile}`
end

Then /^database adapter should be sqlite and db file should be (.*)$/ do |dbfile|
  @app_config[:database].should == dbfile
  @app_config[:adapter].should == 'sqlite'
  `rm #{dbfile}`
end
