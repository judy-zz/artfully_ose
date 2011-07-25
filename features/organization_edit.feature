Feature: Organization Creation
  In order to change information about their organization
  a registered user wants to be able to update the details

  Scenario: A registered user creates an organization
    Given I am logged in
    And I am part of an organization
    And I follow "My Organization"
    And I follow "Edit Organization"
    When I fill in "Organization Name" with "My Organization"
    And I press "Update"
    And I should be a part of the organization "My Organization"

    @wip
    Scenario: A registered user creates an organization
      Given I am logged in
      And I am part of an organization "Fractured Atlas"
      And I follow "My Organization"
      When I follow "New Organization"
      Then I should see "You can only join one organization at this time."
