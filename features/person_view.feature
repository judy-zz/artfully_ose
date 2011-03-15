Feature: View the record for a person
  In order to view a history and perform actions
  a user wants to be able to view the details of a People record

  Scenario: A user views the Person Record for another user
    Given I am logged in
    And I am on the people page
    And an athena person exists with an email of "person@example.com"
    When I fill in "Email Address" with "person@example.com"
    And I press "Search"
    Then I should see "People Record for person@example.com"

  Scenario: A user attempts to view a Person Record for a non-existent user
    Given I am logged in
    And I am on the people page
    When I fill in "Email Address" with "doesnotexist@example.com"
    And I press "Search"
    Then I should see "Oops! No people records for this email address."