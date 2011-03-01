Feature: Admin Password Reset

  In order to help a user who can't log in,
  an admin wants to be able to reset a that user's password.

  Scenario: An admin send's password reset instructions to a user
    Given I am logged in as an "admin"
    And I click on "Administration"
    And I click on "Administer Users"
    And a patron exists with an email of "patron@example.com"
    And I fill in "Email" with "patron@example.com"
    And I press "Search"
    When I press "Send Password Reset Instructions"
    Then a reset password email was sent to "patron@example.com"
    And I should see "Instructions to reset this password have been emailed to patron@example.com."