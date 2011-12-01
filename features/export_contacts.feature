Feature: Export Contacts
  In order to export contacts, a user will download a CSV file.

  Background:
    Given I am logged in
    And I am part of an organization

  Scenario: A user exports their contacts
    Given there are 20 contacts
    And I am on the imports page
    And I follow "Export all people currently in Artful.ly"
    Then I should receive a file "Artfuly-People-Export-%s.csv" named for today
