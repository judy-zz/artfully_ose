Feature: Segment deletion
  As a producer
  I want to delete list segments
  In order to clean the segment list of unnecessary information

  Scenario: A producer deletes a list segment
    Given I am logged in
    And I am part of an organization
    And there is a list segment called "Segment 1"
    And I go to the segments page
    When I follow "Delete"
    Then I should not see "Segment 1"
