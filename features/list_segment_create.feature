Feature: Order creation
  In order to work with groups of people
  a producer wants to be able to create list segments from searches

  Scenario: A producer searches for a group of people to create a new list segment
    Given I am logged in
    And I am part of an organization
    And there are 5 people tagged with "donor"
    And I search for people tagged with "donor"
    When I press "New List Segment"
    And I fill in "Name" with "New Segment"
    And I save the list segment
    Then I should see 5 people