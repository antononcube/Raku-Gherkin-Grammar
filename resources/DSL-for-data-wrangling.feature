Feature: DSL for data wrangling tests

Background: Load data
    Given target is "raku"
    Then titanic dataset exists
    And the columns of the titanic dataset are "id passengerAge passengerClass passengerSex passengerSurvival"

Scenario: Group and count
    When group by passengerSex; counts
    Then result is a hash

Scenario: Slicing
    When take the elements from 12 to 511
    Then the result length is "500"