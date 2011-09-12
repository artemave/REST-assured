Feature: manage redirect rules
  In order to be able to mock only part of api
  As a developer
  I want to redirect to real api if there are no fixtures for requested fullpath

  Background:
    Given there are no redirect rules
    And there are no fixtures

  Scenario: no redirect rules
    When I request "/api/something"
    Then I should get 404

  Scenario: add redirect rule
    When I register redirect with pattern "^/api" and uri "http://real.api.co.uk"
    And I request "/api/something"
    Then it should redirect to "http://real.api.co.uk/api/something"

  Scenario: add second redirect that match the same request
    When I register redirect with pattern "/api/something" and uri "http://real.api.co.uk"
    And I register redirect with pattern "/api/some.*" and uri "http://real.com"
    And I request "/api/something"
    Then it should redirect to "http://real.api.co.uk/api/something"

  Scenario: add second redirect that does not match the same request
    When I register redirect with pattern "/api/something" and uri "http://real.api.co.uk"
    And I register redirect with pattern "/api/some" and uri "http://real.com"
    And I request "/api/someth"
    Then it should redirect to "http://real.com/api/someth"
