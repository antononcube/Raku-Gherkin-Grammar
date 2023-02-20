use v6.d;

use Gherkin::Grammar::Internationalization;

constant $docStrDelim = '"""';

role Gherkin::Grammarish {
    token TOP($*lang) { <ghk-feature-block> }

    regex ghk-feature-block {
        [<ghk-tag-line>? \n]?
        <ghk-feature-text-line> \n+
        <ghk-feature-description>? \n*
        [ <ghk-rule-block> || <ghk-example-block-list> ]
        \n*
    }

    regex ghk-rule-block {
        <ghk-rule-text-line> \n+
        <ghk-example-block-list>
        \n*
    }

    regex ghk-example-block-list {
        <ghk-background-block>? \n*
        <ghk-example-block>+
    }

    regex ghk-background-block {
        <ghk-background-text-line> \n
        <ghk-given-block>?
        <ghk-when-block>?
        <ghk-then-block>?
        \n*
    }

    regex ghk-example-block {
        [ <ghk-tag-line> \n]?
        <ghk-example-text-line> \n
        <ghk-given-block>?
        <ghk-when-block>?
        <ghk-then-block>
        \n*
    }

    regex ghk-given-block {
        <ghk-given-text-line> \n
        <ghk-given-block-element>* % \n
        \n*
    }
    regex ghk-given-block-element {
        | <ghk-given-text-line>
        | <ghk-and-text-line>
        | <ghk-but-text-line>
        | <ghk-asterisk-text-line>
    }

    regex ghk-when-block {
        <ghk-when-text-line> \n
        <ghk-when-block-element>* % \n
        \n*
    }
    regex ghk-when-block-element {
        | <ghk-when-text-line>
        | <ghk-and-text-line>
        | <ghk-but-text-line>
        | <ghk-asterisk-text-line>
    }

    regex ghk-then-block {
        <ghk-then-text-line> \n
        <ghk-then-block-element>* % \n
        \n*
    }
    regex ghk-then-block-element {
        | <ghk-then-text-line>
        | <ghk-and-text-line>
        | <ghk-but-text-line>
        | <ghk-asterisk-text-line>
    }

    regex ghk-feature-description {
        <ghk-description-line>+ % \n
    }

    regex ghk-doc-string {
        \h* $<docStrDelim>=('```' | '"""' | '~~~')
        $<text>=[<!before $<docStrDelim>> .]*?
        $<docStrDelim> \s*
    }

    regex ghk-feature-text-line          { \h* <ghk-keyword-feature>    \h* ':' \h+ <ghk-text-line-tail> }
    regex ghk-example-text-line          { \h* [ <ghk-keyword-example> | <ghk-keyword-scenario> ] \h* ':' \h+ <ghk-text-line-tail> }
    regex ghk-scenario-outline-text-line { \h* <ghk-keyword-scenario>   \h+ [ <ghk-keyword-outline> | <ghk-keyword-template> ] \h* ':' \h+ <ghk-text-line-tail> }
    regex ghk-rule-text-line             { \h* <ghk-keyword-rule>       \h* ':' \h+ <ghk-text-line-tail> }
    regex ghk-background-text-line       { \h* <ghk-keyword-background> \h* ':' \h+ <ghk-text-line-tail> }
    regex ghk-given-text-line            { \h* <ghk-keyword-given>      \h+ <ghk-text-line-tail-arg> }
    regex ghk-when-text-line             { \h* <ghk-keyword-when>       \h+ <ghk-text-line-tail-arg> }
    regex ghk-and-text-line              { \h* <ghk-keyword-and>        \h+ <ghk-text-line-tail-arg> }
    regex ghk-then-text-line             { \h* <ghk-keyword-then>       \h+ <ghk-text-line-tail-arg> }
    regex ghk-but-text-line              { \h* <ghk-keyword-but>        \h+ <ghk-text-line-tail-arg> }
    regex ghk-asterisk-text-line         { \h* <ghk-keyword-asterisk>   \h+ <ghk-text-line-tail-arg> }
    regex ghk-text-line-tail-arg         { <ghk-text-line-tail> [ \n [ <ghk-doc-string> || <md-table-block> ] ]? }
    regex ghk-text-line-tail             { <-[\v]>+ }
    regex ghk-text-element               { <-[\v]>* }
    token ghk-tag                        { '@' \S+ }
    regex ghk-tag-line                   { \h* <ghk-tag>+ % \h+ }
    regex ghk-description-line           { $<text>=(<-[\v]>+) <!{ $<text>.Str.trim ~~ / ^ [ Rule | Example | Scenario | Given | When | Then | But | And | Feature | Background ] \h* ':'/}> }

    token ghk-keyword-and { 'And' || (\w+) <?{ $0.Str ~~ gherkin-keywords($*lang // 'en')<and> }> }
    token ghk-keyword-asterisk { '*' }
    token ghk-keyword-background { 'Background' || (\w+) <?{ $0.Str ~~ gherkin-keywords($*lang // 'en')<background> }> }
    token ghk-keyword-but { 'But' || (\w+) <?{ $0.Str ~~ gherkin-keywords($*lang // 'en')<but> }> }
    token ghk-keyword-example { 'Example' || (\w+) <?{ $0.Str ~~ gherkin-keywords($*lang // 'en')<example> }> }
    token ghk-keyword-examples { 'Examples' || (\w+) <?{ $0.Str ~~ gherkin-keywords($*lang // 'en')<examples> }> }
    token ghk-keyword-feature { 'Feature' || (\w+) <?{ $0.Str ~~ gherkin-keywords($*lang // 'en')<feature> }> }
    token ghk-keyword-given { 'Given' || (\w+) <?{ $0.Str ~~ gherkin-keywords($*lang // 'en')<given> }> }
    token ghk-keyword-outline { 'Outline' || (\w+) <?{ $0.Str ~~ gherkin-keywords($*lang // 'en')<outline> }> }
    token ghk-keyword-rule { 'Rule' || (\w+) <?{ $0.Str ~~ gherkin-keywords($*lang // 'en')<rule> }> }
    token ghk-keyword-scenario { 'Scenario' || (\w+) <?{ $0.Str ~~ gherkin-keywords($*lang // 'en')<scenario> }> }
    token ghk-keyword-template { 'Template' || (\w+) <?{ $0.Str ~~ gherkin-keywords($*lang // 'en')<template> }> }
    token ghk-keyword-then { 'Then' || (\w+) <?{ $0.Str ~~ gherkin-keywords($*lang // 'en')<then> }> }
    token ghk-keyword-when { 'When' || (\w+) <?{ $0.Str ~~ gherkin-keywords($*lang // 'en')<when> }> }
}