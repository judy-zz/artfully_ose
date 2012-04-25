Feature: Become User Feature

  In order to administer the site, an admin wants to be able to sign in as any user.

  Scenario: An admin removes a user from an organization
    Given I am logged in as an admin
    And a user exists with an email of "user@example.com"
    And I follow "Users"
    And I search for "user@example.com"
    And I press "Search"
    And I follow "user@example.com"
    When I press "Sign in as user@example.com"
    Then I should be on the root page
    And I should see "user@example.com"