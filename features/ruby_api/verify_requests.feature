Feature: verify requests that happened on double
  In order to check that my app is performing correct requests
  As test developer
  I want to be able to get double 'call history' 

  Background:
    Given rest-assured is running locally:
    """
    RestAssured::Double.site = 'http://localhost:9876'
    """

  Scenario: no calls made to double
    Given I created a double:
    """
    @double = RestAssured::Double.create(:fullpath => '/some/api')
    """
    When I request call history for that double:
    """
    @requests = @double.reload.requests
    """
    Then it should be empty:
    """
    @requests.should be_empty
    """

  Scenario: some calls made to double
    Given I created a double:
    """
    @double = RestAssured::Double.create(:fullpath => '/some/path', :content => 'some content', :verb => 'POST')
    """
    When that double gets requested:
    """
    post @double.fullpath, { :foo => 'bar' }.to_json, "CONTENT_TYPE" => "application/json"
    post @double.fullpath, { :fooz => 'baaz'}, 'SOME_HEADER' => 'header_data'
    """
    And I request call history for that double:
    """
    @requests = @double.reload.requests
    """
    Then I should see history records for those requests:
    """
    @requests.first.body.should == { :foo => 'bar' }.to_json
    @requests.first.params.should == '{}'
    JSON.parse( @requests.first.rack_env )["CONTENT_TYPE"].should == 'application/json'

    @requests.last.body.should == 'fooz=baaz'
    JSON.parse( @requests.last.params ).should == { 'fooz' => 'baaz' }
    JSON.parse( @requests.last.rack_env )["SOME_HEADER"].should == 'header_data'
    """
