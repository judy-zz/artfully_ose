Feature: Refund Tickets
  In order to refund an order
  a producer wants to be able to select the tickets to refund

  Background:
    Given I can refund tickets through ATHENA
    And I can save purchase actions in ATHENA
    And I am logged in
    And I am part of an organization
    And there is an order with an ID of 1 and 2 tickets
    And I am on the orders page
    And I fill in "search" with "1"
    And I press "Search"

  Scenario: A producer refunds a ticket
    Given I check the 1st ticket for a refund
    When I press "Refund"
    Then I should see "Successfully refunded 1 tickets."
