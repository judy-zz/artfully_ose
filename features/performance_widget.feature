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
    And show me the page
