Feature: Putting Tickets on Sale
  In order to sell tickets to patrons
  a producer wants to be able to mark certain tickets as on sale.

  Background:
    Given I am logged in
    And I am part of an organization with access to the ticketing kit
    And there is an Event with 3 Shows
    And the 1st show has had tickets created
    And I am on the events page
    And I view the 1st event
    And I follow "Shows"
    And I view the 1st show
    
  Scenario: A producer takes tickets off sale
    Given I take tickets off sale for the 1st section
    Then I should see "Take Tickets Off Sale"
    And I fill in "quantity" with "1"
    And I follow "Take off sale"
    
  Scenario: A producer puts tickets for a show on sale
    Given I put tickets on sale for the 1st section
    Then I should see "Put Tickets On Sale"
    And I fill in "quantity" with "1"
    And I follow "Put on sale"