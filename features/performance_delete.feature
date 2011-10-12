Feature: Delete a performance
  In order to remove performances from an event
  a producer wants to be able to remove a performance form the selected event

  Scenario: A producer deletes a performance without tickets
    Given I am logged in
    And I am part of an organization with access to the ticketing kit
    And there is an Event with 3 Performances
    And I follow "Events"
    And I view the 1st Event
    When I delete the 1st Performance
    Then I should see 2 performances

  Scenario: A producer attempts to delete a live show
    Given I am logged in
    And I am part of an organization with access to the ticketing kit
    And there is an Event with 3 Performances
    And the 1st performance has had tickets sold
    And I follow "Events"
    When I view the 1st event
    Then I should not be able to delete the 1st performance
