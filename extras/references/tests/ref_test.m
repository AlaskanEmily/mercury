%-----------------------------------------------------------------------------%
% Copyright (C) 1998 University of Melbourne.
% This file may only be copied under the terms of the GNU General
% Public License - see the file COPYING in the Mercury distribution.
%-----------------------------------------------------------------------------%
% 
% File      : ref_test.m
% Authors   : pets (Peter Schachte)
% Purpose   : test of reference types
%

:- module ref_test.
:- interface.
:- import_module io.

:- impure pred main(io__state::di, io__state::uo) is det.

:- implementation.

:- import_module int.
:- import_module reference, nb_reference, scoped_update.

main -->
	{ impure new_reference(3,X) },
	{ impure new_nb_reference(3,Y) },
	(
		{ impure update(X, 42) },
		{ impure update(Y, 42) },
		{ semipure value(X,V1) },
		{ semipure value(Y,W1) },
		print(V1),
		nl,
		print(W1),
		nl,
		{same(X, X1)},
		{same(Y, Y1)},
		{ impure update(X1, 7) },
		{ impure update(Y1, 7) },
		{ semipure value(X, V2) },
		{ semipure value(Y, W2) },
		print(V2),
		nl,
		print(W2),
		nl,
		{ impure scope_test }
	;
		{ impure scope_test2 }
	;
		{ semipure value(X, V3) },
		print(V3),
		nl,
		{ semipure value(Y, W3) },
		print(W3),
		nl
	).


%  Here is an example of using references to implement non-backtrackable
%  global variables.  We implement global variables with a function that
%  returns a reference.

:- pragma c_header_code("extern Integer globalvar;").
:- pragma c_code("Integer globalvar = 0;").

:- func globalvar = nb_reference(int).
:- pragma inline(globalvar/0).
:- pragma c_code(globalvar = (Ref::out), will_not_call_mercury, "
	Ref = (Word) &globalvar;
").


%  Here is an example of using the scoped_update module.  This effectively
%  creates two versions of globalvar:  one between the enter_scope/
%  exit_scope pair, and one outside it.

:- impure pred scope_test is failure.

scope_test :-
	small_int(I),
	semipure value(globalvar, V0),
	impure update(globalvar, V0 + I),
	impure scope_test_message("before", V0, V0 + I),
	impure enter_scope(globalvar, Handle),
	small_int(J),
	semipure value(globalvar, V1),
	impure scope_test_message("inside", V1, V1 + (J * 10)),
	impure update(globalvar, V1 + (J * 10)),
	impure exit_scope(Handle),
	semipure value(globalvar, V2),
	impure update(globalvar, V2 + (I * 100)),
	impure scope_test_message("after", V2, V2 + (I * 100)),
	fail.

%  This predicate checks nested enter/exit scope calls.

:- impure pred scope_test2 is failure.

scope_test2 :-
	semipure value(globalvar, V0),
	impure update(globalvar, 0),
	impure scope_test_message("outside", V0, 0),
	impure enter_scope(globalvar, Handle1),
	semipure value(globalvar, V1),
	impure update(globalvar, 1),
	impure scope_test_message("inside 1", V1, 1),
	impure enter_scope(globalvar, Handle2),
	semipure value(globalvar, V2),
	impure update(globalvar, 2),
	impure scope_test_message("inside 2", V2, 2),
	impure exit_scope(Handle2),
	semipure value(globalvar, V3),
	impure update(globalvar, 3),
	impure scope_test_message("inside 1", V3, 3),
	impure exit_scope(Handle1),
	semipure value(globalvar, V4),
	impure update(globalvar, 4),
	impure scope_test_message("outside", V4, 4),
	fail.


:- pred same(T, T).
:- mode same(in, in) is semidet.
:- mode same(in, out) is det.
:- mode same(out, in) is det.

same(X,X).


:- pred small_int(int::out) is multi.

small_int(1).
small_int(2).
small_int(3).

:- impure pred scope_test_message(string::in, int::in, int::in) is det.

:- pragma c_header_code("
#include <stdio.h>
").

:- pragma c_code(scope_test_message(Prefix::in, Old::in, New::in),
		will_not_call_mercury, "
	printf(""%s scope ref = %d; reset to %d\n"", (char *) Prefix,
			(int) Old, (int) New);
").

