%-----------------------------------------------------------------------------%
% vim: ft=mercury ts=4 sw=4 et
%-----------------------------------------------------------------------------%
% Copyright (C) 1996-2006 The University of Melbourne.
% This file may only be copied under the terms of the GNU General
% Public License - see the file COPYING in the Mercury distribution.
%-----------------------------------------------------------------------------%

% File: prog_io_goal.m.
% Main author: fjh.

% This module defines the predicates that parse goals.

%-----------------------------------------------------------------------------%

:- module parse_tree.prog_io_goal.
:- interface.

:- import_module parse_tree.prog_data.
:- import_module parse_tree.prog_item.

:- import_module list.
:- import_module term.

%-----------------------------------------------------------------------------%

    % Convert a single term into a goal.
    %
:- pred parse_goal(term::in, goal::out, prog_varset::in, prog_varset::out)
    is det.

    % Convert a term, possibly starting with `some [Vars]', into
    % a list of the quantified variables, a list of quantified
    % state variables, and a goal. (If the term doesn't start
    % with `some [Vars]', we return empty lists of variables.)
    %
:- pred parse_some_vars_goal(term::in, list(prog_var)::out,
    list(prog_var)::out, goal::out, prog_varset::in, prog_varset::out)
    is det.

    % parse_pred_expression/3 converts the first argument to a :-/2
    % higher-order pred expression into a list of variables, a list
    % of their corresponding modes, and a determinism.
    %
:- pred parse_pred_expression(term::in, lambda_eval_method::out,
    list(prog_term)::out, list(mer_mode)::out, determinism::out) is semidet.

    % parse_dcg_pred_expression/3 converts the first argument to a -->/2
    % higher-order DCG pred expression into a list of arguments, a list
    % of their corresponding modes and the two DCG argument modes, and a
    % determinism.
    % This is a variant of the higher-order pred syntax:
    %   `(pred(Var1::Mode1, ..., VarN::ModeN, DCG0Mode, DCGMode)
    %       is Det --> Goal)'.
    %
:- pred parse_dcg_pred_expression(term::in, lambda_eval_method::out,
    list(prog_term)::out, list(mer_mode)::out, determinism::out) is semidet.

    % parse_func_expression/3 converts the first argument to a :-/2
    % higher-order func expression into a list of arguments, a list
    % of their corresponding modes, and a determinism.  The syntax
    % of a higher-order func expression is
    %   `(func(Var1::Mode1, ..., VarN::ModeN) = (VarN1::ModeN1) is Det
    %       :- Goal)'
    % or
    %   `(func(Var1, ..., VarN) = (VarN1) is Det :- Goal)'
    %       where the modes are assumed to be `in' for the
    %       function arguments and `out' for the result
    % or
    %   `(func(Var1, ..., VarN) = (VarN1) :- Goal)'
    %       where the modes are assumed as above, and the
    %       determinism is assumed to be det
    % or
    %   `(func(Var1, ..., VarN) = (VarN1). '
    %
:- pred parse_func_expression(term::in, lambda_eval_method::out,
    list(prog_term)::out, list(mer_mode)::out, determinism::out) is semidet.

%-----------------------------------------------------------------------------%
%-----------------------------------------------------------------------------%

:- implementation.

:- import_module mdbcomp.prim_data.
:- import_module parse_tree.prog_io.
:- import_module parse_tree.prog_io_util.
:- import_module parse_tree.prog_mode.
:- import_module parse_tree.prog_out.

:- import_module int.
:- import_module map.
:- import_module pair.
:- import_module string.
:- import_module term.

%-----------------------------------------------------------------------------%

parse_goal(Term, Goal, !VarSet) :-
    % We could do some error-checking here, but all errors are picked up
    % in either the type-checker or parser anyway.

    % First, get the goal context.
    (
        Term = term.functor(_, _, Context)
    ;
        Term = term.variable(_),
        term.context_init(Context)
    ),
    % We just check if it matches the appropriate pattern for one of the
    % builtins. If it doesn't match any of the builtins, then it's just
    % a predicate call.
    (
        % Check for builtins...
        Term = term.functor(term.atom(Name), Args, Context),
        parse_goal_2(Name, Args, GoalExpr, !VarSet)
    ->
        Goal = GoalExpr - Context
    ;
        % It's not a builtin.
        term.coerce(Term, ArgsTerm),
        (
            % Check for predicate calls.
            sym_name_and_args(ArgsTerm, SymName, Args)
        ->
            Goal = call_expr(SymName, Args, purity_pure) - Context
        ;
            % A call to a free variable, or to a number or string.
            % Just translate it into a call to call/1 - the
            % typechecker will catch calls to numbers and strings.
            Goal = call_expr(unqualified("call"), [ArgsTerm], purity_pure)
                - Context
        )
    ).

%-----------------------------------------------------------------------------%

:- pred parse_goal_2(string::in, list(term)::in, goal_expr::out,
    prog_varset::in, prog_varset::out) is semidet.

    % Since (A -> B) has different semantics in standard Prolog
    % (A -> B ; fail) than it does in NU-Prolog or Mercury (A -> B ; true),
    % for the moment we'll just disallow it.
    % For consistency we also disallow if-then without the else.

parse_goal_2("true", [], true_expr, !V).
parse_goal_2("fail", [], fail_expr, !V).
parse_goal_2("=", [A0, B0], unify_expr(A, B, purity_pure), !V) :-
    term.coerce(A0, A),
    term.coerce(B0, B).
parse_goal_2(",", [A0, B0], conj_expr(A, B), !V) :-
    parse_goal(A0, A, !V),
    parse_goal(B0, B, !V).
parse_goal_2("&", [A0, B0], par_conj_expr(A, B), !V) :-
    parse_goal(A0, A, !V),
    parse_goal(B0, B, !V).
parse_goal_2(";", [A0, B0], R, !V) :-
    ( A0 = term.functor(term.atom("->"), [X0, Y0], _Context) ->
        parse_some_vars_goal(X0, Vars, StateVars, X, !V),
        parse_goal(Y0, Y, !V),
        parse_goal(B0, B, !V),
        R = if_then_else_expr(Vars, StateVars, X, Y, B)
    ;
        parse_goal(A0, A, !V),
        parse_goal(B0, B, !V),
        R = disj_expr(A, B)
    ).
parse_goal_2("else", [IF, C0], if_then_else_expr(Vars, StateVars, A, B, C),
        !V) :-
    IF = term.functor(term.atom("if"),
        [term.functor(term.atom("then"), [A0, B0], _)], _),
    parse_some_vars_goal(A0, Vars, StateVars, A, !V),
    parse_goal(B0, B, !V),
    parse_goal(C0, C, !V).

parse_goal_2("not", [A0], not_expr(A), !V) :-
    parse_goal(A0, A, !V).

parse_goal_2("\\+", [A0], not_expr(A), !V) :-
    parse_goal(A0, A, !V).

parse_goal_2("all", [QVars, A0], GoalExpr, !V):-
    % Extract any state variables in the quantifier.
    parse_quantifier_vars(QVars, StateVars0, Vars0),
    list.map(term.coerce_var, StateVars0, StateVars),
    list.map(term.coerce_var, Vars0, Vars),

    parse_goal(A0, A @ (GoalExprA - ContextA), !V),

    (
        Vars = [],    StateVars = [],
        GoalExpr = GoalExprA
    ;
        Vars = [],    StateVars = [_ | _],
        GoalExpr = all_state_vars_expr(StateVars, A)
    ;
        Vars = [_ | _], StateVars = [],
        GoalExpr = all_expr(Vars, A)
    ;
        Vars = [_ | _], StateVars = [_ | _],
        GoalExpr = all_expr(Vars, all_state_vars_expr(StateVars, A) - ContextA)
    ).

    % Handle implication.
parse_goal_2("<=", [A0, B0], implies_expr(B, A), !V):-
    parse_goal(A0, A, !V),
    parse_goal(B0, B, !V).

parse_goal_2("=>", [A0, B0], implies_expr(A, B), !V):-
    parse_goal(A0, A, !V),
    parse_goal(B0, B, !V).

    % handle equivalence
parse_goal_2("<=>", [A0, B0], equivalent_expr(A, B), !V):-
    parse_goal(A0, A, !V),
    parse_goal(B0, B, !V).

parse_goal_2("some", [QVars, A0], GoalExpr, !V):-
    % Extract any state variables in the quantifier.
    parse_quantifier_vars(QVars, StateVars0, Vars0),
    list.map(term.coerce_var, StateVars0, StateVars),
    list.map(term.coerce_var, Vars0, Vars),

    parse_goal(A0, A @ (GoalExprA - ContextA), !V),
    (
        Vars = [],
        StateVars = [],
        GoalExpr = GoalExprA
    ;
        Vars = [],
        StateVars = [_ | _],
        GoalExpr = some_state_vars_expr(StateVars, A)
    ;
        Vars = [_ | _],
        StateVars = [],
        GoalExpr = some_expr(Vars, A)
    ;
        Vars = [_ | _],
        StateVars = [_ | _],
        GoalExpr = some_expr(Vars, some_state_vars_expr(StateVars, A)
            - ContextA)
    ).

parse_goal_2("promise_equivalent_solutions", [OVars, A0], GoalExpr, !V):-
    parse_goal(A0, A, !V),
    parse_vars_and_state_vars(OVars, Vars0, DotSVars0, ColonSVars0),
    list.map(term.coerce_var, Vars0, Vars),
    list.map(term.coerce_var, DotSVars0, DotSVars),
    list.map(term.coerce_var, ColonSVars0, ColonSVars),
    GoalExpr = promise_equivalent_solutions_expr(Vars,
        DotSVars, ColonSVars, A).

parse_goal_2("promise_equivalent_solution_sets", [OVars, A0], GoalExpr, !V):-
    parse_goal(A0, A, !V),
    parse_vars_and_state_vars(OVars, Vars0, DotSVars0, ColonSVars0),
    list.map(term.coerce_var, Vars0, Vars),
    list.map(term.coerce_var, DotSVars0, DotSVars),
    list.map(term.coerce_var, ColonSVars0, ColonSVars),
    GoalExpr = promise_equivalent_solution_sets_expr(Vars,
        DotSVars, ColonSVars, A).

parse_goal_2("arbitrary", [OVars, A0], GoalExpr, !V):-
    parse_goal(A0, A, !V),
    parse_vars_and_state_vars(OVars, Vars0, DotSVars0, ColonSVars0),
    list.map(term.coerce_var, Vars0, Vars),
    list.map(term.coerce_var, DotSVars0, DotSVars),
    list.map(term.coerce_var, ColonSVars0, ColonSVars),
    GoalExpr = promise_equivalent_solution_arbitrary_expr(Vars,
        DotSVars, ColonSVars, A).

parse_goal_2("promise_pure", [A0], GoalExpr, !V):-
    parse_goal(A0, A, !V),
    GoalExpr = promise_purity_expr(dont_make_implicit_promises,
        purity_pure, A).

parse_goal_2("promise_semipure", [A0], GoalExpr, !V):-
    parse_goal(A0, A, !V),
    GoalExpr = promise_purity_expr(dont_make_implicit_promises,
        purity_semipure, A).

parse_goal_2("promise_impure", [A0], GoalExpr, !V):-
    parse_goal(A0, A, !V),
    GoalExpr = promise_purity_expr(dont_make_implicit_promises,
        purity_impure, A).

parse_goal_2("promise_pure_implicit", [A0], GoalExpr, !V):-
    parse_goal(A0, A, !V),
    GoalExpr = promise_purity_expr(make_implicit_promises, purity_pure, A).

parse_goal_2("promise_semipure_implicit", [A0], GoalExpr, !V):-
    parse_goal(A0, A, !V),
    GoalExpr = promise_purity_expr(make_implicit_promises, purity_semipure, A).

parse_goal_2("promise_impure_implicit", [A0], GoalExpr, !V):-
    parse_goal(A0, A, !V),
    GoalExpr = promise_purity_expr(make_implicit_promises, purity_impure, A).

    % The following is a temporary hack to handle `is' in the parser -
    % we ought to handle it in the code generation - but then `is/2' itself
    % is a bit of a hack.
parse_goal_2("is", [A0, B0], unify_expr(A, B, purity_pure), !V) :-
    term.coerce(A0, A),
    term.coerce(B0, B).
parse_goal_2("impure", [A0], A, !V) :-
    parse_goal_with_purity(A0, purity_impure, A, !V).
parse_goal_2("semipure", [A0], A, !V) :-
    parse_goal_with_purity(A0, purity_semipure, A, !V).

:- pred parse_goal_with_purity(term::in, purity::in, goal_expr::out,
    prog_varset::in, prog_varset::out) is det.

parse_goal_with_purity(A0, Purity, A, !V) :-
    parse_goal(A0, A1, !V),
    ( A1 = call_expr(Pred, Args, purity_pure) - _ ->
        A = call_expr(Pred, Args, Purity)
    ; A1 = unify_expr(ProgTerm1, ProgTerm2, purity_pure) - _ ->
        A = unify_expr(ProgTerm1, ProgTerm2, Purity)
    ;
        % Inappropriate placement of an impurity marker, so we treat
        % it like a predicate call. typecheck.m prints out something
        % descriptive for these errors.
        purity_name(Purity, PurityString),
        term.coerce(A0, A2),
        A = call_expr(unqualified(PurityString), [A2], purity_pure)
    ).

%-----------------------------------------------------------------------------%

parse_some_vars_goal(A0, Vars, StateVars, A, !VarSet) :-
    (
        A0 = term.functor(term.atom("some"), [QVars, A1], _Context),
        parse_quantifier_vars(QVars, StateVars0, Vars0)
    ->
        list.map(term.coerce_var, StateVars0, StateVars),
        list.map(term.coerce_var, Vars0,      Vars),
        parse_goal(A1, A, !VarSet)
    ;
        Vars      = [],
        StateVars = [],
        parse_goal(A0, A, !VarSet)
    ).

%-----------------------------------------------------------------------------%

:- pred parse_lambda_arg(term::in, prog_term::out, mer_mode::out) is semidet.

parse_lambda_arg(Term, ArgTerm, Mode) :-
    Term = term.functor(term.atom("::"), [ArgTerm0, ModeTerm], _),
    term.coerce(ArgTerm0, ArgTerm),
    convert_mode(allow_constrained_inst_var, ModeTerm, Mode0),
    constrain_inst_vars_in_mode(Mode0, Mode).

%-----------------------------------------------------------------------------%
% 
% Code for parsing pred/func expressions
%

parse_pred_expression(PredTerm, lambda_normal, Args, Modes, Det) :-
    PredTerm = term.functor(term.atom("is"), [PredArgsTerm, DetTerm], _),
    DetTerm = term.functor(term.atom(DetString), [], _),
    standard_det(DetString, Det),
    PredArgsTerm = term.functor(term.atom("pred"), PredArgsList, _),
    parse_pred_expr_args(PredArgsList, Args, Modes),
    inst_var_constraints_are_consistent_in_modes(Modes).

parse_dcg_pred_expression(PredTerm, lambda_normal, Args, Modes, Det) :-
    PredTerm = term.functor(term.atom("is"), [PredArgsTerm, DetTerm], _),
    DetTerm = term.functor(term.atom(DetString), [], _),
    standard_det(DetString, Det),
    PredArgsTerm = term.functor(term.atom("pred"), PredArgsList, _),
    parse_dcg_pred_expr_args(PredArgsList, Args, Modes),
    inst_var_constraints_are_consistent_in_modes(Modes).

parse_func_expression(FuncTerm, lambda_normal, Args, Modes, Det) :-
    % Parse a func expression with specified modes and determinism.
    FuncTerm = term.functor(term.atom("is"), [EqTerm, DetTerm], _),
    EqTerm = term.functor(term.atom("="), [FuncArgsTerm, RetTerm], _),
    DetTerm = term.functor(term.atom(DetString), [], _),
    standard_det(DetString, Det),
    FuncArgsTerm = term.functor(term.atom("func"), FuncArgsList, _),

    ( parse_pred_expr_args(FuncArgsList, Args0, Modes0) ->
        parse_lambda_arg(RetTerm, RetArg, RetMode),
        list.append(Args0, [RetArg], Args),
        list.append(Modes0, [RetMode], Modes),
        inst_var_constraints_are_consistent_in_modes(Modes)
    ;
        % The argument modes default to `in',
        % the return mode defaults to `out'.
        in_mode(InMode),
        out_mode(OutMode),
        list.length(FuncArgsList, NumArgs),
        list.duplicate(NumArgs, InMode, Modes0),
        RetMode = OutMode,
        list.append(Modes0, [RetMode], Modes),
        list.append(FuncArgsList, [RetTerm], Args1),
        list.map(term.coerce, Args1, Args)
    ).

parse_func_expression(FuncTerm, lambda_normal, Args, Modes, Det) :-
    % Parse a func expression with unspecified modes and determinism.
    FuncTerm = term.functor(term.atom("="), [FuncArgsTerm, RetTerm], _),
    FuncArgsTerm = term.functor(term.atom("func"), Args0, _),

    % The argument modes default to `in', the return mode defaults to `out',
    % and the determinism defaults to `det'.
    in_mode(InMode),
    out_mode(OutMode),
    list.length(Args0, NumArgs),
    list.duplicate(NumArgs, InMode, Modes0),
    RetMode = OutMode,
    Det = detism_det,
    list.append(Modes0, [RetMode], Modes),
    inst_var_constraints_are_consistent_in_modes(Modes),
    list.append(Args0, [RetTerm], Args1),
    list.map(term.coerce, Args1, Args).

:- pred parse_pred_expr_args(list(term)::in, list(prog_term)::out,
    list(mer_mode)::out) is semidet.

parse_pred_expr_args([], [], []).
parse_pred_expr_args([Term | Terms], [Arg | Args], [Mode | Modes]) :-
    parse_lambda_arg(Term, Arg, Mode),
    parse_pred_expr_args(Terms, Args, Modes).

    % parse_dcg_pred_expr_args is like parse_pred_expr_args except
    % that the last two elements of the list are the modes of the
    % two DCG arguments.
    %
:- pred parse_dcg_pred_expr_args(list(term)::in, list(prog_term)::out,
    list(mer_mode)::out) is semidet.

parse_dcg_pred_expr_args([DCGModeTermA, DCGModeTermB], [],
        [DCGModeA, DCGModeB]) :-
    convert_mode(allow_constrained_inst_var, DCGModeTermA, DCGModeA0),
    convert_mode(allow_constrained_inst_var, DCGModeTermB, DCGModeB0),
    constrain_inst_vars_in_mode(DCGModeA0, DCGModeA),
    constrain_inst_vars_in_mode(DCGModeB0, DCGModeB).
parse_dcg_pred_expr_args([Term | Terms], [Arg | Args], [Mode | Modes]) :-
    Terms = [_, _ | _],
    parse_lambda_arg(Term, Arg, Mode),
    parse_dcg_pred_expr_args(Terms, Args, Modes).

%-----------------------------------------------------------------------------%
