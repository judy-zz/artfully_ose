Feature: Organization Membership Create

  In order to help user's manage their organization, an admin wants to be able
  to add a user to an organization.

  Background:
    Given an organization exists with an name of "Fractured Atlas"
    And a user exists with an email of "user@example.com"
    And I am logged in as an admin
    And I am on the admin root page
    And I click on "Administer Organizations"
    And I click on "Fractured Atlas"

  Scenario: An admin adds a user to an organization
    Given I fill in "Email" with "user@example.com"
    When I press "Add"
    Then "user@example.com" should be a part of "Fractured Atlas"

  Scenario: An admin tries to add a user that does not exist to an organization.
    Given I fill in "Email" with "nobody@example.com"
    When I press "Add"
    Then I should see "User nobody@example.com could not be found."

  Scenario: An admin tries to add the a user with an existing membership
    Given "user@example.com" is part of "Fractured Atlas"
    And I fill in "Email" with "user@example.com"
    When I press "Add"
    Then I should see "user@example.com is already a member, and was not added a second time."
