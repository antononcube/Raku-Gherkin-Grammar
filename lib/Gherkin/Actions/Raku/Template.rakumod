use v6.d;

constant $protos = q:to/END/;
proto Background(@cmdFuncPairs) {*}
proto ScenarioOutline(@cmdFuncPairs) {*}
proto Given(Str:D $cmd, |) {*}
proto When(Str:D $cmd, |) {*}
proto Then(Str:D $cmd, |) {*}
END


class Gherkin::Actions::Raku::Template {
    method TOP($/) {
        make $/.values[0].made;
    }

    method ghk-feature-block($/) {
        my $res;
        with $<ghk-rule-block> { $res = $<ghk-rule-block>.made };
        with $<ghk-example-block> { $res = $<ghk-example-block>.made };
        make self.make-preface() ~ "\n\n" ~ $res;
    }

    method ghk-rule-block($/) {
        make $<ghk-example-block>>>.made.join("\n\n");
    }

    #------------------------------------------------------
    method ghk-example-block($/) {
        my @res;
        @res.append( $<ghk-example-text-line>.made );
        with $<ghk-given-block> { @res.append( $<ghk-given-block>.made ); }
        with $<ghk-when-block> { @res.append( $<ghk-when-block>.made ); }
        @res.append( $<ghk-then-block>.made );
        make @res.join("\n\n");
    }

    method ghk-example-text-line ($/) {
        make '# Example : ' ~  $<ghk-text-line-tail>.made;
    }

    #------------------------------------------------------
    method ghk-given-block($/) {
        my @res;
        @res.append($<ghk-given-text-line>.made);
        with $<ghk-given-block-element> { @res.append( $<ghk-given-block-element>>>.made ); }
        make @res.join("\n\n");
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
        make @res.join("\n\n");
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
        make @res.join("\n\n");
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
        my $res = "multi sub $type\( {|@cmd} \) \{ \}";
        return $res;
    }

    multi method make-sub-call(Str:D $type, Str:D $cmd) {
        my $res = "multi sub $type\( \"$cmd\" \) \{ \}";
        return $res;
    }

    method make-preface() {
        my $res = "use Test;\n\n#{'-' x 60}\n\n" ~ $protos ~ "\n\n#{'-' x 60}";
        return $res;
    }
}

