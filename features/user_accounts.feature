Feature: User accounts
  In order to use the application
  a user wants wants to be able to sign in with their registered account.

  When visiting Artful.ly for the first time a user should be shown the splash page,
  then they should be able to log in and see the dashboard.

  Scenario: Sign in as a user
    Given I am on the new user session page
    And the following user exists:
      | email            | password |
      | user@example.com | changeme |
    When I fill in "Email" with "user@example.com"
    And I fill in "Password" with "changeme"
    And I press "Sign in"
    Then I should see "Dashboard"

  Scenario: A user sees the splash page and logs in
    Given I am on the root page
    And I follow "Sign in"
    And the following user exists:
      | email            | password |
      | user@example.com | changeme |
    When I fill in "Email" with "user@example.com"
    And I fill in "Password" with "changeme"
    And I press "Sign in"
    Then I should see "Dashboard"

  Scenario: A user signs out
    Given I am logged in
    And I am on the root page
    When I follow "Sign Out"
    Then I should be on the root page

