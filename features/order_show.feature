Feature: Ordering tickets
  In order to review their order
  a user wants to be able to see the items in their current order.

  Background:
    Given I can authorize Credit Cards in ATHENA
    Given I can save People to ATHENA
    And I can settle Credit Cards in ATHENA

  Scenario: A user views items after adding a single set of tickets
    Given I have added 3 tickets to "Jersey Boys" at "Some Theater" for $50
    When I follow "Shopping Cart"
    Then I should see 3 tickets to "Jersey Boys" at "Some Theater" for $50

  Scenario: A user views items after adding multiple sets of tickets
    Given I have added 3 tickets to "Jersey Boys" at "Some Theater" for $50
    Given I have added 2 tickets to "Don Giovanni" at "Some Theater" for $100
    When I follow "Shopping Cart"
    Then I should see 3 tickets to "Jersey Boys" at "Some Theater" for $50
    And I should see 2 tickets to "Don Giovanni" at "Some Theater" for $100
    And show me the page