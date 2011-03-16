Feature: Ticket Comp
  In order to view the patrons attending a performance
  the producer wants to be able to view a list of names

  Background:
    Given I am logged in
    And I am part of an organization with access to the ticketing kit
    And there is an Event with 3 Performances
    And the 1st performance has had tickets created
    And the 1st performance is on sale

  Scenario: A producer comps a ticket
    When I go to the events page
    And I view the 1st event
    And I view the 1st performance
And show me the page
    And I check "selected_tickets_"
    And I press "Comp"

    And I search for the patron named "Joe Producer" email "joe.producer@example.com"
    And I fill in "comp_reason" with "Dull and Generic Reason"
    And I press "Submit"
    And I confirm comp

And show me the page
    Then I should see "Comped"
