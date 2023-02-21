Feature: Numeric word forms parsing

  Scenario: Small number parsing, English
    Given language is English
    When two hundred and thirty eight
    Then the result is "238"

  Scenario: Large number parsing, English
    Given language is English
    When thirty million one thousand and four hundred and fifty
    Then the result is "30_001_450"

  Scenario: Small number parsing, Bulgarian
    Given language is Bulgarian
    When двеста тридесет и осем
    Then the result is "238"

  Scenario: Голямо число на Български
    Given language is Bulgarian
    When трийсет милиона хиляда четиристотин и петдесет
    Then the result is "30_001_450"