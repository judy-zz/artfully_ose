Feature: View a settlement
  In order to keep track of money received, a producer
  wants to be able to view the details of settlements.

  Scenario: A producer views a list of settlements
    Given I am logged in
    And I am part of an organization "Fractured Atlas"
    And there are 5 settlements for "Fractured Atlas"
    When I follow "Settlements"
    Then I should see 5 settlements
