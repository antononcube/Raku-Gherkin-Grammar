use v6.d;

constant $protos = q:to/END/;
proto Given(Str:D $cmd, &func) {*}
proto When(Str:D $cmd, &func) {*}
proto Then(Str:D $cmd, &func) {*}
proto Background(@cmdFuncPairs) {*}
proto ScenarioOutline(@cmdFuncPairs) {*}
END


class Gherkin::Actions::Raku::Template {
    method TOP($/) {
        make $/.values[0].made;
    }

    method ghk-rule-block($/) { }

    method ghk-feature-block($/) { }

    method ghk-example-block($/) { }

    method ghk-given-block($/) { }
    method ghk-given-block-element($/) { make $/.values[0].made; }

    method ghk-when-block($/) { }
    method ghk-when-block-element($/) { make $/.values[0].made; }

    method ghk-then-block($/) { }
    method ghk-then-block-element($/) { make $/.values[0].made; }

    method md-table-block($/) {

    }

    method make-sub-call(Str:D $type, Str:D $cmd) {
        my $res = "multi sub $type\( $cmd, -> \{ \} \) \{ \}";
        return $res;
    }

    method make-preface(Str:D $type, Str:D $cmd) {
        my $res = "use Test;\n\n#{'-' x 60}\n\n" ~ $protos ~ "\n\n#{'-' x 60}\n\n";
        return $res;
    }
}

