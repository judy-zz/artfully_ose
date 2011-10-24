Feature: Tag a person record
  In order to add free-form information to people records
  a producer wants to be able to add a tag to the record

  Background:
    Given I am logged in
    And I am part of an organization

  Scenario: A producer adds a tag to a person record
    Given a person exists with an email of "test@dummy.com" for my organization
    When I fill in "tag" with "test"
    And I press "Add Tag"
    Then the person record for "test@dummy.com" should have the tag "test"