use v6.d;

constant $docStrDelim = '"""';

role Gherkin::Grammarish {
    token TOP($*obj) { <ghk-feature-block> }

    regex ghk-feature-block {
        <ghk-feature-text-line> \n+
        <ghk-feature-description>? \n*
        [ <ghk-rule-block> || <ghk-example-block> ]
        \n*
    }

    regex ghk-rule-block {
        <ghk-rule-text-line> \n+
        <ghk-example-block>+
        \n*
    }

    regex ghk-example-block {
        <ghk-example-text-line> \n
        <ghk-given-block>
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
        | <ghk-asterix-text-line>
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
        | <ghk-asterix-text-line>
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
        | <ghk-asterix-text-line>
    }

    regex ghk-feature-description {
        <ghk-description-line>+ % \n
    }

    regex ghk-doc-string {
        \h* $<docStrDelim>=('```' | '"""' | '~~~')
        $<text>=[<!before $<docStrDelim>> .]*?
        $<docStrDelim> \s*
    }

    regex ghk-feature-text-line          { \h* <ghk-keyword-feature>  \h* ':' \h+ <ghk-text-line-tail> }
    regex ghk-example-text-line          { \h* [ <ghk-keyword-example> | <ghk-keyword-scenario> ] \h* ':' \h+ <ghk-text-line-tail> }
    regex ghk-scenario-outline-text-line { \h* <ghk-keyword-scenario> \h+ [ <ghk-keyword-outline> | <ghk-keyword-template> ] \h* ':' \h+ <ghk-text-line-tail> }
    regex ghk-rule-text-line             { \h* <ghk-keyword-rule>     \h* ':' \h+ <ghk-text-line-tail> }
    regex ghk-given-text-line            { \h* <ghk-keyword-given>    \h+ <ghk-text-line-tail-arg> }
    regex ghk-when-text-line             { \h* <ghk-keyword-when>     \h+ <ghk-text-line-tail-arg> }
    regex ghk-and-text-line              { \h* <ghk-keyword-and>      \h+ <ghk-text-line-tail-arg> }
    regex ghk-then-text-line             { \h* <ghk-keyword-then>     \h+ <ghk-text-line-tail-arg> }
    regex ghk-but-text-line              { \h* <ghk-keyword-but>      \h+ <ghk-text-line-tail-arg> }
    regex ghk-asterix-text-line          { \h* <ghk-keyword-asterisk> \h+ <ghk-text-line-tail-arg> }
    regex ghk-text-line-tail-arg         { <ghk-text-line-tail> [ \n [ <ghk-doc-string> || <md-table-block> ] ]? }
    regex ghk-text-line-tail             { <-[\v]>+ }
    regex ghk-text-element               { <-[\v]>* }
    regex ghk-description-line           { $<text>=(<-[\v]>+) <!{ $<text>.Str.trim ~~ / ^ [ Rule | Example | Scenario | Given | When | Then | But | And | Feature | Background ] \h* ':'/}> }

    token ghk-keyword-and { 'And' }
    token ghk-keyword-asterisk { '*' }
    token ghk-keyword-but { 'But' }
    token ghk-keyword-example { 'Example' }
    token ghk-keyword-feature { 'Feature' }
    token ghk-keyword-given { 'Given' }
    token ghk-keyword-outline { 'Outline' }
    token ghk-keyword-rule { 'Rule' }
    token ghk-keyword-scenario { 'Scenario' }
    token ghk-keyword-template { 'Template' }
    token ghk-keyword-then { 'Then' }
    token ghk-keyword-when { 'When' }
}