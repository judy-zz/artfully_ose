Feature: Ordering tickets

  In order to purchase tickets
  a user wants to be able to select tickets, enter payment information, and confirm the order.

  Scenario: A user is presented with an order screen when they have found tickets for purchase.
    Given I am on the tickets page
    And I can lock Tickets in ATHENA
    And I have found the following tickets for purchase
      | id | event       | venue    | price |
      | 1  | Jersey Boys | Broadway | 50    |
      | 2  | Jersey Boys | Broadway | 50    |
      | 3  | Jersey Boys | Broadway | 50    |
    And I fill in "price" with "eq50"
    And I press "Search"
    When I press "Buy Tickets"
    Then I should see "Enter Payment Details"
    And I should see "Customer Information"
    And I should see "Credit Card Information"
    And I should see "Billing Address"

    Scenario: An anonymous user enters invalid information for their order
    Scenario: An anonymous user enters valid personal information to order
    Scenario: An anonymous user confirms their valid information
