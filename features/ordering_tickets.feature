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
    
  Scenario: A user saves their information when confirming their order
    Given I have started an order with the following tickets
      | id | event       | venue    | price |
      | 1  | Jersey Boys | Broadway | 50    |
    And I've entered the following Credit Card
      | cardholder_name | card_number      | expiration_date | cvv |
      | Joe Producer    | 4111111111111111 | 11/2013         | 123 |
    And I've entered the following Customer
      | first_name | last_name | phone      | email                    |
      | Joe        | Producer  | 1231231234 | joe.producer@example.com |
    And I've entered the following Billing Address
      | first_name | last_name | street_address1 | city     | state | postal_code |
      | Joe        | Producer  | 1 Producer Ave. | New York | NY    | 12005       |
    When I press "Purchase"
    

  Scenario: An anonymous user enters invalid information for their order
  Scenario: An anonymous user enters valid personal information to order
  Scenario: An anonymous user confirms their valid information
