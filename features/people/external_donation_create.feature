Feature: Create a give action
  A user wants to be able to enter an external donation

  Background:
    Given I am logged in
    And I am part of an organization
    And I am looking at "Joe Montana"

  Scenario: Joe Montana donates 40 dollars
    When I follow "Give"
    Then I should see "Joe Montana"
    And I should see "Record Contribution"
    And I enter a donation of "40" on "2012-03-03"
    And I go to the contributions page
    And I should see "Contributions"
    And I search for contributions between "2012-03-01" and "2012-03-30"
    And show me the page
    And I should see the contribution of "40" from "Joe Montana" made on "2012-03-03"