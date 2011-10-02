Feature: ruby client
  In order to have easy integration with my test code
  As a ruby developer
  I want to have a client library that will take care of rest-assured setup as well as provide some API access helpers

  #TODO if it is already started
  @wip
  Scenario: start rest-assured server
    Given rest-assured is not up
    When I start rest-assured
    Then rest-assured should be up

  Scenario: wait for rest-assured server to come up

  Scenario: autoshut down if tests exit unexpectedly

  Scenario: don't start if previous server instance is still hanging around for some reason

  Scenario: stop rest-assured server
