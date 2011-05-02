Feature: Donation Kit
  In order for an organization to accept donations from user@example.coms,
  they must enable the Donation Kit for their organization.

  Scenario: The owner of an organization enables the 501(c)(3) Donation Kit for her organization
    Given I am logged in
    And I create a new organization called "Fractured Atlas"
    And I am on the organizations page
    And I follow "Activate now"
    And I follow "Add Donation Kit"
    And I press "I am an IRS approved charity"
    When I fill in the following:
    | Legal Organization Name | Some Legal Organization Name |
    | EIN                     | 987654321                    |
    And I press "Save"
    And I press "Back to my kits"
    Then I should see "Pending"
