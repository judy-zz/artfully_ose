Feature: Delete a credit card
  In order to remove an existing credit card
  a registered user wants to be able to remove their saved credit cards

  Scenario: A user deletes their saved credit card
    Given I am logged in as a "patron" with email "joe.patron@example.com"
    And there are 3 saved credit cards for "joe.patron@example.com"
    And I navigate to my credit cards page
    When I delete the 1st credit card
    Then I should see 2 credit cards in the credit card list