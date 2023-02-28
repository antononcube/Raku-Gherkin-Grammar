use v6.d;

use Gherkin::Actions::Raku::TestTemplate;

class Gherkin::Actions::Mathematica::TestTemplate
        is Gherkin::Actions::Raku::TestTemplate {

    # method TOP($/)

    # method ghk-feature-block($/)

    # method ghk-rule-block($/)

    #------------------------------------------------------

    method ghk-background-text-line ($/) {
        make '(* Background : ' ~  $<ghk-text-line-tail>.made ~ '*)';
    }

    #------------------------------------------------------
    method ghk-example-text-line ($/) {
        make '(* Example : ' ~  $<ghk-text-line-tail>.made ~ '*)';
    }

    #------------------------------------------------------
    method ghk-scenario-outline-text-line ($/) {
        make '(* Scenario Outline : ' ~  $<ghk-text-line-tail>.made ~ '*)';
    }

    #------------------------------------------------------
    method ghk-given-block-element($/) { make $/.values[0].made.subst(' And[', ' Given['); }
    method ghk-given-text-line($/) {
        make self.make-sub-definition('Given', $<ghk-text-line-tail-arg>.made);
    }

    #------------------------------------------------------
    method ghk-when-block-element($/) { make $/.values[0].made.subst(' And[', ' When['); }
    method ghk-when-text-line($/) {
        make self.make-sub-definition('When', $<ghk-text-line-tail-arg>.made);
    }

    #------------------------------------------------------
    method ghk-then-block-element($/) { make $/.values[0].made.subst(' And[', ' Then['); }
    method ghk-then-text-line($/) {
        make self.make-sub-definition('Then', $<ghk-text-line-tail-arg>.made);
    }

    #------------------------------------------------------
    # method ghk-and-text-line($/)
    # method ghk-asterisk-text-line($/)

    #------------------------------------------------------
    # method ghk-text-line-tail-arg($/)

    #------------------------------------------------------
    # method ghk-doc-string($/)

    #------------------------------------------------------
    method ghk-table-block($/) {
        my @header = $<header><ghk-table-row>.made;
        my @rows = $<rows><ghk-table-row>>>.made;
        my @res = @rows.map({ @header Z=> $_.Array })>>.Hash.Array;
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
        my $res = "$type\[ '{@cmd[0]}', {@cmd[1].raku} \] := Block[\{\}, True];";
        return $res;
    }

    multi method make-sub-call(Str:D $type, @cmd) {
        my $res = "$type\[ {|@cmd} \];";
        return $res;
    }

    multi method make-sub-definition(Str:D $type, Str:D $cmd) {
        my $res = "$type\[ cmd_ : '$cmd'\] := Block[\{\}, True];";
        return $res;
    }

    multi method make-sub-call(Str:D $type, Str:D $cmd) {
        my $res = "$type\[ $cmd \];";
        return $res;
    }

    multi method make-background-sub($descr, @lines, $add-is) {
        return self.make-execution-sub('Background', $descr, @lines, $add-is);
    }

    multi method make-example-sub($descr, @lines) {
        return self.make-execution-sub('Example', $descr, @lines, True);
    }

    multi method make-scenario-template-sub($descr, @lines, @tbl) {
        return self.make-execution-sub('ScenarioTemplate', $descr, @lines, @tbl, True);
    }

    multi method make-execution-sub($type, $descr, @lines, Bool $add-is) {
        my $res = "$type\[\"$descr\"] \{";
        $res ~= "\n\t" ~ @lines.map({ $_.subst('cmd_ : ', '').subst(':= Block[{}, True];', '').trim ~ ';' }).join("\n\t");
        $res ~= "\n}";

        if $add-is {
            if self.backgroundDescr {
                $res ~= "\n\nBackground[\"{self.backgroundDescr}\"];";
            }
            $res ~= "\n\nVerificationTest[ $type\[\"$descr\"\], True, TestID -> \"$descr\"]";
        }

        return $res;
    }

    multi method make-execution-sub($type, $descr, @lines, @tbl, Bool $add-is) {
        my $res = "$type\[\"$descr\", tbl = {@tbl.raku}) \{";
        $res ~= "\n\tres = Map[Function[\{record\},";

        $res ~= "\n\t\t" ~
                @lines.map({
                    self.enhance-by-table-params($_.subst('cmd_ : ', '').subst(':= Block[{}, True];', ''), False).trim ~ ';'
                }).join("\n\t\t");

        $res ~= "\n\t], tbl];";
        $res ~= "\n\tAnd @@ Map[TrueQ, res];";
        $res ~= "\n];";

        if $add-is {
            if self.backgroundDescr {
                $res ~= "\n\nBackground[\"{self.backgroundDescr}\"];";
            }
            $res ~= "\n\nVerificationTest[$type\[\'$descr\'\], True, TestID -> \"$descr\"]";
        }

        return $res;
    }

    method enhance-by-table-params(Str $line, Bool $definition) {
        my @params = $line.match(:g, / '<' <-[<>\h]>+ '>' /);
        if @params.elems == 0 {
            return $line.subst(')', ', %record )');
        }
        my $rkeys = '<' ~ @params.map({ $_.substr(1, *- 1) })>>.Str.unique.sort.join(' ') ~ '>';
        return do if $definition {
            $line.subst(')', ', %record where *.keys.all ∈ ' ~ $rkeys ~ ' )');
        } else {
            $line.subst(/ ', %record where' .* ')' /, ', %record.grep({ $_.key ∈ ' ~ $rkeys ~ ' }).Hash )');
        }
    }

    method make-preface() {
        my $res = self.protos ~ "\n\n{self.thickSectionSep}";
        return $res;
    }
}

