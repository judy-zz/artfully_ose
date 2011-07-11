Feature: Bank Account Creation
  In order to receive payment via the ACH API, organizations must have
  bank account information on file. An admin can add information to an organization.

  Background:
    Given I am logged in as an admin
    And an organization exists with an name of "Fractured Atlas"
    And the organization "Fractured Atlas" has a bank account
    And I follow "Organizations"
    And I follow "Fractured Atlas"

  Scenario: An admin edits the bank account for an organization
    Given I follow "Edit Bank Account"
    When I fill in the following:
      | Routing number | 111111118            |
      | Number         | 32152401253215240125 |
      | Name           | Joe Smith            |
      | Address        | 248 W 35th St        |
      | City           | New York             |
      | Zip            | 12345                |
      | Phone          | 123-789-4568         |
    And I select "NY" from "State"
    And I select "Personal Checking" from "Account type"
    And I press "Update"
    Then I should see "111111118"
    And I should see "32152401253215240125"
    And I should see "Personal Checking"
    And I should see "Joe Smith"
    And I should see "248 W 35th St"
    And I should see "New York"
    And I should see "NY"
    And I should see "12345"
    And I should see "123-789-4568"
    And I should see "Updated bank account for Fractured Atlas"

  Scenario: An admin does not put in proper data for an organization
    Given I follow "Edit Bank Account"
    And I fill in "NaN" for "Routing number"
    And I press "Update"
    And I should see "Unable to update bank account for Fractured Atlas"