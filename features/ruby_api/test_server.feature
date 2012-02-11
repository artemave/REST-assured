@api_server
Feature: test server
  In order to have easy integration with my test code
  As a ruby developer
  I want to have a client library take care of starting/stopping an instance of rest-assured

  Scenario: start rest-assured server
    Given there is free tcp port
    When I start rest-assured server via client library:
    """
    RestAssured::Server.start(:port => @free_tcp_port)
    """
    Then rest-assured server should be running:
    """
    RestAssured::Server.should be_up
    """

  Scenario: start asyncronously (so that other heavy setup - e.g. firefox startup - can be done in parallel)
    Given there is free tcp port
    When I start rest-assured asyncronously:
    """
    RestAssured::Server.start!(:port => @free_tcp_port)
    """
    Then rest-assured server should not be running:
    """
    RestAssured::Server.should_not be_up
    """
    When it finally comes up
    Then rest-assured server should be running:
    """
    RestAssured::Server.should be_up
    """

  Scenario: stop rest-assured server
    Given rest-assured has been started via client library
    When I stop it:
    """
    RestAssured::Server.stop
    """
    Then it should be stopped:
    """
    RestAssured::Server.should_not be_up
    """
