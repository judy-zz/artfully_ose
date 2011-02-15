Feature: Organization Creation
  In order to access site features and group employees
  a registered user wants to be able to create an organization

  Scenario: A registered user creates an organization
    Given I am logged in
    And I click on "Organizations"
    And I click on "New Organization"
    When I fill in "Name" with "My Organization"
    And I press "Create"
    Then I should see "My Organization has been created"
    And I should be a part of the organization "My Organization"