Feature: Ticketing Kit
  In order to use ticketing features
  a user wants to activate the ticketing kit for their organization

  Background:
    Given I can save Credit Cards to ATHENA

  @wip
  Scenario: A user activates the ticketing kit with a credit and organization
    Given I am logged in
    And I have 2 saved credit cards
    And I create a new organization called "Fractured Atlas"
    And I am on the organizations page
    When I click on "Fractured Atlas"
    And I click on "Ticketing Kit"
    Then I should see "Congratulations, you've activated the TicketingKit"

  @wip
  Scenario: A user activates the ticketing kit without a credit card
    Given I am logged in
    And I create a new organization called "Fractured Atlas"
    And I am on the organizations page
    When I click on "Fractured Atlas"
    And I click on "Ticketing Kit"
    Then I should see "You need at least one credit card to activate this kit"