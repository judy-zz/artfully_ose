Feature: Ticketing Kit
  In order to use ticketing features
  a user wants to activate the ticketing kit for their organization

  Background:
    Given I can save Credit Cards to ATHENA

  Scenario: A user activates the ticketing kit
    Given I am logged in
    And I have 2 saved credit cards
    And I create a new organization called "Fractured Atlas"
    And I view my organization page
    And I activate the "Ticketing Kit"
    And I press "Submit Activation Request"
    Then I should see "Your request has been sent in for approval."