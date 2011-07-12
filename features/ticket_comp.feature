Feature: Ticket Comp
  In order to be able to give away tickets
  a producer wants to be able to comp one or more tickets

  Background:
    Given I am logged in
    And I am part of an organization with access to the ticketing kit
    And there is an Event with 1 Performances
    And the 1st performance has had tickets created
    And the 1st performance is on sale

  Scenario: A producer comps a ticket
    When I go to the events page
    And I view the 1st event
    And I view the 1st performance
    And I check the 1st ticket for a comp
    And I press "Comp"
    And I search for the patron named "Joe Producer" email "joe.producer@example.com"
    And I select the first person
    And I fill in "comp_reason" with "Dull and Generic Reason"
    And I press "Submit"
    And I should see "Dull and Generic Reason"
    And I confirm comp
    Then I should see "Comped"