% This source file is hereby placed in the public domain.  -fjh (the author).

%-----------------------------------------------------------------------------%
:- module mercury_lib.
:- interface.
:- import_module io.

% To avoid link errors, there still has to be a main/2 defined somewhere
% in the program; it won't be used, unless the C program calls
% mercury_call_main(), which will call main/2.
:- pred main(io__state::di, io__state::uo) is det.

% a Mercury predicate with multiple modes
:- pred foo(int).
:- mode foo(in) is semidet.
:- mode foo(out) is multi.

% a Mercury function with multiple modes
:- func bar(int) = int.
:- mode bar(in) = out is det.
:- mode bar(out) = in is det.
:- mode bar(in) = in is semidet.

% a semidet (i.e. partial) Mercury function
:- func baz(int) = int.
:- mode baz(in) = out is semidet.

%-----------------------------------------------------------------------------%
:- implementation.
:- import_module std_util, int, list.

% for this example, main/2 isn't useful
main --> [].

% well, this is just a silly example...
foo(42).
foo(53).
foo(197).

bar(X) = X + 1.

baz(1) = 9.
baz(2) = 16.
baz(3) = 27.

%-----------------------------------------------------------------------------%

% The following code provides provides access to the Mercury predicate foo
% from C code.

:- pragma export(foo(in), "foo_test").

:- pragma export(bar(in) = out, "bar").
:- pragma export(bar(in) = in,  "bar_test").
:- pragma export(bar(out) = in, "bar_inverse").

:- pragma export(baz(in) = out, "baz").

	% The nondet mode of `foo' cannot be exported directly with
	% the current Mercury/C interface.  To get all solutions,
	% must define a predicate which returns all the solutions of foo,
	% and export it to C.  We give it the name foo_list() in C.
:- pred all_foos(list(int)::out) is det.
:- pragma export(all_foos(out), "foo_list").
all_foos(L) :- solutions((pred(X::out) is multi :- foo(X)), L).

	% If we just want one solution, and don't care which one, then
	% we can export a `cc_multi' (committed-choice nondeterminism)
	% version of `foo'. We give it the name one_foo().
:- pred cc_foo(int::out) is cc_multi.
:- pragma export(cc_foo(out), "one_foo").
cc_foo(X) :- foo(X).

%-----------------------------------------------------------------------------%
