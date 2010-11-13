Feature: Ordering tickets

  In order to purchase tickets
  a user wants to be able to select tickets, enter payment information, and confirm the order.

  Scenario: A user
    Given I have found the following tickets for purchase
      | id | EVENT       | VENUE    | PERFORMANCE         |
      | 1  | Jersey Boys | Broadway | 2002-05-30T09:00:00 |
      | 2  | Jersey Boys | Broadway | 2002-05-30T09:00:00 |
      | 3  | Jersey Boys | Broadway | 2002-05-30T09:00:00 |
    When I press "Buy Tickets"
    Then I should see "Enter a Method of Payment"

    Scenario: An anonymous user enters invalid information for their order
    Scenario: An anonymous user enters valid personal information to order
    Scenario: An anonymous user confirms their valid information