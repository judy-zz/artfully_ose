Feature: Cash Sales
  In order to make cash sales
  a produce wants a box office interface that allows them to create new orders

  Background:
    Given I can save Orders in ATHENA
    And I am logged in
    And I am part of an organization with access to the ticketing kit
    And my organization has a dummy person record
    And there is an Event with 3 Performances
    And the 1st performance has had tickets created
    And the 1st performance is on sale
    And I go to the events page
    And I view the 1st event
    And I view the 1st performance
    And I press "Box Office"

  Scenario: A producer creates an anonymous cash sale in the box office
    And there are 2 tickets available
    And I select "2" from "Balcony"
    When I press "Checkout"
    Then I should see "Items successfully purchased."