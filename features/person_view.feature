Feature: View the record for a person
  In order to view a history and perform actions
  a user wants to be able to view the details of a People record

  @wip
  Scenario: A user views the Person Record for another user
    Given I am logged in
    And I am on the people page
    And I am part of an organization
    And an athena person exists with an email of "person@example.com" for my organization
    When I fill in "search" with "person@example.com"
    And I press "Search"
    Then I should see "person@example.com"

  @wip
  Scenario: A user attempts to view a Person Record for a non-existent user
    Given I am logged in
    And I am on the people page
    When I fill in "search" with "doesnotexist@example.com"
    And I press "Search"
    Then I should see "No results found."