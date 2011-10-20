Feature: Door List Creation
  In order to view the user@example.coms attending a show
  the producer wants to be able to view a list of names

  Background:
    Given I am logged in
    And I am part of an organization with access to the ticketing kit
    And there is an Event with 3 Shows
    And the 1st show has had tickets created
    And the 1st show is on sale

  Scenario: A producer views the door list for a show
    Given a user@example.com named "Joe Patron" buys 2 tickets from the 1st show
    And a user@example.com named "Bob Patron" buys 3 tickets from the 1st show
    When I go to the events page
    And I view the 1st event
    And I view the 1st show
    And I press "Door List"
    And show me the page
    Then I should see "Joe Patron"
    And I should see "Bob Patron"
