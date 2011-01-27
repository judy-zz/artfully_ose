Feature: Ticketing Kit
  In order to use ticketing features
  a user wants wants to be able to activate the ticketing kit

  Background:
    Given I can save Credit Cards to ATHENA

  Scenario: A user activates the ticketing kit with a credit and organization
    Given I am logged in as a "user" with email "joe@user.com"
    And there are 2 saved credit cards for "joe@user.com"
    And "joe@user.com" is part of an organization
    When I am on the kits page
    And I follow "Add Ticketing Kit"
    Then I should see "Congratulations, you've activated the ticketing kit"

  @wip
  Scenario: A user activates the ticketing kit without a credit card

  @wip
  Scenario: A user activates the ticketing kit without an organization