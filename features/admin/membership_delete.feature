Feature: Organization Membership Create

  In order to help user's manage their organization, an admin wants to be able
  to remove a user from an organization.

  Background:
    Given an organization exists with an name of "Fractured Atlas"
    And a user exists with an email of "owner@example.com"
    And "owner@example.com" is part of "Fractured Atlas"
    And a user exists with an email of "user@example.com"
    And "user@example.com" is part of "Fractured Atlas"

  Scenario: An admin removes a user from an organization
    Given I am logged in as an admin
    And I am on the admin organization page for "Fractured Atlas"
    When I remove "user@example.com" as an admin
    Then "user@example.com" should not be a part of "Fractured Atlas"