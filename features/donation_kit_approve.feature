Feature: Donation Kit Approval
  In order to approve organizations for donations
  an admin wants to be able to view pending kit applications and approve them.

  Scenario: An admin approves a pending donation kit
    Given I am logged in as an admin
    And there is a pending donation kit application for "Fractured Atlas"
    And I am on the admin root page
    And I click on "Administer Organizations"
    When I click on "Fractured Atlas"
    And I click on "Approve"
    Then I should see "This kit has been activated"
    And the donation kit for "Fractured Atlas" should be activated