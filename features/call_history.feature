Feature: check double's call history
  In order to verify outcomes of my app that take form of http requests
  As test developer
  I want to be able to get double 'call history' 

  @wip
  Scenario: no calls made to double
    Given there is a double
    When I request call history for that double
    Then it should be empty
