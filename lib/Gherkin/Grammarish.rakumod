use v6.d;

role Gherkin::Grammarish {
    token TOP($*obj) { <ghk-feature-block> }

    regex ghk-feature-block {
        <ghk-feature-text-line> \n+
        <ghk-rule-block>
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

    regex ghk-feature-text-line { \h* 'Feature' \h* ':' \h+ <ghk-text-line-tail> }
    regex ghk-example-text-line { \h* [ 'Example' | 'Scenario' ] \h* ':' \h+ <ghk-text-line-tail> }
    regex ghk-rule-text-line    { \h* 'Rule'  \h* ':' \h+ <ghk-text-line-tail> }
    regex ghk-given-text-line   { \h* 'Given' \h+ <ghk-text-line-tail> }
    regex ghk-when-text-line    { \h* 'When'  \h+ <ghk-text-line-tail> }
    regex ghk-and-text-line     { \h* 'And'   \h+ <ghk-text-line-tail> }
    regex ghk-then-text-line    { \h* 'Then'  \h+ <ghk-text-line-tail> }
    regex ghk-but-text-line     { \h* 'But'   \h+ <ghk-text-line-tail> }
    regex ghk-asterix-text-line { \h* '*'     \h+ <ghk-text-line-tail> }
    regex ghk-text-line-tail    { <-[\v]>+ }
    regex ghk-text-element      { <-[\v]>* }

}