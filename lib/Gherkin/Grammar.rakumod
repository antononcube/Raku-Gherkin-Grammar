use v6.d;

use Gherkin::Grammarish;
use Gherkin::Grammar::Internationalization;
use Gherkin::Actions::Mathematica::TestTemplate;
use Gherkin::Actions::Raku::TestTemplate;
use Markdown::Grammar;

grammar Gherkin::Grammar
        is Markdown::Grammar
        does Gherkin::Grammarish {

}

#-----------------------------------------------------------
my $pCOMMAND = Gherkin::Grammar;

my $actionsObjRaku = Gherkin::Actions::Raku::TestTemplate.new();
my $actionsObjWL = Gherkin::Actions::Mathematica::TestTemplate.new(
        thinSectionSep => '(*' ~ ('-' x 60) ~ '*)',
        thickSectionSep => '(*' ~ ('*' x 60) ~ '*)',
        protos => '');

sub gherkin-parse(Str:D $spec,
                   Str:D :$rule = 'TOP',
                   :$lang is copy = Whatever
                   ) is export {
    if $lang.isa(Whatever) { $lang = 'English'; }
    return $pCOMMAND.parse($spec ~ "\n\n", :$rule, args => $rule eq 'TOP' ?? ($lang,) !! Empty);
}

sub gherkin-subparse(Str:D $spec,
                      Str:D :$rule = 'TOP',
                      :$lang is copy = Whatever
                      ) is export {
    if $lang.isa(Whatever) { $lang = 'English'; }
    return $pCOMMAND.subparse($spec ~ "\n\n", :$rule, args => $rule eq 'TOP' ?? ($lang,) !! Empty);
}

#| Conversion of Gherkin specification into code.
#| C<$spec> Specification string.
#| C<:$rule> Rule name to start the parsing with.
#| C<:$actions> Actions to use.
proto gherkin-interpret(|) is export {*}

multi sub gherkin-interpret(Str:D $spec,
                             Str:D :$rule = 'TOP',
                             :target(:$actions) is copy = $actionsObjRaku,
                             :$lang is copy = Whatever
                             ) is export {

    $actions = do given $actions {
        when Whatever { $actionsObjRaku; }
        when $_ ~~ Str && $_.lc eq <raku perl6> { $actionsObjRaku; }
        when $_ ~~ Str && $_.lc ∈ <mathematica wl> { $actionsObjWL; }
        default { $actionsObjRaku}
    }

    if $lang.isa(Whatever) { $lang = 'English'; }

    return $pCOMMAND.parse($spec ~ "\n\n", :$rule, :$actions, args => $rule eq 'TOP' ?? ($lang,) !! Empty).made;
}