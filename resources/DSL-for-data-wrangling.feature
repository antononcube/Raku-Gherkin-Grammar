Feature: DSL for data wrangling tests

Background: Load data
    Given target is "raku"
    Then titanic dataset exists
    And the columns of the titanic dataset are "id passengerAge passengerClass passengerSex passengerSurvival"

Scenario: Group and count
    When group by passengerSex; counts
    Then result is a hash