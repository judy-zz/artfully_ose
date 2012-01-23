Feature: Export Donations
  In order to export donations, a user will download a CSV file.

  Background:
    Given I am logged in
    And I am part of an organization

  Scenario: A user exports their donations
    Given there are 20 donations
    And I am on the imports page
    And I follow "Export all donations currently in Artful.ly"
    Then I should receive a file "Artfully-Donations-Export-%s.csv" named for today
