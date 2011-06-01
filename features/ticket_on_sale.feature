Feature: Putting Tickets on Sale
  In order to sell tickets to patrons
  a producer wants to be able to mark certain tickets as on sale.

  Background:
    Given I am logged in
    And I am part of an organization with access to the ticketing kit
    And there is an Event with 3 Performances
    And the 1st performance has had tickets created
    And I follow "Events"
    And I view the 1st event
    And I view the 1st performance

  Scenario: A producer puts tickets for a performance on sale
    Given I check the 1st ticket to put on sale
    And I press "Put on Sale"
    And I press "Put on Sale"
    Then the 1st ticket should be on sale