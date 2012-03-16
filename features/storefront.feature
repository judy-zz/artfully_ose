Feature: Storefront
  Background:
    Given I am logged in
    And I am part of an organization with access to the ticketing kit
    And there is an Event with 3 Shows
    And the 1st show has had tickets created
    And the 1st show is on sale

  Scenario: A customer wants to buy tickets to my show
    Given the customer goes to the storefront for my event
    And the customer should see the published shows
    And all the checkout panel links
    And not the special instructions link