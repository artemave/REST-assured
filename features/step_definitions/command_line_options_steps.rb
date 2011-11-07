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
  @app_config[:db_config][:database].should == dbfile
  @app_config[:db_config][:adapter].should == 'sqlite3'
  `rm #{dbfile}`
end

Then /^database options should be:$/ do |table|
  res = table.hashes.first

  empty_to_nil = lambda do |string|
    string.empty? ? nil : string
  end
  
  @app_config[:db_config][:adapter].should == 'mysql'
  @app_config[:db_config][:database].should == res['dbname']
  @app_config[:db_config][:user].should == res['dbuser']
  @app_config[:db_config][:password].should == empty_to_nil[res['dbpass']]
  @app_config[:db_config][:host].should == empty_to_nil[res['dbhost']]
  @app_config[:db_config][:port].should == empty_to_nil[res['dbport']].try(:to_i)
  @app_config[:db_config][:encoding].should == empty_to_nil[res['dbencoding']]
  @app_config[:db_config][:socket].should == empty_to_nil[res['dbsocket']]
end
