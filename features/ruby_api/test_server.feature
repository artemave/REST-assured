Feature: test server
  In order to have easy integration with my test code
  As a ruby developer
  I want to have a client library take care of starting/stopping an instance of rest-assured appropriately

  #TODO if it is already started
  @wip
  Scenario: start rest-assured server
    Given rest-assured server is not running
    When I start rest-assured server via client library:
    """
    RestAssured::Server.start
    """
    Then rest-assured server should be running:
    """
    require 'net/http'
    expect { Net::HTTP.new('localhost', RestAssured::Server.port).head('/') }.to_not raise_error(Errno::ECONNREFUSED)
    """

  Scenario: wait for rest-assured server to come up

  Scenario: autoshut down if tests exit unexpectedly

  Scenario: don't start if previous server instance is still hanging around for some reason

  Scenario: stop rest-assured server
