Feature: Display a list of events for a producer
  In order to display a list of events on a producer's own website
  a producer wants to be able insert a javascript widget

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
