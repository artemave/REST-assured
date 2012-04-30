@ruby_api
Feature: destroy double
  As api user
  I want to be able to destroy double 
  So that I can emulate 'service gone' in the middle of a test

  Scenario: list doubles
    Given I created a double:
    """
    @double = RestAssured::Double.create :fullpath => 'path'
    """

    When I destroy that double:
    """
    @double.destroy
    """

    Then the following should be true:
    """
    RestAssured::Double.all.size.should == 0
    """

