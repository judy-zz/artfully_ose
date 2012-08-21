Feature: Order creation
  In order to work with groups of people
  a producer wants to be able to create list segments from searches

  Scenario: A producer searches for a group of people to create a new list segment
    Given I am logged in
    And I am part of an organization
    And there are 5 people tagged with "donor"
    And I do an advanced search for people tagged with "donor"
    And show me the page
    When I follow "Create List Segment"
    And I fill in "segment_name" with "New Segment"
    And I press "Save"
    Then I should see "List Segment: New Segment"
    And I should see 5 people