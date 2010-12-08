Feature: Performance Widget
  In order to let users search for tickets
  the widget should display performance information for rendering in an iframe

  Scenario: The widget display performance information with ticket filter options
    Given the following producer exists:
      | id | athena_id |
      | 1  | 1         |
    And the following event exists with 1 performance for producer with id of 1:
      | id | name       | venue      | producer      |
      | 1  | Some Event | Some Venue | Some Producer |
    When I select performance 1 for event 1 in the event widget
    Then I should see "Some Event"
    And I should see "Number of Tickets"
    And I should see "Price"

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
