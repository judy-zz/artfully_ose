Feature: Ordering tickets
  In order to purchase tickets
  a user wants to be able to select tickets, enter payment information, and confirm the order.

  Background:
    Given I can authorize Credit Cards in ATHENA
    Given I can save People to ATHENA
    And I can settle Credit Cards in ATHENA

  Scenario: A user is presented with an order screen when they have found tickets for purchase.
    Given I have found 3 tickets to "Jersey Boys" at "Some Theater" for $50
    When I press "Add Tickets"
    Then I should see "Shopping Cart (3)"


  Scenario: A user saves their information when confirming their order
    Given I have started an order for 3 tickets to "Jersey Boys" at "Some Theatre" for $50
    And I can save Customers to ATHENA
    And I can save Credit Cards to ATHENA
    When I check "Save my information"
    And I fill in "Password" with "password"
    And I fill in "Password confirmation" with "password"
    And I press "Purchase"
    And I should see "Successfully saved your information."

  Scenario: An anonymous user enters invalid information for their order
  Scenario: An anonymous user enters valid personal information to order
  Scenario: An anonymous user confirms their valid information
