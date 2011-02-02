Feature: Order deletion
  In order to start over
  a patron wants to be able to clear the items from their order

  Scenario: The patron has added tickets and a donation to their order
    Given I have added 2 tickets to my order
    And I have added 1 donations to my order
    And I am on the order page
    When I follow "Clear Cart"
    And I should see "You have 0 items in your cart."