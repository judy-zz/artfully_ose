Feature: Ticketing Kit
  In order to manage their kits
  a user wants wants to be able to view, add, and remove kits

  Scenario: A user can get to the producer activation page
    Given I am logged in
    And I follow "Dashboard"
    When I follow "Kits"
    Then I should see "Ticketing Kit"
    And I should see "Activate"