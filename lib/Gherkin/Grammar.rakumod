use v6.d;

use Gherkin::Grammarish;
use Gherkin::Grammar::Internationalization;
use Gherkin::Actions::Raku::Template;
use Markdown::Grammar;

grammar Gherkin::Grammar
        is Markdown::Grammar
        does Gherkin::Grammarish {

}

#-----------------------------------------------------------
my $pCOMMAND = Gherkin::Grammar;

my $actionsObj = Gherkin::Actions::Raku::Template.new();

sub gherkin-parse(Str:D $spec,
                   Str:D :$rule = 'TOP',
                   :$lang is copy = Whatever
                   ) is export {
    if $lang.isa(Whatever) { $lang = 'English'; }
    return $pCOMMAND.parse($spec ~ "\n", :$rule, args => $rule eq 'TOP' ?? ($lang,) !! Empty);
}

sub gherkin-subparse(Str:D $spec,
                      Str:D :$rule = 'TOP',
                      :$lang is copy = Whatever
                      ) is export {
    if $lang.isa(Whatever) { $lang = 'English'; }
    return $pCOMMAND.subparse($spec ~ "\n", :$rule, args => $rule eq 'TOP' ?? ($lang,) !! Empty);
}

#| Conversion of Gherkin specification into code.
#| C<$spec> Specification string.
#| C<:$rule> Rule name to start the parsing with.
#| C<:$actions> Actions to use.
proto gherkin-interpret(|) is export {*}

multi sub gherkin-interpret(Str:D $spec,
                             Str:D :$rule = 'TOP',
                             :target(:$actions) is copy = $actionsObj,
                             :$lang is copy = Whatever
                             ) is export {
    if $actions.isa(Whatever) || $actions ~~ Str && $actions.lc eq 'raku' { $actions = $actionsObj; }
    if $lang.isa(Whatever) { $lang = 'English'; }
    return $pCOMMAND.parse($spec ~ "\n", :$rule, :$actions, args => $rule eq 'TOP' ?? ($lang,) !! Empty).made;
}