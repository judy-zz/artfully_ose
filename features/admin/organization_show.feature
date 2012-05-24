Feature: Viewing an organization
  In order to be called an admin, an admin must administrate organizations
  
  Background:
    Given I am logged in as an admin
    And an organization exists with an name of "Fractured Atlas"
    And the organization "Fractured Atlas" has a bank account
    And I am on the admin organization page for "Fractured Atlas"
  
  Scenario:
    Then I should see "Fractured Atlas"
    Then I should see "Users"
    Then I should see "Bank account"
    Then I should see "Events"
    Then I should see "Settlements"