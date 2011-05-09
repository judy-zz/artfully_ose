Feature: Regular Donation Kit
  In order for an organization to accept donations from user@example.coms,
  they must enable the Donation Kit for their organization.

  Background:
    Given I am logged in
    And I create a new organization called "Fractured Atlas"
    When I follow "My Organization"
    And I follow "View all kits"

  Scenario: The owner of an organization enables the Regular Donation Kit for her organization
    Given my organization has tax information
    When I follow "Activate Regular Donation Kit"
    And I follow "I am an IRS approved charity"
    And I follow "Activate Regular Donation Kit"
    Then I should see "Pending"

  Scenario: The owner of an organization enters tax info and then activates the Regular Donation Kit for her organization
    Given I follow "Activate Regular Donation Kit"
    And I follow "I am an IRS approved charity"
    When I fill in "EIN" with "111-1234"
    And I fill in "Legal Organization Name" with "Some Organization"
    And I press "Update Tax Information"
    Then I should see "You meet the requirements for this kit."
    And I follow "Activate Regular Donation Kit"
    And I should see "Pending"
