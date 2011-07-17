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

  @wip
  Scenario: add new fixture
    Given I am on fixtures page
    When I choose to create a fixture
    And I enter fixture details:
      | url       | description  | content      |
      | /url1/aaa | twitter      | test content |
    And I save it
    Then I should see "Fixture created"
    And I should see existing fixtures:
      | url       | description  |

  #Scenario: add new fixture with parameters
    #Given I register "/api/something?p=3&a=5" as url and "test content" as response content
    #And I register "/api/something?p=4&a=5" as url and "more content" as response content
    #When I request "/api/something?p=4&a=5"
    #Then I should get "more content" in response content

  #Scenario: add another fixture for the same url
    #Given I register "/api/something" as url and "test content" as response content
    #When I register "/api/something" as url and "more content" as response content
    #And I request "/api/something"
    #Then I should get "more content" in response content

  #Scenario: clear fixtures
    #Given there are some fixtures
    #When I delete all fixtures
    #Then there should be no fixtures
