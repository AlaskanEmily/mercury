%-----------------------------------------------------------------------------%
%
% Main author: fjh.
%
% This file should be loaded into np before any of the others.
% (This is done automatically if you just load 'doit.nl'.)
% We should perhaps use ensure_loaded to achieve this, but that
% declaration is broken in NU-Prolog.
%
%-----------------------------------------------------------------------------%

% Declare the appropriate operators.

:- op(1199, fx, (module)).
:- op(1199, fx, (end_module)).

:- op(1199, fx, (export_module)).
:- op(1199, fx, (export_sym)).
:- op(1199, fx, (export_pred)).
:- op(1199, fx, (export_cons)).
:- op(1199, fx, (export_type)).
:- op(1199, fx, (export_adt)).
:- op(1199, fx, (export_op)).

:- op(1199, fx, (import_module)).
:- op(1199, fx, (import_sym)).
:- op(1199, fx, (import_pred)).
:- op(1199, fx, (import_cons)).
:- op(1199, fx, (import_type)).
:- op(1199, fx, (import_adt)).
:- op(1199, fx, (import_op)).

:- op(1199, fx, (use_module)).
:- op(1199, fx, (use_sym)).
:- op(1199, fx, (use_pred)).
:- op(1199, fx, (use_cons)).
:- op(1199, fx, (use_type)).
:- op(1199, fx, (use_adt)).
:- op(1199, fx, (use_op)).

:- op(1199, fx, (rule)).

:- op(1199, fx, (mode)).
:- op(1199, fx, (inst)).
:- op(1179, xfy, (--->)).
:- op(1175, xfx, (::)).

% Prevent warnings about undefined predicates
% when the interpreter tries to execute the new declarations.

:- assert(rule(_)).

:- assert(mode(_)).
:- assert(inst(_)).

:- assert(module(_)).
:- assert(end_module(_)).
:- assert(interface).
:- assert(implementation).

:- assert(import_module(_)).
:- assert(import_sym(_)).
:- assert(import_pred(_)).
:- assert(import_cons(_)).
:- assert(import_type(_)).
:- assert(import_adt(_)).
:- assert(import_op(_)).

:- assert(export_module(_)).
:- assert(export_sym(_)).
:- assert(export_pred(_)).
:- assert(export_cons(_)).
:- assert(export_type(_)).
:- assert(export_adt(_)).
:- assert(export_op(_)).

:- assert(use_module(_)).
:- assert(use_sym(_)).
:- assert(use_pred(_)).
:- assert(use_cons(_)).
:- assert(use_type(_)).
:- assert(use_adt(_)).
:- assert(use_op(_)).

%-----------------------------------------------------------------------------%
