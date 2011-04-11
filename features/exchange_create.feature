Feature: Exchange Tickets
  In order to provide customer service to patrons
  a producer wants to be able to exchange a set of tickets for
  an equal amount of other tickets

  Scenario: A producer starts the exchange workflow by selecting tickets
    Given I am logged in
    And I am part of an organization
    And there is an order with an ID of 1 and 2 tickets
    And I look up order 1
    When I check the 1st ticket for an exchange
    And I press "Exchange"
    And show me the page
    Then I should see "Exchanging 1 ticket"