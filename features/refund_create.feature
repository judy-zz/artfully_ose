Feature: Refund Tickets
  In order to refund an order
  a producer wants to be able to select the tickets to refund

  Background:
    And I am logged in
    And I am part of an organization
    And I can refund tickets through Braintree
    And there is an order with 2 tickets

  Scenario: A producer is presented with the option to refund with or without returning to inventory
    Given I check the 1st ticket for a refund
    When I press "Refund"
    Then I should see "Refund these tickets and keep the tickets out of inventory"