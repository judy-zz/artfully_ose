Feature: Resellers have profiles
  In order to promote their service to producers
  a user wants their reselling organization to have a profile

  Background:
    Given I am part of an organization with access to the reselling kit
    And I am logged in

  Scenario: A user wants access to the reseller settings
    Then my organization should have the "reseller" kit
    And I should see "Reseller Settings"

  Scenario: A user wants to see their reseller profile
    When I follow "Reseller Settings"
    Then I should see "Url"
    And I should see "Description"

  Scenario: A user wants to update their reseller profile
    When I follow "Reseller Settings"
    And I fill in "Url" with "http://example.com"
    And I fill in "Description" with "a great example"
    And I fill in "Fee" with "$2.71"
    And I press "Update Profile"
    Then the "Url" field should contain "http://example.com"
    And the "Description" field should contain "a great example"
    And the "Fee" field should contain "\$2.71"
