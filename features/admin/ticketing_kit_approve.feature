Feature: Ticketing Kit Approval
  In order to approve organizations for ticketing
  an admin wants to be able to view pending kit applications and approve them.

  Scenario: An admin approves a pending ticketing kit
    Given I am logged in as an admin
    And there is a pending ticketing kit application for "Fractured Atlas"
    And the organization "Fractured Atlas" has a bank account
    And I am on the admin root page
    And I follow "Organizations"
    When I follow "Fractured Atlas"
    And I follow "Approve"
    Then I should see "This kit has been activated"
    And the ticketing kit for "Fractured Atlas" should be activated