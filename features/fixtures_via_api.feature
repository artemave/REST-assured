Feature: manage fixtures via api
  In order to use fixture data in integration tests
  As a developer
  I want to mock rest services my app is consuming from

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

  Scenario: clear fixtures
    Given there are some fixtures
    When I delete all fixtures
    Then there should be no fixtures
