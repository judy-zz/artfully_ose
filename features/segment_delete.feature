Feature: Segment deletion
  As a producer
  I want to delete list segments
  In order to clean the segment list of unnecessary information

  Scenario: A producer deletes a list segment
    Given I am logged in
    And I am part of an organization
    And there is a list segment called "Segment 1"
    And I am on the segment page for "Segment 1"
    And I decide I don't want it any more so I click Delete
    And I go to the segments page
    Then I should not see "Segment 1"
