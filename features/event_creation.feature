Feature: Event creation
  In order to create a event and its tickets
  a producer wants to be able to create a new event and have tickets generated from its details

  Background:
    Given I can save Tickets to ATHENA
    And I can get Tickets from ATHENA

  Scenario: A producer creates a new event
    Given I am logged in as a "producer"
    And I am on the new event page
    When I fill in the following event details:
    | name      | venue      | city     | state | producer      |
    | Some Name | Some Venue | New York | NY    | Some Producer |
    And I press "Submit"
    Then I should see "Your event has been created."
    And I should see "Some Name"
    And I should see "Some Venue"
    And I should see "New York, NY"
