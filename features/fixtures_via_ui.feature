Feature: manage fixtures via ui
  In order to use fixture data in development
  As a developer
  I want to have a manual interface for managing fixtures

  Scenario: view existing fixtures
    Given the following fixtures exist:
      | url       | description  | content      |
      | /url1/aaa | twitter      | test content |
      | /url2/bbb | geo location | more content |
      | /u/b?c=1  | wikipedia    | article      |
    When I visit fixtures page
    Then I should see that I am on "fixtures" page
    And I should see existing fixtures:
      | url       | description  |
      | /url1/aaa | twitter      |
      | /url2/bbb | geo location |
      | /u/b?c=1  | wikipedia    |

  Scenario: add new fixture
    Given I am on fixtures page
    When I choose to create a fixture
    And I enter fixture details:
      | url           | description | content      |
      | /url2/bb?a=b5 | google api  | test content |
    And I save it
    Then I should see "Fixture created"
    And I should see existing fixtures:
      | url           | description |
      | /url2/bb?a=b5 | google api  |

