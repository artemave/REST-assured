Feature: wait for requests on double to happen
  In order to know when it is a good time to verify requests on a double
  As test developer
  I want to be able to wait until specified number of requests happen

  Background:
    Given I created a double:
    """
    @double = RestAssured::Double.create(:fullpath => '/some/api')
    """

  Scenario: succesfully wait for requests
    When I wait for 3 requests:
    """
    @double.wait_for_requests(3)
    """
    And that double gets requested 3 times
    Then it should let me through

  Scenario: wait for requests that never come
    When I wait for 3 requests:
    """
    @double.wait_for_requests(3)
    """
    And that double gets requested 2 times
    Then it should wait for 5 seconds (default timeout)
    And it should raise MoreRequestsExpected error after with the following message:
    """
    Expected 3 requests. Got 2.
    """

  @now
  Scenario: custom timeout
    When I wait for 3 requests:
    """
    @double.wait_for_requests(3, :timeout => 3)
    """
    And that double gets requested 2 times
    Then it should wait for 3 seconds
