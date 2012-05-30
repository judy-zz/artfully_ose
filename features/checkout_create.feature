Feature: Order Checkout
  In order to complete an order
  a user wants to be able to check out and enter their payment information

  Background:
    Given I can authorize Credit Cards in ATHENA
    And I can settle Credit Cards in ATHENA
    And there is an event called "Test Event" with 3 shows with tickets

  Scenario: A user checks out with tickets
    Given I have added 2 tickets to my order for "Test Event"
    And I am on the store order page
    And I follow "Checkout Now"
    When I check "athena_payment_user_agreement"
    And I enter my payment details
    And I press "Purchase"
    Then I should see "Thank you for your order!"
    And an email confirmation for the order should have been sent

  Scenario: A user checks out with a donation
    Given I have added 1 donations to my order
    And I am on the store order page
    And I follow "Checkout Now"
    When I check "athena_payment_user_agreement"
    And I enter my payment details
    And I press "Purchase"
    Then I should see "Thank you for your order!"
    And an email confirmation for the order should have been sent

