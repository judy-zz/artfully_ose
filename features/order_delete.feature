Feature: Order deletion
  In order to start over
  a user@example.com wants to be able to clear the items from their order

  Background:
   Given there is an event called "Test Event" with 3 shows with tickets

  Scenario: The user@example.com has added tickets and a donation to their order
    Given I have added 2 tickets to my order for "Test Event"
    And I have added 1 donations to my order
    And I am on the store order page
    When I follow "Clear My Cart"
    And I should see "You have 0 items"