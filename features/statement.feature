Feature: View a statement for a single show
  A producer should see a statement of a shows financial performance

  Background:
    Given I am logged in as a user with email "joe.producer@producer.com"
    And I am part of an organization with access to the ticketing kit

  Scenario: A producer views a statement
    Given there is an event called "The Walking Dead" with 3 shows with tickets
    And a user named "Bob Patron" buys 3 tickets from the 1st show
    And 10 days pass
    When I peep statements
    Then I should see a list of events
    When I follow "The Walking Dead"
    Then I should see a list of played shows
    When I view the 1st show in the list of shows
    Then I should see a statement