#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use Gherkin::Grammar;
use Gherkin::Grammarish;

my $text0 = q:to/END/;
Функционалност: Highlander
    From the Movie "Highlander" (1986)
    Or the TV series.

  Правило: Само един ще остане

    Пример: Само един -- Повече от един са живи
      Дадено Има поне 3 нинджи
      И има повече от един нинджа живи
      Когато 2 нинджи се срещнат те се бият
      Тогaва един нинжа остава жив
      И броя на живите нинджи налява с един

    Пример: Само един -- Само един нинджа е жив
      Дадено Само един ниджа е жив
      Тогава Той или тя ще живее вечно :-8
END

say gherkin-parse($text0, rule => 'TOP', lang => 'Bulgarian');

