% Test overloading resolution for cross-module optimization.
:- module intermod_test.
:- interface.

:- import_module int.

:- pred p(int::out) is det.

:- type t
	--->	f(int)
	;	g.

:- implementation.

:- import_module intermod_test2.

p(X) :-
	Y = f(1),
	Y = f(_),
	Lambda = lambda([Z::int_mode] is det, Z = 2),
	local(Lambda, X).

:- mode int_mode :: out.

:- pred local(pred(int), int).
:- mode local(pred(int_mode) is det, out) is det.

local(Pred, Int) :- call(Pred, Int).
