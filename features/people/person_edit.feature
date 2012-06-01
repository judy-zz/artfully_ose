Feature: Edit the record for a person
  In order to view a history and perform actions
  A user wants to be able to view the details of a People record

  Scenario: A user edits a person record
    Given I am logged in
    And I am part of an organization
    And I am looking at "Joe Montana"
    When I follow "Edit"
    Then I should see "Editing Joe Montana"
    And I fill in "Company" with "San Francisco 49ers"
    And I press "Save"
    Then I should see "Your changes have been saved"