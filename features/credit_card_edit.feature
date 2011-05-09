Feature: Edit a credit card
  In order to change credit card details
  a registered user wants to be able to update their saved credit cards

  @wip
  Scenario: A user edits their saved credit card
    Given I am logged in as a user with email "joe.user@example.com"
    And there are 3 saved credit cards for "joe.user@example.com"
    And I navigate to my credit cards page
    When I update 1st credit card details with:
      | cardholder_name |
      | Joe Producer    |
    And I press "Submit"
    Then the 1st credit card should be:
      | cardholder_name |
      | Joe Producer    |