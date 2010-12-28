Feature: Display a list of events for a producer
  In order to display a list of events on a producer's own website
  a producer wants to be able insert a javascript widget

  @wip
  Scenario: A producer puts the event list widget on their website
    Given the following producer exists:
    | id | athena_id |
    | 1  | 1         |
    And the following event exists with 1 performance for producer with id of 1:
    | id | name       | venue      | producer      |
    | 1  | Some Event | Some Venue | Some Producer |
    And I send and accept JSON
    When I send a GET request for "/users/1/events/1.jsonp?callback=parse"
    Then the response should be "200"
    And the response should be JSONP with callback "parse"
    And the response should be JSON with callback "parse" for the following events:
    | id | name       | venue      | producer      |
    | 1  | Some Event | Some Venue | Some Producer |

  Scenario: A producer views the source code for an event widget
    Given I am logged in as a "producer" with email "producer@example.com"
    And the following event exists in ATHENA for "producer@example.com"
    | name       | venue      | producer      |
    | Some Event | Some Venue | Some Producer |
    And I am on the events page
    When I follow "Some Event"
    Then I should see "Widget!"
    And the "widget-display" field should contain "display_event"
    And the "widget-display" field should contain "display_performances"