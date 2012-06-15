Feature: Resellers create events
  In order to integrate their own events into the calendar
  a reseller wants to create events

  Background:
    Given I am part of an organization with access to the reselling kit
    And I am logged in
    And I have a reseller profile
    And I am on the root page

  Scenario: A reseller creates an event
    When I follow "Reseller Events"
    And I fill in the following:
       | reseller_event_name                   | A Time to ROCK!          |
       | reseller_event_producer               | Great Productions Studio |
       | reseller_event_venue_attributes_name  | One Great Place          |
       | reseller_event_venue_attributes_city  | Springfield              |
    And I select "Missouri" from "reseller_event_venue_attributes_state"
    And I press "Create Event"
    Then I should see "Your event has been created."
    And I should see "A Time to ROCK!"

  Scenario: A reseller updates an event
    Given I have a reseller event "Styx Comeback Tour"
    And I follow "Reseller Events"
    And I follow "Styx Comeback Tour"
    And I press "Edit Event"
    And I fill in "reseller_event_name" with "Quiet Jazz Songs"
    And I press "Update Event"
    Then I should see "Your event has been updated."
    And I should see "Quiet Jazz Songs"
