:- module singleton_test.
:- interface.
:- import_module list, io.

:- pred my_append(list(int), list(int), list(int)).
:- mode my_append(in, in, out) is det.

:- func my_append_func(list(int), list(int)) = list(int).
:- mode my_append_func(in, in) = out is det.

:- func my_c_func(int, int) = int.
:- mode my_c_func(in, in) = out is det.

:- pred my_c_pred(int, int, int).
:- mode my_c_pred(in, in, out) is det.

:- pred c_hello_world(string::in, io__state::di, io__state::uo) is det.
:- implementation.
:- import_module int.

my_append([], L, L) :-
	L = L2.
my_append([H | T], L, [H | NT]) :-
	my_append(T, L, NT).

my_append_func([], L) = L :- L1 = L2.
my_append_func([H | T], L) = [H | my_append_func(L, L)].

:- pragma c_code(my_c_pred(X::in, Y::in, Z::out), will_not_call_mercury, "
	Z = 2 * X;
").

:- pragma c_code(my_c_func(X::in, Y::in) = (Z::out), will_not_call_mercury, "
	Z = 2 * Y;
").

:- pragma c_header_code("#include <stdio.h>").

:- pragma c_code(c_hello_world(Msg::in, IO0::di, IO::uo),
		will_not_call_mercury, "
	printf(""Hello, world"");
	IO = IO0;
").
