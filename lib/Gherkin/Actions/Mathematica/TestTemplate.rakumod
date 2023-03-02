use v6.d;

use Gherkin::Actions::Raku::TestTemplate;

class Gherkin::Actions::Mathematica::TestTemplate
        is Gherkin::Actions::Raku::TestTemplate {

    # method TOP($/)

    method ghk-feature-block($/) {
        my $res;
        with $<ghk-rule-block> { $res = $<ghk-rule-block>.made };
        with $<ghk-example-block-list> { $res = $<ghk-example-block-list>.made };
        make self.make-preface() ~ "\n" ~ $res;
    }

    # method ghk-rule-block($/)

    #------------------------------------------------------

    method ghk-background-text-line ($/) {
        make '(* TestBackground : ' ~  $<ghk-text-line-tail>.made ~ ' *)';
    }

    #------------------------------------------------------
    method ghk-example-text-line ($/) {
        make '(* Example : ' ~  $<ghk-text-line-tail>.made ~ ' *)';
    }

    #------------------------------------------------------
    method ghk-scenario-outline-text-line ($/) {
        make '(* Scenario Outline : ' ~  $<ghk-text-line-tail>.made ~ ' *)';
    }

    #------------------------------------------------------
    method ghk-given-block-element($/) { make $/.values[0].made.subst( / <wb> 'And[' /, 'Given['); }
    method ghk-given-text-line($/) {
        make self.make-sub-definition('Given', $<ghk-text-line-tail-arg>.made);
    }

    #------------------------------------------------------
    method ghk-when-block-element($/) { make $/.values[0].made.subst(/ <wb> 'And[' /, 'When['); }
    method ghk-when-text-line($/) {
        make self.make-sub-definition('When', $<ghk-text-line-tail-arg>.made);
    }

    #------------------------------------------------------
    method ghk-then-block-element($/) { make $/.values[0].made.subst(/ <wb> 'And[' /, 'Then['); }
    method ghk-then-text-line($/) {
        make self.make-sub-definition('Then', $<ghk-text-line-tail-arg>.made);
    }

    #------------------------------------------------------
    # method ghk-and-text-line($/)
    # method ghk-asterisk-text-line($/)

    #------------------------------------------------------
    # method ghk-text-line-tail-arg($/)

    method ghk-text-line-tail($/) {
        make $/.Str.subst('"', '\"'):g;
    }

    #------------------------------------------------------
    # method ghk-doc-string($/)

    #------------------------------------------------------
    method ghk-table-block($/) {
        my @header = $<header><ghk-table-row>.made;
        my @rows = $<rows><ghk-table-row>>>.made;
        my @res = @rows.map({ '<|' ~ ( @header.map({ "\"$_\"" }) Z~ ( '->' X~ $_.Array ) ).join(', ') ~ '|>' }).Array;
        @res = '{' ~ @res.join(', ') ~ '}';
        make @res;
    }
    method ghk-table-row($/) {
        make $<ghk-table-field>>>.made;
    }
    method ghk-table-field($/) {
        make $/.Str.trim;
    }

    #------------------------------------------------------
    multi method make-sub-definition(Str:D $type, @cmd where *.elems == 2) {
        my $res = "$type\[ \"{@cmd[0]}\", tbl_ : {@cmd[1]} \] := Block[\{\}, True];";
        return $res;
    }

    multi method make-sub-call(Str:D $type, @cmd) {
        my $res = "$type\[ {|@cmd} \];";
        return $res;
    }

    multi method make-sub-definition(Str:D $type, Str:D $cmd) {
        my $res = "$type\[ \"$cmd\" ] := Block[\{\}, True];";
        return $res;
    }

    multi method make-sub-call(Str:D $type, Str:D $cmd) {
        my $res = "$type\[ $cmd \];";
        return $res;
    }

    multi method make-background-sub($descr, @lines, $add-is) {
        return self.make-execution-sub('TestBackground', $descr, @lines, $add-is);
    }

    multi method make-example-sub($descr, @lines) {
        return self.make-execution-sub('Example', $descr, @lines, True);
    }

    multi method make-scenario-template-sub($descr, @lines, @tbl) {
        return self.make-execution-sub('ScenarioTemplate', $descr, @lines, @tbl, True);
    }

    multi method make-execution-sub($type, $descr, @lines, Bool $add-is) {
        my $res = "$type\[\"$descr\"] := Block[\{\},";
        $res ~= "\n\t" ~ @lines.map({ $_.subst('cmd_ : ', '').subst(':= Block[{}, True];', '').trim ~ ';' }).join("\n\t");
        $res = $res.subst(/';' $/, '');
        $res ~= "\n];";

        if $add-is {
            if self.backgroundDescr {
                $res ~= "\n\nTestBackground[\"{self.backgroundDescr}\"];";
            }
            $res ~= "\n\nVerificationTest[ $type\[\"$descr\"\], True, TestID -> \"$descr\"]";
        }

        return $res;
    }

    multi method make-execution-sub($type, $descr, @lines, @tbl, Bool $add-is) {
        my $res = "$type\[\"$descr\", tbl_ : {@tbl[0]}] :=\nBlock[\{res\},";
        $res ~= "\n\tres = Map[Function[\{record\},";

        $res ~= "\n\t\t" ~
                @lines.map({
                    self.enhance-by-table-params($_.subst('cmd_ : ', '').subst(':= Block[{}, True];', ''), False).trim ~ ';'
                }).join("\n\t\t");
        $res = $res.subst(/';' $/, '');

        $res ~= "\n\t], tbl];";
        $res ~= "\n\tAnd @@ Map[TrueQ, res]";
        $res ~= "\n];";

        if $add-is {
            if self.backgroundDescr {
                $res ~= "\n\nTestBackground[\"{self.backgroundDescr}\"];";
            }
            $res ~= "\n\nVerificationTest[$type\[\"$descr\"\], True, TestID -> \"$descr\"]";
        }

        return $res;
    }

    method enhance-by-table-params(Str $line, Bool $definition) {
        my @params = $line.match(:g, / '<' <-[<>\h]>+ '>' /);
        if @params.elems == 0 {
            if !$line.contains(', record_') {
                return $line.subst(']', ", record_ ]");
            } else {
                return $line.subst('record_', 'record');
            }
        }
        my $rkeys = '{"' ~ @params.map({ $_.substr(1, *- 1) })>>.Str.unique.sort.join('", "') ~ '"}';
        return do if $definition {
            $line.subst(']', ', record_?AssociationQ ]');
        } else {
            $line.subst(', record_?AssociationQ ]', ', KeyTake[record, ' ~ $rkeys ~ ']]');
        }
    }

    method make-preface() {
        my @funcs = <Then When TestBackground ScenarioTemplate>;
        my $res = 'Clear[' ~ @funcs.join(', ') ~ '];' ~ "\n\n";
        $res ~= @funcs.map({ $_ ~ '[___] := (Echo["No definitions.", "' ~ $_ ~ ':"]);' }).join("\n");
        $res ~= "\n\n{self.thickSectionSep}";
        return $res;
    }
}

