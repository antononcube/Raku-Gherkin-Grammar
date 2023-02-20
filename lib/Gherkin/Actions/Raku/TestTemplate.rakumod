use v6.d;

use Data::Reshapers;

constant $protos = q:to/END/;
proto sub Background(@cmdFuncPairs) {*}
proto sub ScenarioOutline(@cmdFuncPairs) {*}
proto sub Example($descr) {*}
proto sub Given(Str:D $cmd, |) {*}
proto sub When(Str:D $cmd, |) {*}
proto sub Then(Str:D $cmd, |) {*}
END


class Gherkin::Actions::Raku::TestTemplate {
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
    method ghk-example-block-list($/) {
        make $<ghk-example-block>>>.made.join("\n\n#{'=' x 60}\n");
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
    method ghk-given-block($/) {
        my @res;
        @res.append($<ghk-given-text-line>.made);
        with $<ghk-given-block-element> { @res.append( $<ghk-given-block-element>>>.made ); }
        make @res;
     }
    method ghk-given-block-element($/) { make $/.values[0].made.subst(' And(', ' Given(');; }
    method ghk-given-text-line($/) {
        make self.make-sub-call('Given', $<ghk-text-line-tail-arg>.made);
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
    method ghk-when-block-element($/) { make $/.values[0].made.subst(' And(', ' When(');; }
    method ghk-when-text-line($/) {
        make self.make-sub-call('When', $<ghk-text-line-tail-arg>.made);
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
        make self.make-sub-call('Then', $<ghk-text-line-tail-arg>.made);
    }

    #------------------------------------------------------
    method ghk-and-text-line($/) {
        make self.make-sub-call('And', $<ghk-text-line-tail-arg>.made);
    }
    method ghk-asterisk-text-line($/) {
        make self.make-sub-call('And', $<ghk-text-line-tail-arg>.made);
    }

    #------------------------------------------------------
    method ghk-text-line-tail-arg($/) {
        my $cmd = $<ghk-text-line-tail>.made;
        my $arg;
        if $<ghk-doc-string> { $arg = $<ghk-doc-string>.made; }
        if $<md-table-block> { $arg = $<md-table-block>.made; }
        make $arg.defined ?? [$cmd, $arg] !! $cmd;
    }

    method ghk-text-line-tail($/) {
        make $/.Str;
    }

    #------------------------------------------------------
    method md-table-block($/) {
        my @header = $<hearder>.made;
        my @rows = $<rows>>>.made;
        my @res = @rows.map({ @header Z=> $_ });
        return @res;
    }
    method md-table-row($/) {
        return $<md-table-field>>>.made;
    }
    method md-table-field($/) {
        return $/.Str;
    }

    #------------------------------------------------------
    multi method make-sub-call(Str:D $type, @cmd) {
        my $res = "multi sub $type\( {|@cmd} \) \{\}";
        return $res;
    }

    multi method make-sub-call(Str:D $type, Str:D $cmd) {
        my $res = "multi sub $type\( '$cmd' \) \{\}";
        return $res;
    }

    multi method make-example-sub($descr, @lines) {
        my $res = "multi sub Example('$descr') \{";
        $res ~= "\n\t" ~ @lines.map({ $_.subst('multi sub', '').subst('{}', '').trim ~ ';' }).join("\n\t");
        $res ~= "\n}\n\nis Example(\'$descr\'), True, '$descr';";
        return $res;
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

