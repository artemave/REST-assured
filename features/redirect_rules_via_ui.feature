@ui
Feature: manage redirects via ui
  In order to set up 'pass through' for requests that don't match any fixture
  As a developer
  I want to have a ui to set up redirects

  Scenario: view existing redirects
    Given the following redirects exist:
      | pattern   | to                     |
      | /url1/.*  | http://google.com/api  |
      | /url2/bbb | http://twitter.com/api |
    When I visit "redirects" page
    Then I should see that I am on "redirects" page
    And I should see existing redirects:
      | pattern   | to                     |
      | /url1/.*  | http://google.com/api  |
      | /url2/bbb | http://twitter.com/api |

  Scenario: add new redirect
    Given I visit "redirects" page
    When I choose to create a redirect
    And I enter redirect details:
      | pattern  | to                    |
      | /url1/.* | http://google.com/api |
    And I save it
    Then I should see "Redirect created"
    And I should see existing redirects:
      | pattern  | to                    |
      | /url1/.* | http://google.com/api |

  Scenario: edit redirect
    Given the following redirects exist:
      | pattern  | to                    |
      | /url1/.* | http://google.com/api |
    And I visit "redirects" page
    And I choose to edit redirect
    When I change "redirect" "pattern" to "/some/remote.*"
    And I save it
    Then I should see that I am on "redirects" page
    And I should see existing redirects:
      | pattern  | to                    |
      | /some/remote.* | http://google.com/api |

  @javascript @wip
  Scenario: delete redirect
    Given the following redirects exist:
      | pattern   | to                     |
      | /url1/.*  | http://google.com/api  |
      | /url2/bbb | http://twitter.com/api |
    And I visit "redirects" page
    And I choose to delete redirect with pattern "/url1/.*"
    Then I should be asked to confirm delete
    And I should see "Redirect deleted"
    And I should not see "/url1/.*"
    And I should see "/url2/bbb"
