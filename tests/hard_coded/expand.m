% Test case for io__write
% 
% Author: trd

:- module expand.
:- interface.
:- import_module io.

:- pred main(io__state::di, io__state::uo) is det.

:- implementation.

:- import_module list, int, std_util, term, map, string, prolog.

:- pred test_builtins(io__state::di, io__state::uo) is det.
:- pred test_discriminated(io__state::di, io__state::uo) is det.
:- pred test_polymorphism(io__state::di, io__state::uo) is det.
:- pred test_other(io__state::di, io__state::uo) is det.
:- pred newline(io__state::di, io__state::uo) is det.
:- pred test_functor(T::in, io__state::di, io__state::uo) is det.
:- pred test_arg(T::in, io__state::di, io__state::uo) is det.
:- pred test_expand(T::in, io__state::di, io__state::uo) is det.
:- pred test_all(T::in, io__state::di, io__state::uo) is det.


:- type enum	--->	one	;	two	;	three.

:- type fruit	--->	apple(list(int))
		;	banana(list(enum)).

:- type thingie	--->	foo ; bar(int) ; bar(int, int) ; qux(int) ;
			quux(int) ; quuux(int, int) ; wombat ; 
			zoom(int) ; zap(int, float) ; zip(int, int) ;
			zop(float, float).

:- type poly(A, B)	--->	poly_one(A) ; poly_two(B) ; 
				poly_three(B, A, poly(B, A)).

:- type no_tag		---> 	qwerty(int).

main -->
	test_discriminated,
	test_polymorphism,
	test_builtins, 
	test_other.


test_discriminated -->
	io__write_string("TESTING DISCRIMINATED UNIONS\n"),

		% test enumerations
	test_all(one), newline,
	test_all(two), newline,
	test_all(three), newline,

		% test simple tags
	test_all(apple([9,5,1])), newline,
	test_all(banana([three, one, two])), newline,


		% test complicated tags
	test_all(zop(3.3, 2.03)), newline,
	test_all(zip(3, 2)), newline,
	test_all(zap(3, -2.111)), newline,

		% test complicated constant

	test_all(wombat), newline,
	test_all(foo), newline,

	newline.	

test_all(T) -->
	test_functor(T), newline,
	test_arg(T), newline,
	test_expand(T), newline.

test_functor(T) -->
	{ functor(T, Functor, Arity) },
	io__write_string(Functor),
	io__write_string("/"),
	io__write_int(Arity).

test_arg(T) -->
	{ functor(T, Functor, Arity) },
	( 
		{ arg(Arity, T, Argument) }
	->
		{ string__format("argument %d of functor %s was:", [i(Arity),
			s(Functor)], Str) },
		io__write_string(Str),
		io__print(Argument)
	;
		io__write_string("no arguments")
	).

test_expand(T) -->
	{ expand(T, Functor, Arity, Arguments) },
	{ string__format("expand: functor %s arity %d arguments ", [s(Functor),
		i(Arity)], Str) },
	io__write_string(Str),
	io__write_string("["),
	io__write_list(Arguments, ", ", io__print),
	io__write_string("]").


test_polymorphism -->
	io__write_string("TESTING POLYMORPHISM\n"),
	test_all(poly_two(3)), newline,
	test_all(poly_three(3.33, 4, poly_one(9.11))), newline,
	test_all(poly_one([2399.3])), newline,

	newline.


test_builtins -->
	io__write_string("TESTING BUILTINS\n"),

		% test strings
 	test_all(""), newline,
 	test_all("Hello, world\n"), newline,
 	test_all("Foo%sFoo"), newline,
 	test_all(""""), newline,	% interesting - prints """ of course

		% test characters
	test_all('a'), newline,
	test_all('&'), newline,

		% test floats
	test_all(3.14159), newline,
	test_all(11.28324983E-22), newline,
	test_all(22.3954899E22), newline,

		% test integers
	test_all(-65), newline,
	test_all(4), newline,

		% test univ.
	{ type_to_univ(["hi! I'm a univ!"], Univ) }, 
	test_all(Univ), newline,
	
		% test predicates	
	test_all(newline), newline,

	newline.

	% Note: testing abstract types is always going to have results
	% that are dependent on the implementation. If someone changes
	% the implementation, the results of this test can change.

test_other -->
	io__write_string("TESTING OTHER TYPES\n"),
	{ term__init_var_supply(VarSupply) },
	{ term__create_var(VarSupply, Var, NewVarSupply) },
	test_all(Var), newline,
	test_all(VarSupply), newline,
	test_all(NewVarSupply), newline,

		% presently, at least, map is an equivalence and
		% an abstract type.
	{ map__init(Map) },
	test_all(Map), newline,

		% a no tag type 
	test_all(qwerty(4)), newline,

	newline.

newline -->
	io__write_char('\n').


