Feature: Door List Creation
  In order to view the user@example.coms attending a performance
  the producer wants to be able to view a list of names

  Background:
    Given I am logged in
    And I am part of an organization with access to the ticketing kit
    And there is an Event with 3 Performances
    And the 1st performance has had tickets created
    And the 1st performance is on sale

  Scenario: A producer views the door list for a performance
    Given a user@example.com named "Joe Patron" buys 2 tickets from the 1st performance
    And a user@example.com named "Bob Patron" buys 3 tickets from the 1st performance
    When I go to the events page
    And I view the 1st event
    And I view the 1st performance
    And I press "Door List"
    Then I should see "Patron, Joe"
    And I should see "Patron, Bob"
