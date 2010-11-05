Feature: Ticket search
  In order to find tickets for purcahse
  a user wants to be able to enter details about existing tickets

  Scenario: Getting to the search page
    Given I am on the root page
    When I follow "Tickets"
    Then I should see "Search for Tickets"
    And I should see "Price:"
    And I should see "Performance Date:"
    And I should see "Limit number of results to"

  Scenario: Searching for Tickets
    Given I am on the tickets page
    When I fill in "Price" with "eq50"
    And I fill in "Performance Date" with "eq2002-05-30T09:00:00"
    And I fill in "Limit" with "10"
    And I press "Search"
    Then the last request to ATHENA should include "price=eq50"
    And the last request to ATHENA should include "performance=eq2002-05-30T09:00:00"
    And the last request to ATHENA should include "_limit=10"
