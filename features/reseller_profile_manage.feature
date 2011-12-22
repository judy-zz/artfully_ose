Feature: Resellers have profiles
  In order to promote their service to producers
  a user wants their reselling organization to have a profile

  Background:
    Given I am logged in
    And I am part of an organization with access to the reselling kit

  Scenario: A user wants to see their reseller profile
    When I follow "My Organization"
    Then I should see "Url"
    And I should see "Description"
  
  Scenario: A user wants to update their reseller profile
    When I follow "My Organization"
    And I fill in "Url" with "http://example.com"
    And I fill in "Description" with "a great example"
    And I press "Update Profile"
    Then the "Url" field should contain "http://example.com"
    And the "Description" field should contain "a great example"
