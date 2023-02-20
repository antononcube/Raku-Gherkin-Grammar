#!/usr/bin/env raku
use v6.d;

use Gherkin::Grammar;
use Gherkin::Grammarish;

my $text0 = q:to/END/;
Feature: Highlander
    From the Movie "Highlander" (1986)
    Or the TV series.

  Rule: There can be only One

    Example: Only One -- More than one alive
      Given there are 3 ninjas
      And there are more than one ninja alive
      When 2 ninjas meet, they will fight
      Then one ninja dies (but not me)
      And there is one ninja less alive

    Example: Only One -- One alive
      Given there is only 1 ninja alive
      Then he (or she) will live forever ;-)
END

say '=' x 120;
say gherkin-parse($text0, rule => 'TOP');