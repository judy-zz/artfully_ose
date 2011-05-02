Feature: Donation Kit Approval
  In order to approve organizations for donations
  an admin wants to be able to view pending kit applications and approve them.

  Scenario: An admin approves a pending donation kit
    Given I am logged in as an admin
    And there is a pending donation kit application for "Fractured Atlas"
    And I am on the admin root page
    And I follow "Administer Organizations"
    When I follow "Fractured Atlas"
    And I follow "Approve"
    Then I should see "This kit has been activated"
    And the donation kit for "Fractured Atlas" should be activated

  Scenario: When an organization adds a donation kit, the admin recieves an email notification
    Given I am logged in
    And I create a new organization called "Fractured Atlas"
    And I am on the organizations page
    When I follow "Activate now"
    And I follow "Add Donation Kit"
    And I press "I am an IRS approved charity"
    When I fill in the following:
    | Legal Organization Name | Some Legal Organization Name |
    | EIN                     | 987654321                    |
    And I press "Save"
    Then an email notification for the kit should have been sent