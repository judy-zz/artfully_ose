Feature: Export Ticket Sales
  In order to export ticket sales, a user will download a CSV file.

  Background:
    Given I am logged in
    And I am part of an organization

  Scenario: A user exports their ticket sales
    Given there are 20 ticket sales
    And I am on the imports page
    And I follow "Export all ticket sales currently in Artful.ly"
    Then I should receive a file "Artfuly-Ticket-Sales-Export-%s.csv" named for today
