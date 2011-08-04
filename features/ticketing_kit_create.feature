Feature: Ticketing Kit
  In order to use ticketing features
  a user wants to activate the ticketing kit for their organization

  Background:
    Given I can save Credit Cards to ATHENA

  Scenario: A user activates the ticketing kit with a credit and organization
    Given I am logged in
    And I have 2 saved credit cards
    And I create a new organization called "Fractured Atlas"
    When I follow "My Organization"
    And I follow "Activate Paid Event Ticketing Kit"
    And I press "Submit Activation Request"
    Then I should see "Your request has been sent in for approval."

  Scenario: A user activates the ticketing kit without a credit card
    Given I am logged in
    And I create a new organization called "Fractured Atlas"
    When I follow "My Organization"
    And I follow "Activate Paid Event Ticketing Kit"
    And I press "Submit Activation Request"
    Then I should see "Your request has been sent in for approval."