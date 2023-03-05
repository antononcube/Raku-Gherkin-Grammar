BeginTestSection["DateTime_interpretation_test"];

Clear[Then, When, TestBackground, ScenarioTemplate];

Then[___] := (Echo["No definitions.", "Then:"]);
When[___] := (Echo["No definitions.", "When:"]);
TestBackground[___] := (Echo["No definitions.", "TestBackground:"]);
ScenarioTemplate[___] := (Echo["No definitions.", "ScenarioTemplate:"]);

(**************************************************************)
(* Example : Full date *)
(*------------------------------------------------------------*)

When[ "2023-02-20T00:00:00Z" ] := Block[{}, True];

Then[ "the result is DateTime" ] := Block[{}, True];

Then[ "the year is \"2023\", month is \"2\", and date \"20\"" ] := Block[{}, True];

Example["Full date"] := Block[{},
  When[ "2023-02-20T00:00:00Z" ];
  Then[ "the result is DateTime" ];
  Then[ "the year is \"2023\", month is \"2\", and date \"20\"" ]
];

VerificationTest[ Example["Full date"], True, TestID -> "Full date"];

(**************************************************************)
(* Example : ISO date *)
(*------------------------------------------------------------*)

When[ "2032-10-01" ] := Block[{}, True];

Then[ "the result is DateTime" ] := Block[{}, True];

Then[ "the year is \"2032\", month is \"10\", and date \"1\"" ] := Block[{}, True];

Example["ISO date"] := Block[{},
  When[ "2032-10-01" ];
  Then[ "the result is DateTime" ] &&
      Then[ "the year is \"2032\", month is \"10\", and date \"1\"" ]
];

VerificationTest[ Example["ISO date"], True, TestID -> "ISO date"];

(**************************************************************)
(* Example : Full blown date time spec *)
(*------------------------------------------------------------*)

When[ "Sun, 06 Nov 1994 08:49:37 GMT" ] := Block[{}, True];

Then[ "the result is DateTime" ] := Block[{}, True];

Then[ "the year is \"1994\", month is \"11\", and date \"6\"" ] := Block[{}, True];

Example["Full blown date time spec"] := Block[{},
  When[ "Sun, 06 Nov 1994 08:49:37 GMT" ];
  Then[ "the result is DateTime" ] &&
      Then[ "the year is \"1994\", month is \"11\", and date \"6\"" ]
];

VerificationTest[ Example["Full blown date time spec"], True, TestID -> "Full blown date time spec"];

(**************************************************************)
(* Example : Simple table spec *)
(*------------------------------------------------------------*)

When[ "today, yesterday, tomorrow" ] :=
    Block[{},
      result = {Today, Yesterday, Tomorrow}
    ];

Then[ "the results adhere to:", tbl_ : {
  <|"Spec" -> "today", "Result" -> "Date.today.DateTime"|>,
  <|"Spec" -> "yesterday", "Result" -> "Date.today.DateTime.earlier(:1day)"|>,
  <|"Spec" -> "tomorrow", "Result" -> "Date.today.DateTime.later(:1day)"|>} ] :=
    Block[{},
      True
    ];

Example["Simple table spec"] := Block[{},
  When[ "today, yesterday, tomorrow" ];
  Then[ "the results adhere to:", {
    <|"Spec" -> "today", "Result" -> "Date.today.DateTime"|>,
    <|"Spec" -> "yesterday", "Result" -> "Date.today.DateTime.earlier(:1day)"|>,
    <|"Spec" -> "tomorrow", "Result" -> "Date.today.DateTime.later(:1day)"|>} ]
];

VerificationTest[ Example["Simple table spec"], True, TestID -> "Simple table spec"];

(**************************************************************)
(* Scenario Outline : Template with table spec *)
(*------------------------------------------------------------*)

When[ "the argument is <Spec>" , record_?AssociationQ ] :=
    Block[{},
      Echo[record["Spec"], "When[ the argument is <Spec>, __] : "];
      result = SemanticInterpretation[record["Spec"]];
    ];

Then[ "the interpretation is <Result>" , record_?AssociationQ ] :=
    Block[{res},
      res = StringReplace[record["Result"],
        {"Date.today.DateTime" -> "Today",
          "Date.new(" ~~ x:__ ~~ ").DateTime" :> "DateObject[{" <> x <>"}]",
          ".earlier(:1day)" -> "-Quantity[1,\"Days\"]",=
          ".later(:1day)" -> "+Quantity[1,\"Days\"]"
        }];
      Echo[res, "Then[the interpretation is <Result>, __] : "];
      result == ToExpression[res]
    ];

ScenarioTemplate["Template with table spec", tbl_ : {
  <|"Spec" -> "today", "Result" -> "Date.today.DateTime"|>,
  <|"Spec" -> "Oct 20 2022", "Result" -> "Date.new(2022, 10, 20).DateTime"|>,
  <|"Spec" -> "11/2/2012", "Result" -> "Date.new(2012, 11, 2).DateTime"|>}] :=
    Block[{res},
      res = Map[Function[{record},
        When[ "the argument is <Spec>" , KeyTake[record, {"Spec"}]];
        Then[ "the interpretation is <Result>" , KeyTake[record, {"Result"}]]
      ], tbl];
      And @@ Map[TrueQ, res]
    ];

VerificationTest[ScenarioTemplate["Template with table spec"], True, TestID -> "Template with table spec"];

EndTestSection[];