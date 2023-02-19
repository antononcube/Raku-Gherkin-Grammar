@calc @basic
Feature: Basic Calculator Functions
    In order to check I've written the Calculator class correctly
    As a developer I want to check some basic operations
    So that I can have confidence in my Calculator class.

@positive
Scenario: First Key Press on the Display
    Given a new Calculator object
    And having pressed 1
    Then the display should show 1

@arithmetic
Scenario: Addition of two
    Given a new Calculator object
    When entered "1 + 1"
    Then 2