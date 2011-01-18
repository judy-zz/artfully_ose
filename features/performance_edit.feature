Feature: Edit a performance
  In order to edit performances
  a producer wants to be able to change the details for a selected

  Scenario: A producer attempts to edit a performance with tickets
    Given I am logged in as a "producer" with email "joe.producer@producer.com"
    And there is an Event with 3 Performances for "joe.producer@producer.com"
    And the 1st performance is on sale
    And I follow "Events"
    When I view the 1st event
    Then I should see not be able to edit the 1st performance