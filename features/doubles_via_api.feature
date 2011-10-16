Feature: use doubles via api
  In order to use double data in integration tests
  As a developer
  I want to mock rest services my app is consuming from

  Scenario Outline: create double
    When I create a double with "<fullpath>" as fullpath, "<content>" as response content and "<verb>" as request verb
    Then there should be 1 double with "<fullpath>" as fullpath, "<content>" as response content and "<result_verb>" as request verb

    Examples:
      | fullpath           | content      | verb | result_verb |
      | /api/something     | created      | POST   | POST          |
      | /api/sss           | changed      | PUT    | PUT           |
      | /api/asdfsf        | removed      | DELETE | DELETE        |
      | /api/some          | text content | GET    | GET           |
      | /api/some?a=3&b=dd | more content |        | GET           |

  Scenario Outline: request fullpath that matches double
    Given there is double with "<fullpath>" as fullpath, "<content>" as response content and "<verb>" as request verb
    When I "<verb>" "<fullpath>"
    Then I should get "<content>" in response content

    Examples:
      | fullpath           | content      | verb |
      | /api/something     | created      | POST   |
      | /api/sss           | changed      | PUT    |
      | /api/asdfsf        | removed      | DELETE |
      | /api/some?a=3&b=dd | more content | GET    |

  # current rule: last added double gets picked
  Scenario Outline: request fullpath that matches multiple doubles
    Given there is double with "<fullpath>" as fullpath and "<content>" as response content
    And there is double with "<fullpath>" as fullpath and "<content2>" as response content
    When I "GET" "<fullpath>"
    Then I should get "<content2>" in response content

    Examples:
      | fullpath           | content      | content2        |
      | /api/something     | test content | another content |
      | /api/some?a=3&b=dd | more content | some text       |

  Scenario: request fullpath that does not match any double
    Given there are no doubles
    When I "GET" "/api/something"
    Then I should get 404 in response status

  Scenario: clear doubles
    Given there are some doubles
    When I delete all doubles
    Then there should be no doubles
