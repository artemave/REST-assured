Feature: Persistence
  In order to persist fixtrures/redirects between service restarts
  As a developer
  I want to be able to specify persistent storage

  Scenario: default storage
    Given I start service without --database option
    And I register "/api/something" as url and "content" as response content
    And I restart service without --database option
    When I request "/api/something"
    Then I should get "404" in response status

  Scenario Outline: specify storage
    Given I start service with --database "<db>" option
    And I register "/api/something" as url and "content" as response content
    And I restart service with --database "<db2>" option
    When I request "/api/something"
    Then I should get "<status>" in response status

    Examples:
      | db               | db2              | status |
      | database.db      | database.db      | 200    |
      | /tmp/database.db | /tmp/database.db | 200    |
      | database.db      | database2.db     | 404    |
