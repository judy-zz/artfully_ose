Feature: Cash Sales
  In order to make cash sales
  a produce wants a box office interface that allows them to create new orders

  Background:
    Given I am logged in
    And I am part of an organization with access to the ticketing kit
    And there is an Event with 3 Performances
    And the 1st performance has had tickets created
    And the 1st performance is on sale
    And I go to the events page
    And I view the 1st event
    And I view the 1st performance
    And I press "Box Office"

  Scenario: A producer creates an order in the box office
    When I press "Next"
    Then I should see 1 tickets

