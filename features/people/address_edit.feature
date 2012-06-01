Feature: Edit an address for a person record

  Scenario: A user edits the address on a person record
    Given I am logged in
    And I am part of an organization
    And there is an address for the people record for "person@example.com"
    And I view the people record for "person@example.com"
    When I fill out the address form
    And I press "Update Address"
    Then I should see "Successfully updated the address"