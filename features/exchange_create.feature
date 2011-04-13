Feature: Exchange Tickets
  In order to provide customer service to patrons
  a producer wants to be able to exchange a set of tickets for
  an equal amount of other tickets

  Background:
    Given I am logged in
    And I am part of an organization
    And there is an event with 3 performances
    And the 1st performance has had tickets created
    And the 1st performance is on sale
    And I can save Orders in ATHENA
    And I can save purchase actions in ATHENA

  Scenario: A producer starts the exchange workflow by selecting tickets
    Given there is an order with an ID of 1 and 2 tickets
    And I look up order 1
    When I check the 1st ticket for an exchange
    And I press "Exchange"
    Then I should see "Exchanging 1 item"

  Scenario: A producer selects the tickets to exchange
    Given I have found 2 items to exchange
    When I select the 1st event
    And I select the 1st performance
    And I check 2 tickets
    And I press "Exchange these tickets"
    Then I should see "Successfully exchanged 2 items"

  Scenario:
    Given I have found 3 items to exchange
    When I select the 1st event
    And I select the 1st performance
    And I check 2 tickets
    And I press "Exchange these tickets"
    Then I should see "Unable to process exchange."