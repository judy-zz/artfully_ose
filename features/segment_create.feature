Feature: Segment creation
  As a producer
  I want to create list segments
  In order to refer to the same group of people repeatedly

  Scenario: A producer creates a new list segment from a people search
    Given I am logged in
    And I am part of an organization
    And there are 5 people tagged with "donor"
    And I do an advanced search for people tagged with "donor"
    When I follow "Create List Segment"
    And I fill in "segment_name" with "New Segment"
    And I press "Save"
    Then I should see "List Segment: New Segment"
    And I should see 5 people
