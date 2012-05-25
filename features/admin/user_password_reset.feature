Feature: Admin Password Reset

  In order to help a user who can't log in,
  an admin wants to be able to reset a that user's password.

  Scenario: An admin send's password reset instructions to a user
    Given I am logged in as an admin
    And I am on the admin users page
    And a user exists with an email of "user@example.com"
    And I fill in "query" with "user@example.com"
    And I press "Search"
    And I follow "user@example.com"
    When I press "Reset Password"
    Then a reset password email was sent to "user@example.com"
    And I should see "Instructions to reset this password have been emailed to user@example.com."