Feature: Organization Creation
  In order to access site features and group employees
  a registered user wants to be able to create an organization

  Scenario: A registered user creates an organization
    Given I am logged in
    And I click on "My Organization"
    When I fill in "Organization Name" with "My Organization"
    And I press "Create"
    And I should be a part of the organization "My Organization"

    @wip
    Scenario: A registered user creates an organization
      Given I am logged in
      And I am part of an organization "Fractured Atlas"
      And I click on "My Organization"
      When I click on "New Organization"
      Then I should see "You can only join one organization at this time."
