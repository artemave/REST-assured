@now
Feature: create double using ruby client api
  As ruby developer
  I want to be able to create doubles via client api
  So that interactions with rest-assured server are completely hidden from me

  Background:
    Given rest-assured is running locally:
    """
    RestAssured::Client.config.server_address = 'http://localhost:9876'
    """

  Scenario: create double with defaults
    When I create a double:
    """
    @double = RestAssured::Double.create(:fullpath => '/some/api')
    """
    Then it should have the following defaults:
    """
    @double.verb.should == 'GET'
    @double.response_headers.should == {}
    @double.status.should == 200
    @double.content.should == nil

    get @double.fullpath
    last_response.status.should be_ok
    """

  Scenario: create double with specified response headers
    When I create a double:
    """
    @double = RestAssured::Double.create(:fullpath => '/some/api', :response_headers => { 'ACCEPT' => 'text/html' })
    """
    Then it should have the following defaults:
    """
    @double.response_headers.should == { 'ACCEPT' => 'text/html' }

    get @double.fullpath
    last_response.headers['ACCEPT'].should == 'text/html'
    """

