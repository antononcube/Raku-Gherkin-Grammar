use v6.d;

use Data::Reshapers;

constant $protos = q:to/END/;
proto sub Background($descr) {*}
proto sub ScenarioOutline(@cmdFuncPairs) {*}
proto sub Example($descr) {*}
proto sub Given(Str:D $cmd, |) {*}
proto sub When(Str:D $cmd, |) {*}
proto sub Then(Str:D $cmd, |) {*}
END


class Gherkin::Actions::Raku::TestTemplate {

    has Str $!backgroundDescr = '';

    method TOP($/) {
        make $/.values[0].made;
    }

    method ghk-feature-block($/) {
        my $res;
        with $<ghk-rule-block> { $res = $<ghk-rule-block>.made };
        with $<ghk-example-block-list> { $res = $<ghk-example-block-list>.made };
        make self.make-preface() ~ "\n" ~ $res ~ "\n\ndone-testing;";
    }

    method ghk-rule-block($/) {
        make $<ghk-example-block-list>.made;
    }

    #------------------------------------------------------
    # Basically a degenerated version of ghk-example-block.
    method ghk-background-block($/) {
        my $add-is = False;
        my $descr = $<ghk-background-text-line><ghk-text-line-tail>.made.trim;
        my @res;

        with $<ghk-given-block> { @res.append( $<ghk-given-block>.made ); }

        with $<ghk-when-block> { @res.append( $<ghk-when-block>.made ); }

        with $<ghk-then-block> { $add-is = True; @res.append( $<ghk-then-block>.made ); }

        my $res = $<ghk-background-text-line>.made ~ "\n" ~
                "#{'-' x 60}\n\n" ~
                @res.join("\n\n") ~ "\n\n" ~
                self.make-background-sub($descr, @res, $add-is);

        $!backgroundDescr = $descr;

        make $res;
    }

    method ghk-background-text-line ($/) {
        make '# Background : ' ~  $<ghk-text-line-tail>.made;
    }

    #------------------------------------------------------
    method ghk-example-block-list($/) {
        my @res;
        with $<ghk-background-block> { @res.append($<ghk-background-block>.made); }
        @res.append($<ghk-example-block>>>.made);
        @res.append($<ghk-scenario-outline-block>>>.made);
        make @res.join("\n\n#{'=' x 60}\n");
    }

    method ghk-example-block($/) {
        my $descr = $<ghk-example-text-line><ghk-text-line-tail>.made.trim;
        my @res;

        with $<ghk-given-block> { @res.append( $<ghk-given-block>.made ); }

        with $<ghk-when-block> { @res.append( $<ghk-when-block>.made ); }

        @res.append( $<ghk-then-block>.made );

        make $<ghk-example-text-line>.made ~ "\n" ~
                "#{'-' x 60}\n\n" ~
                @res.join("\n\n") ~ "\n\n" ~
                self.make-example-sub($descr, @res);
    }

    method ghk-example-text-line ($/) {
        make '# Example : ' ~  $<ghk-text-line-tail>.made;
    }

    #------------------------------------------------------
    method ghk-scenario-outline-block($/) {
        my $descr = $<ghk-scenario-outline-text-line><ghk-text-line-tail>.made.trim;
        my @res;

        my @tbl = $<ghk-table-block>.made;

        with $<ghk-given-block> { @res.append( $<ghk-given-block>.made ); }

        with $<ghk-when-block> { @res.append( $<ghk-when-block>.made ); }

        @res.append( $<ghk-then-block>.made );

        @res = @res.map({ self.enhance-by-table-params($_, True) });

        make $<ghk-scenario-outline-text-line>.made ~ "\n" ~
                "#{'-' x 60}\n\n" ~
                @res.join("\n\n") ~ "\n\n" ~
                self.make-scenario-template-sub($descr, @res, @tbl);
    }

    method ghk-scenario-outline-text-line ($/) {
        make '# Scenario Outline : ' ~  $<ghk-text-line-tail>.made;
    }

    #------------------------------------------------------
    method ghk-given-block($/) {
        my @res;
        @res.append($<ghk-given-text-line>.made);
        with $<ghk-given-block-element> { @res.append( $<ghk-given-block-element>>>.made ); }
        make @res;
     }
    method ghk-given-block-element($/) { make $/.values[0].made.subst(' And(', ' Given(');; }
    method ghk-given-text-line($/) {
        make self.make-sub-definition('Given', $<ghk-text-line-tail-arg>.made);
    }

    #------------------------------------------------------
    method ghk-when-block($/) {
        my @res;
        @res.append($<ghk-when-text-line>.made);
        with $<ghk-when-block-element> {
            @res.append( $<ghk-when-block-element>>>.made );
        }
        make @res;
    }
    method ghk-when-block-element($/) { make $/.values[0].made.subst(' And(', ' When('); }
    method ghk-when-text-line($/) {
        make self.make-sub-definition('When', $<ghk-text-line-tail-arg>.made);
    }

    #------------------------------------------------------
    method ghk-then-block($/) {
        my @res;
        @res.append($<ghk-then-text-line>.made);
        with $<ghk-then-block-element> { @res.append( $<ghk-then-block-element>>>.made ); }
        make @res;
    }
    method ghk-then-block-element($/) { make $/.values[0].made.subst(' And(', ' Then('); }
    method ghk-then-text-line($/) {
        make self.make-sub-definition('Then', $<ghk-text-line-tail-arg>.made);
    }

    #------------------------------------------------------
    method ghk-and-text-line($/) {
        make self.make-sub-definition('And', $<ghk-text-line-tail-arg>.made);
    }
    method ghk-asterisk-text-line($/) {
        make self.make-sub-definition('And', $<ghk-text-line-tail-arg>.made);
    }

    #------------------------------------------------------
    method ghk-text-line-tail-arg($/) {
        my $cmd = $<ghk-text-line-tail>.made;
        my $arg;
        if $<ghk-doc-string> { $arg = $<ghk-doc-string>.made; }
        if $<ghk-table-block> { $arg = $<ghk-table-block>.made; }
        make $arg.defined ?? [$cmd, $arg] !! $cmd;
    }

    method ghk-text-line-tail($/) {
        make $/.Str;
    }

    #------------------------------------------------------
    method ghk-doc-string($/) {
        make $<text>.Str;
    }

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
        my $res = "multi sub $type\( '{@cmd[0]}', {@cmd[1].raku} \) \{\}";
        return $res;
    }

    multi method make-sub-call(Str:D $type, @cmd) {
        my $res = "$type\( {|@cmd} \);";
        return $res;
    }

    multi method make-sub-definition(Str:D $type, Str:D $cmd) {
        my $res = "multi sub $type\( \$cmd where * eq '$cmd' \) \{\}";
        return $res;
    }

    multi method make-sub-call(Str:D $type, Str:D $cmd) {
        my $res = "$type\( $cmd' \);";
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
        my $res = "multi sub $type\('$descr') \{";
        $res ~= "\n\t" ~ @lines.map({ $_.subst('multi sub', '').subst('$cmd where * eq ', '').subst('{}', '').trim ~ ';' }).join("\n\t");
        $res ~= "\n}";

        if $add-is {
            if $!backgroundDescr {
                $res ~= "\n\nBackground('$!backgroundDescr');";
            }
            $res ~= "\n\nis $type\(\'$descr\'), True, '$descr';";
        }

        return $res;
    }

    multi method make-execution-sub($type, $descr, @lines, @tbl, Bool $add-is) {
        my $res = "multi sub $type\('$descr', @tbl = {@tbl.raku}) \{";
        $res ~= "\n\tmy @res = do for @tbl -> %record \{";

        $res ~= "\n\t\t" ~
                @lines.map({
                    self.enhance-by-table-params($_.subst('multi sub', '').subst('$cmd where * eq ', '').subst('{}', ''), False).trim ~ ';'
                }).join("\n\t\t");

        $res ~= "\n\t}";
        $res ~= "\n\treturn [&&] @res;";
        $res ~= "\n}";

        if $add-is {
            if $!backgroundDescr {
                $res ~= "\n\nBackground('$!backgroundDescr');";
            }
            $res ~= "\n\nis $type\(\'$descr\'), True, '$descr';";
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
            $line.subst(/ ', %record where' .* ')' /, ', %record.map({ $_.key ∈ ' ~ $rkeys ~ ' }) )');
        }
    }

    method make-preface() {
        my $res = "use v6.d;\n\n#{'=' x 60}\n\n" ~
                $protos ~
                "\n#{'=' x 60}\n\n" ~
                "use Test;\nplan *;" ~
                "\n\n#{'=' x 60}";
        return $res;
    }
}

