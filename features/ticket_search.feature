Feature: Ticket search
  In order to find tickets for purcahse
  a user
  wants to be able to enter details about existing tickets

  Scenario: Selecting tickets for purchase
    Pending
    Given the following ticket exists:
      | id | EVENT       | VENUE    | PERFORMANCE         |
      | 1  | Jersey Boys | Broadway | 2002-05-30T09:00:00 |
      | 2  | Jersey Boys | Broadway | 2002-05-30T09:00:00 |
      | 3  | Jersey Boys | Broadway | 2002-05-30T09:00:00 |
      And I have
    When I fill in "Performance Date" with "2002-05-30T09:00:00"
      And I press "Search"
