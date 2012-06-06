Feature: Viewing an organization
  In order to be called an admin, an admin must administrate organizations
  
  Background:
    Given I am logged in as an admin
    And an organization exists with an name of "Fractured Atlas"
    And the organization "Fractured Atlas" has a bank account
    And the organization "Fractured Atlas" has a lifetime value of "400"
    And I am on the admin organization page for "Fractured Atlas"
  
  Scenario:
    Then I should see "Fractured Atlas"
    And I should see "Users"
    And I should see "Bank account"
    And I should see "Events"
    And I should see "Settlements"
    And the lifetime value should show "400"