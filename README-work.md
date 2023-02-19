# Gherkin::Grammar Raku package

This repository has the Raku package for 
[Gherkin](https://en.wikipedia.org/wiki/Cucumber_(software)#Gherkin_language)
grammar and interpretations.

[Gherkin](https://en.wikipedia.org/wiki/Cucumber_(software)#Gherkin_language)
is the language of the 
[Cucumber framework](https://cucumber.io), [Wk1] 
that is used to 
[Behavior-Driven Development (BDD)](https://en.wikipedia.org/wiki/Behavior-driven_development), [Wk2].

The Raku package 
["Cucumis Sextus](https://github.com/robertlemmen/raku-cucumis-sextus), [RL1],
aims to provide a "full-blown" specification-and-execution framework in Raku like the typical 
Cucumber functionalities in other languages. (Ruby, Java, etc.) 

This package, "Gherkin::Grammar", aims to provide:

- Grammar (and roles) for parsing Gherkin specifications 
- Test file template generation 

Having a "standalone" Gherkin grammar (or role) facilitates the creation and execution
of general or specialized frameworks for Raku support of BDD.

The package provides the functions:

- `gherkin-parse`
- `gherkin-subparse`
- `gherkin-interpret`

The Raku outputs of `gherkin-interpret` are test file templates that after filling-in
would provide tests correspond to the input specifications (given in Gherkin.)

------

## Installation

From [Zef ecosystem](https://raku.land):

```
zef install Gherkin::Grammar
```

From GitHub:

```
zef install https://github.com/antononcube/Raku-Gherkin-Grammar
```

------

## Usage examples

Here is a basic (and short) Gherkin spec parsing example:

```perl6
use Gherkin::Grammar;

my $text0 = q:to/END/;
Feature: Calculation
    Example: One plus one
    When 1 + 1
    Then 2
END

gherkin-interpret($text0);
```

### Internationalization

The package provides provides internationalization using different languages.
The (initial) internationalization keyword-regexes were taken from [RLp1].
(See the file ["I18n.rakumod"](https://github.com/robertlemmen/raku-cucumis-sextus/blob/master/lib/CucumisSextus/I18n.rakumod).)

Here is an example with Russian:


```perl6
my $ru-text = q:to/END/;
Функционал: Вычисление
    Пример: одно плюс одно
    Когда 1 + 1
    Тогда 2
END

gherkin-interpret($ru-text, lang => 'Russian');
```

### Arguments

The package takes both doc-strings and tables as step arguments.

*TBD...*

------

## CLI

The package provides a Command Line Interface (CLI) script. Here is its help message:

```shell
gherkin-interpretation --help
```

------

## References

[Wk1] Wikipedia entry,
["Cucumber (software)"](https://en.wikipedia.org/wiki/Cucumber_(software)).
See also [cucumber.io](https://cucumber.io).

[Wk2] Wikipedia entry,
["Behavior-driven development"](https://en.wikipedia.org/wiki/Behavior-driven_development).

[RLp1] Robert Lemmen,
[Cucumis Sextus Raku package](https://github.com/robertlemmen/raku-cucumis-sextus),
(2017-2020),
[GitHub/robertlemmen](https://github.com/robertlemmen).

[AAp1] Anton Antonov,
[Markdown::Grammar Raku package](https://github.com/antononcube/Raku-Markdown-Grammar),
(2022-2023),
[GitHub/antononcube](https://github.com/antononcube).


