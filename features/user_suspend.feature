Feature: User suspension
  In order to moderate the application
  an admin wants to be able to suspend users

  Scenario: An admin searches for a user to suspend
    Given I am logged in as an "admin"
    And I am on the admin root page
    And a patron exists with an email of "patron@example.com"
    When I follow "Users"
    And I fill in "Email" with "patron@example.com"
    And I press "Search"
    Then I should see "patron@example.com"

  Scenario: An admin suspends a user
    Given I am logged in as an "admin"
    And I have found the user "patron@example.com" to suspend
    When I fill in "Reason" with "Testing the suspension feature."
    When I press "Suspend"
    Then I should see "Suspended patron@example.com"
    And I should see "Reason: Testing the suspension feature."
