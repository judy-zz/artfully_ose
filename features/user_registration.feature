Feature: User registration
  In order to use the application
  a user wants to be able to register

  Background:
    Given I can save People to ATHENA

  Scenario: Register as a producer
    Given I am on the new user registration page
    When I fill in "Email" with "example@example.com"
    And I fill in "Password" with "password"
    And I fill in "Password confirmation" with "password"
    And I press "Sign up"
    Then I should be on the dashboard page

