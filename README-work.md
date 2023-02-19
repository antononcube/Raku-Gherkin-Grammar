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

**Remark:** A good introduction to the Cucumber / Gherkin approach and workflows is the 
[README](https://github.com/robertlemmen/raku-cucumis-sextus#readme)
of [RLp1].

**Remark:** The grammar in this package was programmed following the specifications and 
explanations in 
[Gherkin Reference](https://cucumber.io/docs/gherkin/reference/).

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

The tables are parsed with the package "Markdown::Grammar", [AAp1].

*TBD...*

------

## Complete example

The files 
["Calculator.feature"](./resources/Calculator.feature) 
and
["Calculator.rakutest"](./resources/Calculator.rakutest)
provide a fully worked example of how this package can be used 
to implement Cucumber framework workflows.

**Remark:** The Cucumber framework(s) expect Gherkin specifications to be written in 
files with extension ".feature".

------

## CLI

The package provides a Command Line Interface (CLI) script. Here is its help message:

```shell
gherkin-interpretation --help
```

------

## References

### Articles

[Wk1] Wikipedia entry,
["Cucumber (software)"](https://en.wikipedia.org/wiki/Cucumber_(software)).
See also [cucumber.io](https://cucumber.io).

[Wk2] Wikipedia entry,
["Behavior-driven development"](https://en.wikipedia.org/wiki/Behavior-driven_development).

[SB1] SmartBear,
["Gherkin Reference"](https://cucumber.io/docs/gherkin/reference/),
(2023),
[cucumber.io](https://cucumber.io).

### Packages 

[AAp1] Anton Antonov,
[Markdown::Grammar Raku package](https://github.com/antononcube/Raku-Markdown-Grammar),
(2022-2023),
[GitHub/antononcube](https://github.com/antononcube).

[RLp1] Robert Lemmen,
[Cucumis Sextus Raku package](https://github.com/robertlemmen/raku-cucumis-sextus),
(2017-2020),
[GitHub/robertlemmen](https://github.com/robertlemmen).
