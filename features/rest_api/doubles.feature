Feature: use doubles via api
  In order to use double data in integration tests
  As a developer
  I want to mock rest services my app is consuming from

  Scenario Outline: create double
    When I create a double with "<fullpath>" as fullpath, "<content>" as response content, "<verb>" as request verb, status as "<status>" and delay as "<delay>"
    Then there should be 1 double with "<fullpath>" as fullpath, "<content>" as response content, "<result_verb>" as request verb, status as "<result_status>" and delay as "<result_delay>"

    Examples:
      | fullpath           | content      | verb   | result_verb | status | result_status | delay | result_delay |
      | /api/something     | created      | POST   | POST        | 200    | 200           |       | 0            |
      | /api/sss           | changed      | PUT    | PUT         | 201    | 201           | 0     | 0            |
      | /api/asdfsf        | removed      | DELETE | DELETE      | 300    | 300           | 1     | 1            |
      | /api/some          | text content | GET    | GET         | 303    | 303           | 2     | 2            |
      | /api/some?a=3&b=dd | more content |        | GET         |        | 200           | 3     | 3            |
      | /api/empty         |              | POST   | POST        |        | 200           | 4     | 4            |
      | /api/file          |              | HEAD   | HEAD        |        | 200           | 5     | 5            |
      | /api/file          |              | PATCH  | PATCH       |        | 200           | 6     | 6            |

  Scenario Outline: create a double with a url pattern
    When I create a double with "<pathpattern>" as pathpattern, "<content>" as response content, "<verb>" as request verb, status as "<status>" and delay as "<delay>"
    Then there should be 1 double with "<pathpattern>" as pathpattern, "<content>" as response content, "<result_verb>" as request verb, status as "<result_status>" and delay as "<result_delay>"
    Examples:
      | pathpattern         | content | verb   | result_verb | status | result_status | delay | result_delay |
      | ^\/api\/.*$         | created | POST   | POST        | 200    | 200           |       | 0            |
      | ^.*\/\?nocache=\d+$ | changed | PUT    | PUT         | 201    | 201           | 0     | 0            |
      | ^[a-zA-Z]\/123$     | removed | DELETE | DELETE      | 300    | 300           | 1     | 1            |

  Scenario: view created double details
    When I create a double
    Then I should be able to get json representation of that double from response

  Scenario Outline: request fullpath that matches double
    Given there is double with "<fullpath>" as fullpath, "<content>" as response content, "<verb>" as request verb and "<status>" as status
    When I "<verb>" "<fullpath>"
    Then I should get <status> as response status and "<content>" in response content

    Examples:
      | fullpath           | content      | verb   | status |
      | /api/something     | created      | POST   | 200    |
      | /api/sss           | changed      | PUT    | 201    |
      | /api/asdfsf        | removed      | DELETE | 202    |
      | /api/some?a=3&b=dd | more content | GET    | 203    |
      | /other/api         |              | GET    | 303    |
      | /patch/api         |              | PATCH  | 200    |

  Scenario Outline: request a path that matches double a path pattern
    Given there is double with "<pathpattern>" as pathpattern, "<content>" as response content, "<verb>" as request verb and "<status>" as status
    When I "<verb>" "<fullpath>"
    Then I should get <status> as response status and "<content>" in response content

    Examples:
      | pathpattern                   | fullpath            | content      | verb | status |
      | ^.*$                          | /api/something      | created      | POST | 200    |
      | ^/api/.*$                     | /api/sss            | changed      | PUT  | 201    |
      | ^\/api\/some\?a=\d&b=[a-z]{2}$ | /api/some?a=3&b=dd | more content | GET  | 203    |

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

  # current rule: full path matches over pattern
  Scenario Outline: request fullpath that matches the full path of a double and a url pattern of another double
    Given there is double with "<fullpath>" as fullpath and "<content>" as response content
    Given there is double with "<pathpattern>" as pathpattern and "<content2>" as response content
    When I "GET" "<fullpath>"
    Then I should get "<content>" in response content

    Examples:
      | fullpath           | content      | pathpattern                  | content2     |
      | /api/something     | test content | ^/api/.*$                    | more content |
      | /api/some?a=3&b=dd | test content | ^\/api\/some?a=\d+&b=d[a-z]$ | more content |

  # current rule: last added double gets picked
  Scenario Outline: request full path that matches more than one path pattern
    Given there is double with "<pathpattern>" as pathpattern and "<content>" as response content
    Given there is double with "<pathpattern2>" as pathpattern and "<content2>" as response content
    When I "GET" "<fullpath>"
    Then I should get "<content2>" in response content

    Examples:
      | fullpath             | pathpattern                   | content      | pathpattern2                  | content2     |
      | /api/sam             | ^.*$                          | test content | ^\/api\/.*$                   | more content |
      | /api/some?a=123&b=dd | ^\/api\/some\?a=\d+&b=d[a-z]$ | test content | ^\/api\/some\?a=\d+&b=d[a-z]$ | more content |

  Scenario: request fullpath that does not match any double
    Given there are no doubles
    When I "GET" "/api/something"
    Then I should get 404 in response status

  Scenario: request full path that matches more than one path pattern
    Given there is double with "^.*$" as pathpattern, "test content" as response content, "OPTIONS" as request verb and "204" as status
    When I "OPTIONS" "/api/sam"
    Then I should get 204 in response status

  Scenario: clear doubles
    Given there are some doubles
    When I delete all doubles
    Then there should be no doubles
