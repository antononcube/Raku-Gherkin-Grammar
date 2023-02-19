#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use Gherkin::Grammar;
use Gherkin::Grammarish;

my $text0 = q:to/END/;
Feature: Highlander

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


my $text1 = q:to/END/;
Example: Multiple Givens
  Given one thing
  Given another thing
  Given yet another thing
  When I open my eyes
  Then I should see something
  Then I shouldn't see something else
END

my $text2 = q:to/END/;
    Given one thing
    Given another thing
    Given yet another thing
END

#say Gherkin::Grammar.parse('Example: Multiple Givens', rule => 'ghk-example-text-line');

#say Gherkin::Grammar.parse('Given one thing', rule => 'ghk-given-text-line');

#say Gherkin::Grammar.parse('Given one thing', rule => 'ghk-given-block');

#say gherkin-subparse($text1, rule => 'ghk-example-block');

say '=' x 120;
say gherkin-parse($text0, rule => 'TOP');
