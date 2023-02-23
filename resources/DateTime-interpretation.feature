Feature: DateTime interpretation test

  Scenario: Full date
    When 2023-02-20T00:00:00Z
    Then the result is DateTime
    And the year is "2023", month is "2", and date "20"

  Scenario: ISO date
    When 2032-10-01
    Then the result is DateTime
    And the year is "2032", month is "10", and date "1"

  Scenario: Full blown date time spec
    When Sun, 06 Nov 1994 08:49:37 GMT
    Then the result is DateTime
    And the year is "1994", month is "11", and date "6"

  Scenario: Simple table spec
    When today, yesterday, tomorrow
    Then the results adhere to:
      | Spec      | Result                        |
      | today     | DateTime.today                |
      | yesterday | DateTime.today.earlier(:1day) |
      | tomorrow  | DateTime.today.later(:1day)   |