Feature: Order Checkout
  In order to complete an order
  a user wants to be able to check out and enter their payment information

  Background:
    Given I can authorize Credit Cards in ATHENA
    And I can settle Credit Cards in ATHENA
    And I can save Orders in ATHENA
    And I can save purchase actions in ATHENA

  Scenario: A user checks out without saving information
    Given I have added 2 tickets to my order
    And I am on the store order page
    And I follow "Checkout Now"
    When I enter my payment details
    And I press "Purchase"
    Then I should see "Thank you for your order!"
    And an email confirmation for the order should have been sent