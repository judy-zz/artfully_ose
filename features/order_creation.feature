Feature: Order creation
  In order to buy items and make donations
  a patron wants to be able to add items to their order

  Scenario: The patron has added tickets to their order
    Given I have added 2 tickets to my order
    When I am on the order page
    Then I should see 2 tickets
    And I should see "You have 2 items in your cart."

  Scenario: The patron has added a donation to their order
    Given I have added 1 donations to my order
    When I am on the order page
    Then I should see 1 donations
    And I should see "You have 1 item in your cart."

  Scenario: The patron has added tickets and a donation to their order
    Given I have added 2 tickets to my order
    And I have added 1 donations to my order
    When I am on the order page
    Then I should see 2 tickets
    And I should see 1 donations
    And I should see "You have 3 items in your cart."

  Scenario: The patron added tickets to the order and then wants to include a donation
    Given I have added 2 tickets to my order
    And I am on the order page
    When I fill in "Amount" with "50"
    And I press "Add Donation"
    Then I should see "Donation for 50"