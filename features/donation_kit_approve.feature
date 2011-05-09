Feature: Donation Kit Approval
  In order to approve organizations for donations
  an admin wants to be able to view pending kit applications and approve them.

  Scenario: An admin approves a pending donation kit
    Given I am logged in as an admin
    And there is a pending regular donation kit application for "Fractured Atlas"
    And I am on the admin root page
    And I follow "Administer Organizations"
    When I follow "Fractured Atlas"
    And I follow "Approve"
    Then I should see "This kit has been activated"
    And the regular donation kit for "Fractured Atlas" should be activated

  Scenario: An admin approves a pending donation kit
    Given I am logged in as an admin
    And there is a pending sponsored donation kit application for "Fractured Atlas"
    And I am on the admin root page
    And I follow "Administer Organizations"
    When I follow "Fractured Atlas"
    And I follow "Approve"
    Then I should see "This kit has been activated"
    And the regular sponsored kit for "Fractured Atlas" should be activated