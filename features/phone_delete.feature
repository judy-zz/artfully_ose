Feature: Add a phone to a person record
  As a producer, I want to be able to add a phone number
  to a person record

  Background:
    Given I am logged in
    And I am part of an organization

  Scenario: A producer adds a tag to a person record
    Given a person exists with an email of "test@dummy.com" for my organization
    And "test@dummy.com" has a phone number
    When I follow "Delete"
    Then the person record for "test@dummy.com" should not have "123-123-1234" as a "Home" number