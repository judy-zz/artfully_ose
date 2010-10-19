Feature: Transactions and ticket sales
  In order to create a transaction for ticket sales
  a user
  wants to be able to select and purchase existing tickets

  Scenario: Selecting tickets for purchase
    Given I have found 3 tickets for purchase
    When I press "Buy Now"
    Then I should see "Please enter a method of payment"
