Feature: Sponsored Donation Kit
  In order for an organization to accept donations from user@example.coms,
  they must enable the Donation Kit for their organization.

  Background:
    Given I am logged in
    And I create a new organization called "Fractured Atlas"
    When I follow "My Organization"

  Scenario: The owner of an organization enables the Sponsored Donation Kit for her organization
    Given my organization is connected to a Fractured Atlas membership
    And my organization has a website
    When I follow "Activate Sponsored Donation Kit"
    And I follow "I have a fiscally sponsored project with Fractured Atlas"
    And I follow "Activate Sponsored Donation Kit"
    Then I should see "Pending"

  Scenario: The owner of an organization enters tax info and then activates the Sponsored Donation Kit for her organization
    Given my organization has a website
    And I follow "Activate Sponsored Donation Kit"
    And I follow "I have a fiscally sponsored project with Fractured Atlas"
    And the credentials I'll enter are valid
    When I fill in "Account Email" with "account@fracturedatlas.org"
    And I fill in "Account Password" with "somepassword"
    And I press "Connect"
    Then I should see "You meet the requirements for this kit."
    And I follow "Activate Sponsored Donation Kit"
    And I should see "Pending"

  Scenario: The owner of an organization enters tax info and then activates the Sponsored Donation Kit for her organization
    Given my organization is connected to a Fractured Atlas membership
    And I follow "Activate Sponsored Donation Kit"
    And I follow "I have a fiscally sponsored project with Fractured Atlas"
    When I fill in "Website" with "http://test.com"
    And I press "Update Website"
    Then I should see "You meet the requirements for this kit."
    And I follow "Activate Sponsored Donation Kit"
    And I should see "Pending"