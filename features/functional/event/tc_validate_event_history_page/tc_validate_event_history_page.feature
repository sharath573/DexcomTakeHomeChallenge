@event

Feature: Verify the created evecnt is displayed in event list page
  As a user i want to create an event
  And i should see same in event page

  Background:

  Scenario: As a user i want to create an event and same should be displayed in event list page
    Given I navigate to add event page
    When I create a "Meal" event
    Then I should see the "created" event in event list page

  Scenario: As a user i want to update the event and same should be displayed in event list page
    When I update an "eventCell-2" event
    Then I should see the "updated" event in event list page

  Scenario: As a user i cannot able to update the event with empty
    When I update an "eventCell-3" event
    Then I should not see the "emtpy" event in event list page