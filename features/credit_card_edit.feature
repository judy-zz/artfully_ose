Feature: Edit a credit card
  In order to change credit card details
  a registered user wants to be able to update their saved credit cards

  Scenario: A user edits their saved credit card
    Given I am logged in as a "patron" with email "joe.patron@example.com"
    And there are 3 saved credit cards for "joe.patron@example.com"
    And I navigate to my credit cards page
    And show me the page
    When I update 1st credit card details with:
      | cardholder_name | card_number          | CVV |
      | Joe Producer    | 371449635398431 | 789 |
    And I press "Submit"
    And show me the page
    Then the 1st credit card should be:
      | cardholder_name | card_number          | CVV |
      | Joe Producer    | 371449635398431 | 789 |
