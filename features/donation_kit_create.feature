Feature: Donation Kit
  In order for an organization to accept donations from user@example.coms,
  they must enable the Donation Kit for their organization.

  Scenario: The owner of an organization enables the Donation Kit for her organization
    Given I am logged in
    And I create a new organization called "Fractured Atlas"
    And I am on the organizations page
    When I click on "Fractured Atlas"
    And I click on "Donation Kit"
    Then I should see "Your request has been sent in for approval."
