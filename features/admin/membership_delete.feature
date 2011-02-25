Feature: Organization Membership Create

  In order to help user's manage their organization, an admin wants to be able
  to add a user to an organization.

  Background:
    Given an organization exists with an name of "Fractured Atlas"
    And a patron exists with an email of "patron@example.com"
    And "patron@example.com" is part of "Fractured Atlas"

  Scenario: An admin adds a user to an organization
    Given I am logged in as an "admin"
    And I am on the admin root page
    And I click on "Administer Organizations"
    And I click on "Fractured Atlas"
    When I click the link to remove "patron@example.com"
    Then "patron@example.com" should not be a part of "Fractured Atlas"