@ui
Feature: manage doubles via ui
  In order to use double data in development
  As a developer
  I want to have a manual interface for managing doubles

  Scenario: view existing doubles
    Given the following doubles exist:
      | fullpath       | description  | content      |
      | /url1/aaa | twitter      | test content |
      | /url2/bbb | geo location | more content |
      | /u/b?c=1  | wikipedia    | article      |
    When I visit "doubles" page
    Then I should see that I am on "doubles" page
    And I should see existing doubles:
      | fullpath       | description  |
      | /url1/aaa | twitter      |
      | /url2/bbb | geo location |
      | /u/b?c=1  | wikipedia    |

  Scenario: add new double
    Given I am on "doubles" page
    When I choose to create a double
    And I enter double details:
      | fullpath           | description | content      |
      | /url2/bb?a=b5 | google api  | test content |
    And I save it
    Then I should see "Double created"
    And I should see existing doubles:
      | fullpath           | description |
      | /url2/bb?a=b5 | google api  |

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
      | fullpath       | description  | content      |
      | /url1/aaa | twitter      | test content |
    And I visit "doubles" page
    And I choose to edit double
    When I change "double" "description" to "google"
    And I save it
    Then I should see that I am on "doubles" page
    And I should see existing doubles:
      | fullpath       | description  |
      | /url1/aaa | google       |

  @javascript
  Scenario: delete double
    Given the following doubles exist:
      | fullpath        | description | content       |
      | /url1/aaa  | twitter     | test content  |
      | /url/cc/bb | google      | other content |
    And I visit "doubles" page
    And I choose to delete double with fullpath "/url1/aaa"
    Then I should be asked to confirm delete
    And I should see "Double deleted"
    And I should not see "/url1/aaa"
    And I should see "/url/cc/bb"
