Feature: Ordering tickets
  In order to purchase tickets
  a user wants to be able to select tickets, enter payment information, and confirm the order.

  Background:
    Given I can save People to ATHENA
    And I can save Customers to ATHENA
    And I can save Credit Cards to ATHENA
    And I can settle Credit Cards in ATHENA
    And I can authorize Credit Cards in ATHENA


  # TODO: Rack-Test and Capybara don't share cookies, so the order gets clobbered.
  # See http://avdi.org/devblog/2010/06/18/rack-test-and-capybara-are-uneasy-bedfellows/
  @wip
  Scenario: A user saves their information when confirming their order
    Given I am logged in
    And I have started an order
    And I follow "Checkout"
    And I enter my payment details
    When I check "Save my information"
    And I fill in "Password" with "password"
    And I fill in "Password confirmation" with "password"
    And I press "Purchase"
    And I should see "Successfully saved your information."
