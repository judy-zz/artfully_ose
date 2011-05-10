Feature: Return Tickets
  In order to return an order
  a producer wants to be able to select the tickets to return

  Background:
    Given I can save purchase actions in ATHENA
    And I can save Orders in ATHENA
    And I am logged in
    And I am part of an organization
    And there is an order with an ID of 1 with 2 comps
    And I am on the orders page
    And I fill in "search" with "1"
    #And I press "Search"
  @wip
  Scenario: A producer returns a ticket
    Given I check the 1st ticket for a return
    When I press "Return"
    Then I should see "Successfully returned 1 tickets."
