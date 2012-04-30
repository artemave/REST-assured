@ruby_api
Feature: list doubles
  As api user
  I want to be able to get list of doubles
  So that I can do batch operations on them (e.g. remove doubles that match criteria)

  Scenario: list doubles
    Given there are the following doubles:
      | fullpath |
      | first    |
      | second   |

    When I get the list of doubles:
    """
    @doubles = RestAssured::Double.all
    """

    Then the following should be true:
    """
    @doubles.size.should == 2
    """
