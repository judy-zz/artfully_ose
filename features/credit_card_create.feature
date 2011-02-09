Feature: Credit Card Creation
  In order to pay for services
  a user wants to be able to add a credit card to their account

  Scenario: A user creates a credit card
    Given I am logged in
    And I am on the root page
    When I click on "Credit Cards"
    And I click on "New Credit Card"
    And I fill in valid credit card details
    And I press "Create"
    Then I should see 1 credit cards in the credit card list