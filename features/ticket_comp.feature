Feature: Ticket Comp
  In order to be able to give away tickets
  a producer wants to be able to comp one or more tickets

  Background:
    Given I am logged in
    And I am part of an organization with access to the ticketing kit
    And there is an Event with 1 Shows
    And the 1st show has had tickets created
    And the 1st show is on sale

  Scenario: A producer comps a ticket
    When I go to the events page
    And I view the 1st event
    And I view the 1st show
    And I check the 1st ticket for a comp
    And I press "Comp"
    And I should see "Recipient"
    And I should see "Reason"
    And I want to comp to "Joe Producer" email "joe.producer@example.com"
    And I fill in "reason_for_comp" with "Dull and Generic Reason"

  Scenario: A producer comps a ticket but forgets to specify which person
    When I go to the events page
    And I view the 1st event
    And I view the 1st show
    And I check the 1st ticket for a comp
    And I press "Comp"
    And I should see "Recipient"
    And I should see "Reason"
    And I fill in "reason_for_comp" with "Dull and Generic Reason"
    And I press "Comp Tickets"
    And I should see "Please select a person to comp to or create a new person record"