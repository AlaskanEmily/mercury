% Test case for use of zero-arity higher-order function terms.
% 
% Author: fjh

:- module nullary_ho_func.
:- interface.
:- import_module io.

:- pred main(io__state::di, io__state::uo) is det.

:- implementation.
:- import_module std_util.

:- type nullary_func(T) == ((func) = T).
:- inst nullary_func == ((func) = out is det).

:- func apply_nullary_func(nullary_func(T)) = T.
:- mode apply_nullary_func(in(nullary_func)) = out is det.

apply_nullary_func(F) = apply(F).

:- func apply_func((func) = T) = T.
:- mode apply_func((func) = out is semidet) = out is semidet.
:- mode apply_func((func) = out is det) = out is det.

apply_func(F) = apply(F).

main -->
	{ F = ((func) = 42) },
	{ X = apply(F) },
	{ G = ((func) = (_ :: out) is semidet :- fail) },
	{ H = ((func) = (R :: out) is semidet :- semidet_succeed, R = X) },
	print("X = "), print(X), nl,
	print("apply(F) = "), print(X), nl,
	print("apply_func(F) = "), print(X), nl,
	print("apply_nullary_func(F) = "), print(X), nl,
	( { Y = apply(G) } ->
		print("Y = "), print(Y), nl
	;
		print("Y = apply(G) failed"), nl
	),
	( { Z = apply(H) } ->
		print("Z = "), print(Z), nl
	;
		print("Y = apply(G) failed"), nl
	).

