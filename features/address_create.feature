Feature: Add an address to a person record

  Scenario: A user adds an address to a person record
    Given I am logged in
    And I am part of an organization
    And there are no addresses for "person@example.com"
    And I view the people record for "person@example.com"
    When I fill out the address form
    And I press "Create Address"
    Then I should see "Successfully added an address"