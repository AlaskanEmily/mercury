% A test case to exercise the code for expanding hash tables.

:- module expand.

:- interface.

:- import_module io.

:- pred main(io__state::di, io__state::uo) is det.

:- implementation.

:- import_module bool, int, list, assoc_list, std_util, random, require.

main -->
	{ random__init(0, RS0) },
	{ random__permutation(range(0, 1023), Perm, RS0, RS1) },
	{ choose_signs_and_enter(Perm, Solns, RS1, _RS) },
	( { test_tables(Solns, yes) } ->
		io__write_string("Test successful.\n")
	;
		io__write_string("Test unsuccessful.\n")
	).
	% io__report_tabling_stats.

:- func range(int, int) = list(int).
range(Min, Max) =
	(if Min > Max then
		[]
	else
		[Min | range(Min + 1, Max)]
	).

:- pred choose_signs_and_enter(list(int)::in, assoc_list(int)::out,
	random__supply::mdi, random__supply::muo) is det.

choose_signs_and_enter([], [], RS, RS).
choose_signs_and_enter([N | Ns], [I - S | ISs], RS0, RS) :-
	random__random(Random, RS0, RS1),
	( Random mod 2 = 0 ->
		I = N
	;
		I = 0 - N
	),
	sum(I, S),
	choose_signs_and_enter(Ns, ISs, RS1, RS).

:- pred test_tables(assoc_list(int)::in, bool::out) is det.

test_tables([], yes).
test_tables([I - S0 | Is], Correct) :-
	sum(I, S1),
	( S0 = S1 ->
		test_tables(Is, Correct)
	;
		Correct = no
	).

:- pred sum(int::in, int::out) is det.
:- pragma memo(sum/2).

sum(N, F) :-
	( N < 0 ->
		sum(0 - N, NF),
		F = 0 - NF
	; N = 1 ->
		F = 1
	;
		sum(N - 1, F1),
		F is N + F1
	).
