Feature: User accounts 
  In order to use the application
  a user
  wants wants to be able to sign in with their registered account.
  
  Scenario: Sign in as a producer
    Given I am on the new user session page
      And the following producer exists:
        | email                | password |
        | producer@example.com | changeme |
    When I fill in "Email" with "producer@example.com"
      And I fill in "Password" with "changeme"
      And I press "Sign in"
    Then I should see "Signed in successfully."

