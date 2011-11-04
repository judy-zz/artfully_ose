Feature: Order creation
  In order to buy items and make donations
  a user wants to be able to add items to their order

  Background:
   Given there is an event called "Test Event" with 3 shows with tickets
   And the organization that owns "Test Event" has a donation kit

  Scenario: The user@example.com has added tickets to their order
    Given I have added 2 tickets to my order for "Test Event"
    When I am on the store order page
    Then I should see 2 tickets
    And I should see "You have 2 items"

  Scenario: The user@example.com has added a donation to their order
    Given I have added 1 donations to my order
    When I am on the store order page
    Then I should see 1 donations
    And I should see "You have 1 item"

  Scenario: The user@example.com has added tickets and a donation to their order
    Given I have added 2 tickets to my order for "Test Event"
    And I have added 1 donations to my order
    When I am on the store order page
    Then I should see 2 tickets
    And I should see 1 donations
    And I should see "You have 3 items"

  Scenario: The user@example.com added tickets to the order and then wants to include a donation
    Given I have added 2 tickets to my order for "Test Event"
    And I am on the store order page
    When I fill in "Add a Donation" with "5000"
    And I press "Make Donation"
    Then I should see "Donation to"
    And I should see "$50"