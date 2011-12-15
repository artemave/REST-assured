Feature: create double
  As ruby developer
  I want to be able to create doubles via client api
  So that interactions with rest-assured server are completely hidden from me

  Background:
    Given rest-assured is running locally:
    """
    RestAssured::Client.config.server_address = 'http://localhost:9876'
    """

  Scenario: default options
    When I create a double:
    """
    @double = RestAssured::Double.create(:fullpath => '/some/api')
    """
    Then the following should be true:
    """
    @double.verb.should             == 'GET'
    @double.response_headers.should == {}
    @double.status.should           == 200
    @double.content.should          == nil

    get @double.fullpath
    last_response.should be_ok
    """

  Scenario: specify response headers
    When I create a double:
    """
    @double = RestAssured::Double.create(:fullpath => '/some/api', :response_headers => { 'Content-Type' => 'text/html' })
    """
    Then the following should be true:
    """
    @double.response_headers.should == { 'Content-Type' => 'text/html' }

    get @double.fullpath
    last_response.headers['Content-Type'].should == 'text/html'
    """

  Scenario: specify content
    When I create a double:
    """
    @double = RestAssured::Double.create(:fullpath => '/some/api', :content => 'awesome')
    """
    Then the following should be true:
    """
    @double.content = 'awesome'

    get @double.fullpath
    last_response.body == 'awesome'
    """

  Scenario: specify verb
    When I create a double:
    """
    @double = RestAssured::Double.create(:fullpath => '/some/api', :verb => 'POST')
    """
    Then the following should be true:
    """
    @double.verb = 'POST'

    get @double.fullpath
    last_response.should_not be_ok

    post @double.fullpath
    last_response.should be_ok
    """

  Scenario: specify status
    When I create a double:
    """
    @double = RestAssured::Double.create(:fullpath => '/some/api', :status => 302)
    """
    Then the following should be true:
    """
    @double.status = 302

    get @double.fullpath
    last_response.status == 302
    """
