Feature: manage fixtures via api
  In order to use fixture data in integration tests
  As a developer
  I want to mock rest services my app is consuming from

  Scenario Outline: create fixture
    When I create a fixture with "<url>" as url and "<content>" as response content
    Then there should be 1 fixture with "<url>" as url and "<content>" as response content

    Examples:
      | url                | content      |
      | /api/something     | test content |
      | /api/some?a=3&b=dd | more content |

  Scenario Outline: request url that matches fixture
    Given there is fixture with "<url>" as url and "<content>" as response content
    When I request "<url>"
    Then I should get "<content>" in response content

    Examples:
      | url                | content      |
      | /api/something     | test content |
      | /api/some?a=3&b=dd | more content |

  # current rule: last added fixture gets picked
  Scenario Outline: request url that matches multiple fixtures
    Given there is fixture with "<url>" as url and "<content>" as response content
    And there is fixture with "<url>" as url and "<content2>" as response content
    When I request "<url>"
    Then I should get "<content2>" in response content

    Examples:
      | url                | content      | content2        |
      | /api/something     | test content | another content |
      | /api/some?a=3&b=dd | more content | some text       |

  Scenario: clear fixtures
    Given there are some fixtures
    When I delete all fixtures
    Then there should be no fixtures
