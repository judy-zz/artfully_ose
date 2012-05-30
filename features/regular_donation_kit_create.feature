Feature: Charity Donation Kit
  In order for an organization to accept donations from user@example.coms,
  they must enable the Donation Kit for their organization.

  Background:
    Given I am logged in
    And I create a new organization called "Fractured Atlas"
    And I view my organization page

  Scenario: The owner of an organization enables the Charity Donation Kit for her organization
    Given my organization has tax information
    When I activate the "Regular Donation Kit"
    And I press "Activate Charity Donation Kit"
    Then I should see a pending image

  Scenario: The owner of an organization enters tax info and then activates the Charity Donation Kit for her organization
    When I activate the "Regular Donation Kit"
    When I fill in "EIN" with "111-1234"
    And I fill in "Legal Organization Name" with "Some Organization"
    And I press "Update Tax Information"
    And I press "Activate Charity Donation Kit"
    Then I should see a pending image
