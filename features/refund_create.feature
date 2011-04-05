Feature: Refund Tickets
  In order to refund an order
  a producer wants to be able to select the tickets to refund

  Background:
    Given there is an order with an ID of 1 and 2 tickets
    And I am on the orders page
    And I fill in "search" with "1"
    And I press "Search"

  @wip
  Scenario: A producer refunds a ticket
    Given I check for 1st ticket for a refund
    When I press "Refund"
    Then the 1st ticket should be refunded
    And I should see "Refunded 1 ticket."
    And show me the page
