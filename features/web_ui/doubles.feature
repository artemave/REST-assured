@ui
Feature: manage doubles via ui
  In order to use double data in development
  As a developer
  I want to have a manual interface for managing doubles

  Scenario: view existing doubles
    Given the following doubles exist:
      | fullpath  | pathpattern             | description  | content         | verb | delay |
      | /url1/aaa |                         | twitter      | test content    | GET  | 0     |
      | /url2/bbb |                         | geo location | more content    | POST | 1     |
      | /u/b?c=1  |                         | wikipedia    | article         | PUT  | 2     |
      |           | ^/api/foo\?nocache=123$ | pattern      | pattern content | GET  | 0     |
    When I visit "doubles" page
    Then I should see existing doubles:
      | fullpath  | pathpattern             | description  | verb | delay |
      | /url1/aaa |                         | twitter      | GET  | 0     |
      | /url2/bbb |                         | geo location | POST | 1     |
      | /u/b?c=1  |                         | wikipedia    | PUT  | 2     |
      |           | ^/api/foo\?nocache=123$ | pattern      | GET  | 0     |

  Scenario: add new double
    Given I am on "doubles" page
    When I choose to create a double
    And I enter double details:
      | fullpath      | pathpattern | description | content      | verb | status | delay |
      | /url2/bb?a=b5 |             | google api  | test content | POST | 200    | 1     |
    And I save it
    Then I should see "Double created"
    And I should see existing doubles:
      | fullpath      | description | verb | status | delay |
      | /url2/bb?a=b5 | google api  | POST | 200    | 1     |

  Scenario: add a new double with a path pattern
    Given I am on "doubles" page
    When I choose to create a double
    And I enter double details:
      | fullpath | pathpattern | description | content        | verb | status | delay |
      |          | ^\/api\/.*$ | pattern api | test content 1 | GET  | 200    | 0     |
    And I save it
    Then I should see "Double created"
    And I should see existing doubles:
      | pathpattern | description | verb | status | delay |
      | ^\/api\/.*$ | pattern api | GET  | 200    | 1     |

  @javascript
  Scenario: choose active double
    Given there are two doubles for the same fullpath
    When I visit "doubles" page
    And I make first double active
    Then first double should be served
    When I make second double active
    Then second double should be served

  Scenario: edit double
    Given the following doubles exist:
      | fullpath  | description | content      | verb | status | delay |
      | /url1/aaa | twitter     | test content | POST | 404    | 0     |
    And I visit "doubles" page
    And I choose to edit double
    When I change "double" "description" to "google"
    And I save it
    Then I should see existing doubles:
      | fullpath  | description | verb | status | delay |
      | /url1/aaa | google      | POST | 404    | 0     |

  @javascript
  Scenario: delete double
    Given the following doubles exist:
      | fullpath   | description | content       | delay |
      | /url1/aaa  | twitter     | test content  | 0     |
      | /url/cc/bb | google      | other content | 1     |
    And I visit "doubles" page
    And I choose to delete double with fullpath "/url1/aaa"
    Then I should be asked to confirm delete
    And I should see "Double deleted"
    And I should not see "/url1/aaa"
    And I should see "/url/cc/bb"
