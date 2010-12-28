Feature: Ticket widget
  In order to review tickets on a producer's site
  the user wants to be able to see the tickets inside the widget

  Scenario: The widget displays tickets for a given performance
    Given the following producer exists:
      | id | athena_id |
      | 1  | 1         |
    And the following event exists with 1 performance for producer with id of 1:
      | id | name       | venue      | producer      |
      | 1  | Some Event | Some Venue | Some Producer |
    And the following tickets exist in ATHENA:
      | event       | venue      | price |
      | Some Event  | Some Venue | 50    |
    And I select performance 1 for event 1 in the event widget
    When I fill in "Number of Tickets" with "1"
    And I fill in "Price" with "eq50"
    And I press "Search"
    Then I should see "Found 1 ticket"
