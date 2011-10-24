Feature: Settling with producers
  The application should automatically settle shows
  and donation via FirstACH

  Scenario: Settling a show
    Given there is a settleable show for "Some Event"
    When the settlement job runs
    Then there should be a settlement for the show
    And the shows sales should be settled

  Scenario: Settling donations
    Given there are settleable donations for the organization "Fractured Atlas"
    When the settlement job runs
    Then the donations should be settled