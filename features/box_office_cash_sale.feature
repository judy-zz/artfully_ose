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
    Given there are 2 tickets available
    When I select "2" from "Balcony"
    And I press "Next"
    Then I should see 2 tickets
    And I should see "Checkout using an existing person record."
    And I should see "Checkout using an anonymous person record."

  Scenario: A producer finds a person for the sale
    Given there are 2 tickets available
    And I select "2" from "Balcony"
    And I press "Next"
    When I find a customer record for the order
    Then I should see "Checkout Confirmation"
    And I should see 2 tickets

  Scenario: A producer confirms the order in the box office
    Given I can save Orders in ATHENA
    And there are 2 tickets available
    And I select "2" from "Balcony"
    And I press "Next"
    And I find a customer record for the order
    When I press "Checkout"
    Then I should see "Items succesfully purchased."
