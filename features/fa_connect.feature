Feature: Fractured Atlas Membership via API
  In order to receive additional benefits and features
  a producer wants to be able to connect his or her organization with
  their Fractured Atlas membership.

  Background:
    Given I am logged in
    And I am part of an organization

  Scenario: A producer is prompted to connect to their Fractured Atlas account
    When I follow "My Organization"
    Then I should see "Connect to Fractured Atlas"
    And I should see "Account Email"
    And I should see "Account Password"

  Scenario: A producer is not prompted to connect to their Fractured Atlas account if they're already connected
    Given my organization is connected to a Fractured Atlas membership
    When I follow "My Organization"
    Then I should not see "Connect to Fractured Atlas"
    And I should not see "Account Email"
    And I should not see "Account Password"

  Scenario: A producer submits valid credentials to connect to their account
    Given I follow "My Organization"
    And the credentials I'll enter are valid
    When I fill in "Account Email" with "account@fracturedatlas.org"
    And I fill in "Account Password" with "somepassword"
    And I press "Connect"
    Then I should see "Successfully connected to Fractured Atlas!"
    And I my organization should have a Fractured Atlas membership

  Scenario: A producer submits invalid credentials to connect to their account
    Given I follow "My Organization"
    And the credentials I'll enter are not valid
    When I fill in "Account Email" with "account@fracturedatlas.org"
    And I fill in "Account Password" with "somepassword"
    And I press "Connect"
    Then I should see "Unable to connect to your Fractured Atlas account."