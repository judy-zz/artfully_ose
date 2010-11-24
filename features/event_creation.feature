Feature: Event creation
  In order to create a event and its tickets
  a producer wants to be able to create a new event and have tickets generated from its details

  Background:
    Given ATHENA is up and running
    And I can save Tickets to ATHENA
    And I can get Tickets from ATHENA

  Scenario: A producer creates a new event
    Given pending
    Given I am logged in as a "producer"
      And I am on the new event page
    When I fill in "Title" with "Some Title"
      And I fill in "Venue" with "Some Venue"
      And I fill in "Seats" with "10"
      And I press "Save"
    Then I should see "Created a new event."
      And I should see "Some Title at Some Venue"
