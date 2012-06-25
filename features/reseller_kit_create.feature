Feature: Reseller Kit
  In order to use selling features
  a user wants to activate the reselling kit for their organization

  Background:
    Given I can save Credit Cards to ATHENA

  # re-enable this when reseller kit goes live
  Scenario: A user activates the reselling kit with a credit and organization
    Given I am logged in
    And I have 2 saved credit cards
    And I create a new organization called "Fractured Atlas"
    And I view my organization page
    # And I activate the "Reseller Kit"
    # And I press "Submit Activation Request"
    # Then I should see "Your request has been sent in for approval."

  Scenario: A user activates the ticketing kit without a credit card
    Given I am logged in
    And I create a new organization called "Fractured Atlas"
    And I view my organization page
    # And I activate the "Reseller Kit"
    # And I press "Submit Activation Request"
    # Then I should see "Your request has been sent in for approval."
