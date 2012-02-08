@now
Feature: manage redirect rules
  In order to be able to mock only part of api
  As a developer
  I want to redirect to real api if there are no doubles for requested fullpath

  Scenario: no redirect rules
    Given blank slate
    When I request "/api/something"
    Then I should get 404

  Scenario: add redirect rule
    Given blank slate
    When I create redirect from "^/api/(.*)" to "http://example.com/\1"
    And I request "/api/something"
    Then it should redirect to "http://example.com/something"

  Scenario: add second redirect that match the same request
    Given there is redirect from "/api/something" to "http://example.com"
    When I create redirect from "/api/some.*" to "http://real.com"
    And I request "/api/something"
    Then it should redirect to "http://example.com/"

  Scenario: add second redirect that does not match the same request
    Given there is redirect from "/api/thing" to "http://real.com"
    When I create redirect from "/api/some.*" to "http://example.com"
    And I request "/api/something"
    Then it should redirect to "http://example.com/"

  Scenario: clear redirects
    Given there are some redirects
    When I delete all redirects
    Then there should be no redirects
