Feature: Credit Card Creation
  In order to pay for services a user wants to be able to add a credit card to their account

  Background:
    Given I am logged in
    And I am on the root page
    And I follow "Credit Cards"

  Scenario: A user creates a credit card without an existing customer record
    Given I follow "New Credit Card"
    When I fill in valid credit card details
    And I fill in valid customer details
    And I press "Save Card"
    Then I should see 1 credit cards in the credit card list

  Scenario: A user creates a credit card but does fill out valid customer information
    Given I follow "New Credit Card"
    When I fill in valid credit card details
    And I press "Save Card"
    Then I should see "There was a problem saving your customer information."

  Scenario: A user fills out the customer information without any credit card information
    Given I follow "New Credit Card"
    When I fill in valid customer details
    And I press "Save Card"
    Then I should see "There was a problem saving your customer information."

  Scenario: A user creates a credit card with an existing customer record
    Given I have a customer record
    And I follow "New Credit Card"
    When I fill in valid credit card details
    And I press "Save Card"
    Then I should see 1 credit cards in the credit card list