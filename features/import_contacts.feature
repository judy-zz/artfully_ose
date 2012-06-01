Feature: Import Contacts
  In order to import many contacts, a user will upload a CSV file of contacts.

  Background:
    Given I am logged in
    And I am part of an organization

  Scenario: A user uploads a valid csv file
    When I upload a new import file "simple-export.csv"
    And I am on the import page
    Then the number of imports should change to 1
    And I should see "29 contacts found in this import file"

  Scenario: A user approves a new import
    When I upload a new import file "simple-export.csv"
    And I am on the import page
    And I follow "Approve"
    Then the import's status should be approved

  Scenario: A user approves a new import and it is performed
    When I upload a new import file "simple-export.csv"
    And the import is performed
    Then there should be no import errors

  Scenario: A user provides an incorrect file
    When I upload a new import file "athena.rb"
    And I am on the import page
    Then I should see "Import Failed"
