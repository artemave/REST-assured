When /^I start rest\-assured with (.*)$/ do |options|
  @app_config = fake_start_rest_assured(options)
end

Then /^it should run on port (\d+)$/ do |port|
  @app_config[:port].should == port
end

Then /^the log file should be (.*)$/ do |logfile|
  @app_config[:logfile].should == logfile
end

Then /^database adapter should be sqlite and db file should be (.*)$/ do |dbfile|
  @app_config[:db_config][:database].should == dbfile
  @app_config[:db_config][:adapter].should == 'sqlite3'
end

Then /^database options should be:$/ do |table|
  res = table.hashes.first

  empty_to_nil = lambda do |string|
    string.empty? ? nil : string
  end
  
  @app_config[:db_config][:adapter].should == 'mysql2'
  @app_config[:db_config][:database].should == res['dbname']
  @app_config[:db_config][:user].should == res['dbuser']
  @app_config[:db_config][:password].should == empty_to_nil[res['dbpass']]
  @app_config[:db_config][:host].should == empty_to_nil[res['dbhost']]
  @app_config[:db_config][:port].should == empty_to_nil[res['dbport']].try(:to_i)
  @app_config[:db_config][:encoding].should == empty_to_nil[res['dbencoding']]
  @app_config[:db_config][:socket].should == empty_to_nil[res['dbsocket']]
end

Then /^ssl certificate used should be "([^"]*)" and ssl key should be "([^"]*)"$/ do |ssl_cert, ssl_key|
  ssl_cert = File.expand_path('../../../ssl/localhost.crt', __FILE__) if ssl_cert == 'DEFAULT_CERT'
  ssl_key = File.expand_path('../../../ssl/localhost.key', __FILE__) if ssl_key == 'DEFAULT_KEY'

  @app_config[:ssl_cert].should == ssl_cert
  @app_config[:ssl_key].should == ssl_key
end

Then /^rest\-assured should "([^"]*)"$/ do |use|
  @app_config[:ssl].to_s.should == use
end
