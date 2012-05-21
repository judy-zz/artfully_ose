Feature: User Search

  In order to find users, an admin wants to be able to search based on email address OR organization name.

  Background:
    Given I am logged in as an admin
    And I follow "Users"

  Scenario: An admin searches by email address
    Given a user exists with an email of "user@example.com"
    When I fill in "query" with "user@example.com"
    And I press "Search"
    Then I should see "user@example.com" in the search results

  Scenario: An admin searches by partial organization name
    Given a user exists with an email of "user@example.com"
    And an organization exists with a name of "FBI"
    And "user@example.com" is part of "FBI"
    When I fill in "query" with "F"
    And I press "Search"
    Then I should see "user@example.com" in the search results
    And I should see "FBI"

  Scenario: An admin searches for a non-existent user
    Given there is no user with an email of "user@example.com"
    And there is no organization with a name of "user@example.com"
    When I fill in "query" with "user@example.com"
    And I press "Search"
    Then I should not see "user@example.com" in the search results