@apigateway-outage-by-region
Feature: API Gateway Outage by Region Chaos Testing
  As a user
  I want to test the resiliency of my application by injecting api gateway outage in a region.

  Scenario Outline: test resiliency by injecting chaos to api gateway in a region
    Given localstack setup is up and running for testing api gateway chaos
    And check api gateway by sending a request to /v1/health gets a response code of 200
    When I inject api gateway fault
    Then check api gateway by sending a GET request to /test and I should get a response code of 200
