:- module nondet_live.
:- interface.

:- pred a1(int::in, int::in, int::out) is nondet.
:- pred a2(int::in, int::in, int::out) is nondet.
:- pred a3(int::in, int::in, int::out) is nondet.

:- implementation.
:- import_module int.

a1(X, _, Y) :-
	A = 42,
	(
		b(X, X),
		V = 10
	;
		b(A, A),
		V = 20
	),
	some [W] (
		c(V, W),
		d(W, Y)
	).

a2(X, _, Y) :-
	A = 42,
	(
		X = 45,
		b(X, X),
		V = 10
	;
		X = 47,
		b(A, A),
		V = 20
	),
	some [W] (
		c(V, W),
		d(W, Y)
	).


a3(X, _, Y) :-
	A = 42,
	(
		X = 45
	->
		b(X, X),
		V = 10
	;
		b(A, A),
		V = 20
	),
	some [W] (
		c(V, W),
		d(W, Y)
	).

:- pred b(int::in, int::out) is nondet.
:- pred c(int::in, int::out) is nondet.
:- pred d(int::in, int::out) is nondet.

:- external(b/2).
:- external(c/2).
:- external(d/2).

:- pragma foreign_code("Erlang", "
b_2_p_0(_, _) -> void.
c_2_p_0(_, _) -> void.
d_2_p_0(_, _) -> void.
").
