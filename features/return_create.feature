Feature: Return Tickets
  In order to return an order
  a producer wants to be able to select the tickets to return

  Background:
    And I am logged in
    And I am part of an organization
    And there is an order with 2 comps

  Scenario: A producer returns a ticket
    Given I check the 1st ticket for a return
    When I press "Return"
    Then I should see "Successfully returned 1 tickets."
