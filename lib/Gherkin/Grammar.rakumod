use v6.d;

use Gherkin::Grammarish;
use Gherkin::Actions::Raku;

grammar Gherkin::Grammar
        does Gherkin::Grammarish {

}

#-----------------------------------------------------------
my $pCOMMAND = Gherkin::Grammar;

my $actionsObj = Gherkin::Actions::Raku.new();

sub gherkin-parse(Str:D $spec,
                   Str:D :$rule = 'TOP',
                   Bool :$extended = True
                   ) is export {
    return $pCOMMAND.parse($spec ~ "\n", :$rule, args => $rule eq 'TOP' ?? ($extended,) !! Empty);
}

sub gherkin-subparse(Str:D $spec,
                      Str:D :$rule = 'TOP',
                      Bool :$extended = True
                      ) is export {
    return $pCOMMAND.subparse($spec ~ "\n", :$rule, args => $rule eq 'TOP' ?? ($extended,) !! Empty);
}

#| Conversion of Gherkin specification into code.
#| C<$spec> Specification string.
#| C<:$rule> Rule name to start the parsing with.
#| C<:$actions> Actions to use.
proto gherkin-interpret(|) is export {*}

multi sub gherkin-interpret(Str:D $spec,
                             Str:D :$rule = 'TOP',
                             :target(:$actions) is copy = $actionsObj,
                             Bool :$extended = False
                             ) is export {
    if $actions.isa(Whatever) || $actions ~~ Str && $actions.lc eq 'raku' { $actions = $actionsObj; }
    return $pCOMMAND.parse($spec, :$rule, :$actions, args => $rule eq 'TOP' ?? ($extended,) !! Empty).made;
}