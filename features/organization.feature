Feature: Organization

  Scenario: A registered user creates an organization
    Given I am logged in
    And I follow "create your own"
    When I fill in "Organization Name" with "My Organization"
    And I press "Create"
    And I should be a part of the organization "My Organization"

  Scenario: A registered user cannot create a second organization
    Given I am logged in
    And I am part of an organization
    And I am on the home page
    Then I should not see "create your own"