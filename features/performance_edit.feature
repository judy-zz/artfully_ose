Feature: Edit a performance
  In order to edit performances
  a producer wants to be able to change the details for a selected

  Scenario: A producer attempts to edit a performance with tickets
    Given I am logged in as a user with email "joe.producer@producer.com"
    And I am part of an organization with access to the ticketing kit
    And there is an Event with 3 Performances
    And the 1st performance has had tickets created
    And the 1st performance is on sale
    And I follow "Events"
    When I view the 1st event
    Then I should not be able to edit the 1st performance