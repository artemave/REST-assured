Feature: manage fixtures via api
  In order to use fixture data in integration tests
  As a developer
  I want to mock real api

  Scenario: add new fixture
    Given I register "/api/something" as url and "test content" as response content
    When I request "/api/something"
    Then I should get "test content" in response content

  Scenario: add new fixture with parameters
    Given I register "/api/something?p=3&a=5" as url and "test content" as response content
    And I register "/api/something?p=4&a=5" as url and "more content" as response content
    When I request "/api/something?p=4&a=5"
    Then I should get "more content" in response content

  Scenario: add another fixture for the same url
    Given I register "/api/something" as url and "test content" as response content
    When I register "/api/something" as url and "more content" as response content
    And I request "/api/something"
    Then I should get "more content" in response content

  Scenario Outline: bypass to real service
    Given there is no fixtures for "<url>"
    When I request "<url>"
    Then it should redirect to "<real_url>"

      Examples:
        | url                            | real_url                                                |
        | /api/something?p=2&a=5         | https://api.int.bbc.co.uk/api/something?p=2&a=5         |
        | /api/something                 | https://api.int.bbc.co.uk/api/something                 |
        | /esp-service/something?p=2&a=5 | http://open.int.bbc.co.uk/esp-service/something?p=2&a=5 |
        | /esp-service/something         | http://open.int.bbc.co.uk/esp-service/something         |
