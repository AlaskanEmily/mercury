:- module test1.

:- type t1 ---> a ; b ; c ; d(undef1).

:- inst x = bound(a ; b ; c).

:- pred p.
p.

:- pred q(undef2).
q(_).

