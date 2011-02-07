Feature: Order Checkout
  In order to complete an order
  a user wants to be able to check out and enter their payment information

  @wip
  Scenario: A user checks out without saving information
    Given I have added 2 tickets to my order
    And I am on the order page
    And I follow "Checkout Now!"
    When I enter my payment details
    And I press "Purchase"
    Then I should see "Thank you for your order!"