Feature: Refund Tickets
  In order to refund an order
  a producer wants to be able to select the tickets to refund

  Background:
    Given I can refund tickets through ATHENA
    And I can save purchase actions in ATHENA
    And I can save Orders in ATHENA
    And I am logged in
    And I am part of an organization
    And there is an order with an ID of 1 and 2 tickets

  Scenario: A producer is presented with the option to refund with or without returning to inventory
    Given I check the 1st ticket for a refund
    When I press "Refund"
    Then I should see "Refunding 1 item."

  Scenario: A producer refunds and returns a ticket
    Given I check the 1st ticket for a refund
    When I press "Refund"
    And I press "Refund and Return"
    Then I should see "Successfully refunded and returned 1 tickets."

  Scenario: A producer refunds a ticket without returning it to inventory
    Given I check the 1st ticket for a refund
    When I press "Refund"
    And I press "Just Refund"
    Then I should see "Successfully refunded 1 tickets."