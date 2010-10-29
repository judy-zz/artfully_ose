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
