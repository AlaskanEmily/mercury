%-----------------------------------------------------------------------------%
% Copyright (C) 1994-1997 The University of Melbourne.
% This file may only be copied under the terms of the GNU General
% Public License - see the file COPYING in the Mercury distribution.
%-----------------------------------------------------------------------------%

% mode_util.m - utility predicates dealing with modes and insts.

% Main author: fjh.

%-----------------------------------------------------------------------------%

:- module mode_util.

:- interface.

:- import_module hlds_module, hlds_pred, hlds_goal, hlds_data, prog_data.
:- import_module (inst), instmap.
:- import_module bool, list.

	% mode_get_insts returns the initial instantiatedness and
	% the final instantiatedness for a given mode, aborting
	% if the mode is undefined.
	%
:- pred mode_get_insts(module_info, mode, inst, inst).
:- mode mode_get_insts(in, in, out, out) is det.

	% a version of mode_get_insts which fails if the mode is undefined
:- pred mode_get_insts_semidet(module_info, mode, inst, inst).
:- mode mode_get_insts_semidet(in, in, out, out) is semidet.

	% a mode is considered input if the initial inst is bound
:- pred mode_is_input(inst_key_table, module_info, mode).
:- mode mode_is_input(in, in, in) is semidet.

	% a mode is considered fully input if the inital inst is ground
:- pred mode_is_fully_input(inst_key_table, module_info, mode).
:- mode mode_is_fully_input(in, in, in) is semidet.

	% a mode is considered output if the initial inst is free
	% and the final inst is bound
:- pred mode_is_output(inst_key_table, module_info, mode).
:- mode mode_is_output(in, in, in) is semidet.

	% a mode is considered fully output if the inital inst is free and
	% the final inst is ground
:- pred mode_is_fully_output(inst_key_table, module_info, mode).
:- mode mode_is_fully_output(in, in, in) is semidet.

	% a mode is considered unused if both initial and final insts are free
:- pred mode_is_unused(inst_key_table, module_info, mode).
:- mode mode_is_unused(in, in, in) is semidet.

	% mode_to_arg_mode converts a mode (and corresponding type) to
	% an arg_mode.  A mode is a high-level notion, the normal
	% Mercury language mode.  An `arg_mode' is a low-level notion
	% used for code generation, which indicates the argument
	% passing convention (top_in, top_out, or top_unused) that
	% corresponds to that mode.  We need to know the type, not just
	% the mode, because the argument passing convention can depend
	% on the type's representation.
	%
:- pred mode_to_arg_mode(inst_key_table, module_info, mode, type, arg_mode).
:- mode mode_to_arg_mode(in, in, in, in, out) is det.

	% Given an expanded inst and a cons_id and its arity, return the 
	% insts of the arguments of the top level functor, failing if the
	% inst could not be bound to the functor.
:- pred get_arg_insts(inst, cons_id, arity, list(inst)).
:- mode get_arg_insts(in, in, in, out) is semidet.

        % Given a list of bound_insts, get the corresponding list of cons_ids
        %
:- pred functors_to_cons_ids(list(bound_inst), list(cons_id)).
:- mode functors_to_cons_ids(in, out) is det.

:- pred mode_id_to_int(mode_id, int).
:- mode mode_id_to_int(in, out) is det.

:- pred mode_list_get_initial_insts(list(mode), module_info, list(inst)).
:- mode mode_list_get_initial_insts(in, in, out) is det.

:- pred mode_list_get_final_insts(list(mode), module_info, list(inst)).
:- mode mode_list_get_final_insts(in, in, out) is det.

:- pred mode_util__modes_to_uni_modes(list(mode), list(mode), module_info,
							list(uni_mode)).
:- mode mode_util__modes_to_uni_modes(in, in, in, out) is det.

	% inst_lists_to_mode_list(InitialInsts, FinalInsts, Modes):
	%	Given two lists of corresponding initial and final
	%	insts, return a list of modes which maps from the
	%	initial insts to the final insts.
:- pred inst_lists_to_mode_list(list(inst), list(inst), list(mode)).
:- mode inst_lists_to_mode_list(in, in, out) is det.

	% Given a user-defined or compiler-defined inst name,
	% lookup the corresponding inst in the inst table.
	%
:- pred inst_lookup(inst_key_table, module_info, inst_name, inst_key_table,
		inst).
:- mode inst_lookup(in, in, in, out, out) is det.

	% Use the instmap deltas for all the atomic sub-goals to recompute
	% the instmap deltas for all the non-atomic sub-goals of a goal.
	% Used to ensure that the instmap deltas remain valid after
	% code has been re-arranged, e.g. by followcode.
	% This also takes the module_info as input and output since it
	% may need to insert new merge_insts into the merge_inst table.
	% If the first argument is yes, the instmap_deltas for calls
	% and deconstruction unifications are also recomputed.
:- pred recompute_instmap_delta(bool, hlds_goal, hlds_goal, instmap,
		inst_key_table, inst_key_table, module_info, module_info).
:- mode recompute_instmap_delta(in, in, out, in, in, out, in, out) is det.

	% Given corresponding lists of types and modes, produce a new
	% list of modes which includes the information provided by the
	% corresponding types.
	%
:- pred propagate_types_into_mode_list(list(type), inst_key_table,
		module_info, list(mode), list(mode)).
:- mode propagate_types_into_mode_list(in, in, in, in, out) is det.

	% Given corresponding lists of types and insts and a substitution
	% for the type variables in the type, produce a new list of insts
	% which includes the information provided by the corresponding types.
	%
:- pred propagate_types_into_inst_list(list(type), tsubst, inst_key_table,
		module_info, list(inst), list(inst)).
:- mode propagate_types_into_inst_list(in, in, in, in, in, out) is det.

	% Given the mode of a predicate,
	% work out which arguments are live (might be used again
	% by the caller of that predicate) and which are dead.
:- pred get_arg_lives(list(mode), inst_key_table, module_info, list(is_live)).
:- mode get_arg_lives(in, in, in, out) is det.

	% Predicates to make error messages more readable by stripping
	% "mercury_builtin" module qualifiers from modes.

:- pred strip_builtin_qualifier_from_cons_id(cons_id, cons_id).
:- mode strip_builtin_qualifier_from_cons_id(in, out) is det.

:- pred strip_builtin_qualifiers_from_mode_list(list(mode), list(mode)).
:- mode strip_builtin_qualifiers_from_mode_list(in, out) is det.

:- pred strip_builtin_qualifiers_from_inst_list(list(inst), list(inst)).
:- mode strip_builtin_qualifiers_from_inst_list(in, out) is det.

:- pred strip_builtin_qualifiers_from_inst((inst), (inst)).
:- mode strip_builtin_qualifiers_from_inst(in, out) is det.

	% Given the switched on variable and the instmaps before the switch
	% and after a branch make sure that any information added by the
	% functor test gets added to the instmap for the case.
:- pred fixup_switch_var(var, instmap, instmap, hlds_goal, hlds_goal). 
:- mode fixup_switch_var(in, in, in, in, out) is det.

%-----------------------------------------------------------------------------%

	% Bind a variable in an instmap to a functor at the beginning
	% of a case in a switch.
	% (note: cons_id_to_const must succeed given the cons_id).

:- pred instmap_bind_var_to_functor(var, cons_id, instmap, instmap,
		inst_key_table, inst_key_table, module_info, module_info).
:- mode instmap_bind_var_to_functor(in, in, in, out, in, out, in, out) is det.

%-----------------------------------------------------------------------------%

:- pred normalise_insts(list(inst), inst_key_table, module_info, list(inst)).
:- mode normalise_insts(in, in, in, out) is det.

:- pred normalise_inst(inst, inst_key_table, module_info, inst).
:- mode normalise_inst(in, in, in, out) is det.

%-----------------------------------------------------------------------------%

:- pred apply_inst_key_sub(inst_key_sub, instmap, instmap,
		inst_key_table, inst_key_table).
:- mode apply_inst_key_sub(in, in, out, in, out) is det.

%-----------------------------------------------------------------------------%

:- pred apply_inst_key_sub_mode(inst_key_sub, mode, mode).
:- mode apply_inst_key_sub_mode(in, in, out) is det.

%-----------------------------------------------------------------------------%
%-----------------------------------------------------------------------------%

:- implementation.
:- import_module require, int, map, set, term, std_util, assoc_list.
:- import_module prog_util, type_util, mode_info.
:- import_module inst_match, inst_util.

%-----------------------------------------------------------------------------%

mode_list_get_final_insts([], _ModuleInfo, []).
mode_list_get_final_insts([Mode | Modes], ModuleInfo, [Inst | Insts]) :-
	mode_get_insts(ModuleInfo, Mode, _, Inst),
	mode_list_get_final_insts(Modes, ModuleInfo, Insts).

mode_list_get_initial_insts([], _ModuleInfo, []).
mode_list_get_initial_insts([Mode | Modes], ModuleInfo, [Inst | Insts]) :-
	mode_get_insts(ModuleInfo, Mode, Inst, _),
	mode_list_get_initial_insts(Modes, ModuleInfo, Insts).

inst_lists_to_mode_list([], [_|_], _) :-
	error("inst_lists_to_mode_list: length mis-match").
inst_lists_to_mode_list([_|_], [], _) :-
	error("inst_lists_to_mode_list: length mis-match").
inst_lists_to_mode_list([], [], []).
inst_lists_to_mode_list([Initial|Initials], [Final|Finals], [Mode|Modes]) :-
	insts_to_mode(Initial, Final, Mode),
	inst_lists_to_mode_list(Initials, Finals, Modes).

:- pred insts_to_mode(inst, inst, mode).
:- mode insts_to_mode(in, in, out) is det.

insts_to_mode(Initial, Final, Mode) :-
	%
	% Use some abbreviations.
	% This is just to make error messages and inferred modes
	% more readable.
	%
	( Initial = free, Final = ground(shared, no) ->
		Mode = user_defined_mode(
				qualified("mercury_builtin", "out"), [])
	; Initial = free, Final = ground(unique, no) ->
		Mode = user_defined_mode(qualified("mercury_builtin", "uo"), [])
	; Initial = ground(shared, no), Final = ground(shared, no) ->
		Mode = user_defined_mode(qualified("mercury_builtin", "in"), [])
	; Initial = ground(unique, no), Final = ground(clobbered, no) ->
		Mode = user_defined_mode(qualified("mercury_builtin", "di"), [])
	; Initial = ground(unique, no), Final = ground(unique, no) ->
		Mode = user_defined_mode(qualified("mercury_builtin", "ui"), [])
	; Initial = free ->
		Mode = user_defined_mode(qualified("mercury_builtin", "out"),
								[Final])
	; Final = ground(clobbered, no) ->
		Mode = user_defined_mode(qualified("mercury_builtin", "di"),
								[Initial])
	; Initial = Final ->
		Mode = user_defined_mode(qualified("mercury_builtin", "in"),
								[Initial])
	;
		Mode = (Initial -> Final)
	).

%-----------------------------------------------------------------------------%

	% A mode is considered an input mode if the top-level
	% node is input.

mode_is_input(IKT, ModuleInfo, Mode) :-
	mode_get_insts(ModuleInfo, Mode, InitialInst, _FinalInst),
	inst_is_bound(InitialInst, IKT, ModuleInfo).

	% A mode is considered fully input if its initial inst is ground.

mode_is_fully_input(IKT, ModuleInfo, Mode) :-
	mode_get_insts(ModuleInfo, Mode, InitialInst, _FinalInst),
	inst_is_ground(InitialInst, IKT, ModuleInfo).

	% A mode is considered an output mode if the top-level
	% node is output.

mode_is_output(IKT, ModuleInfo, Mode) :-
	mode_get_insts(ModuleInfo, Mode, InitialInst, FinalInst),
	inst_is_free(InitialInst, IKT, ModuleInfo),
	inst_is_bound(FinalInst, IKT, ModuleInfo).

	% A mode is considered fully output if its initial inst is free
	% and its final insts is ground.

mode_is_fully_output(IKT, ModuleInfo, Mode) :-
	mode_get_insts(ModuleInfo, Mode, InitialInst, FinalInst),
	inst_is_free(InitialInst, IKT, ModuleInfo),
	inst_is_ground(FinalInst, IKT, ModuleInfo).

	% A mode is considered a unused mode if it is equivalent
	% to free->free.

mode_is_unused(IKT, ModuleInfo, Mode) :-
	mode_get_insts(ModuleInfo, Mode, InitialInst, FinalInst),
	inst_is_free(InitialInst, IKT, ModuleInfo),
	inst_is_free(FinalInst, IKT, ModuleInfo).

%-----------------------------------------------------------------------------%

mode_to_arg_mode(IKT0, ModuleInfo, Mode, Type, ArgMode) :-
	%
	% We need to handle no_tag types (types which have
	% exactly one constructor, and whose one constructor
	% has exactly one argument) specially here,
	% since for them an inst of bound(f(free)) is not really bound
	% as far as code generation is concerned, since the f/1
	% will get optimized away.
	%
	(
		% is this a no_tag type?
		type_constructors(Type, ModuleInfo, Constructors),
		type_is_no_tag_type(Constructors, FunctorName, ArgType)
	->
		% the arg_mode will be determined by the mode and
		% type of the functor's argument,
		% so we figure out the mode and type of the argument,
		% and then recurse
		mode_get_insts(ModuleInfo, Mode, InitialInst, FinalInst),
		ConsId = cons(FunctorName, 1),
		get_single_arg_inst(InitialInst, IKT0, ModuleInfo, ConsId,
			IKT1, InitialArgInst),
		get_single_arg_inst(FinalInst, IKT1, ModuleInfo, ConsId,
			IKT, FinalArgInst),
		ModeOfArg = (InitialArgInst -> FinalArgInst),
		mode_to_arg_mode(IKT, ModuleInfo, ModeOfArg, ArgType, ArgMode)
	;
		mode_to_arg_mode_2(IKT0, ModuleInfo, Mode, ArgMode)
	).

:- pred mode_to_arg_mode_2(inst_key_table, module_info, mode, arg_mode).
:- mode mode_to_arg_mode_2(in, in, in, out) is det.
mode_to_arg_mode_2(IKT, ModuleInfo, Mode, ArgMode) :-
	mode_get_insts(ModuleInfo, Mode, InitialInst, FinalInst),
	( inst_is_bound(InitialInst, IKT, ModuleInfo) ->
		ArgMode = top_in
	; inst_is_bound(FinalInst, IKT, ModuleInfo) ->
		ArgMode = top_out
	;
		ArgMode = top_unused
	).

%-----------------------------------------------------------------------------%

	% get_single_arg_inst(Inst, ConsId, Arity, ArgInsts):
	% Given an inst `Inst', figure out what the inst of the
	% argument would be, assuming that the functor is
	% the one given by the specified ConsId, whose arity is 1.
	%
:- pred get_single_arg_inst(inst, inst_key_table, module_info, cons_id,
		inst_key_table, inst).
:- mode get_single_arg_inst(in, in, in, in, out, out) is det.

get_single_arg_inst(defined_inst(InstName), IKT0, ModuleInfo, ConsId, IKT,
			ArgInst) :-
	inst_lookup(IKT0, ModuleInfo, InstName, IKT1, Inst),
	get_single_arg_inst(Inst, IKT1, ModuleInfo, ConsId, IKT, ArgInst).
get_single_arg_inst(not_reached, IKT, _, _, IKT, not_reached).
get_single_arg_inst(ground(Uniq, _PredInst), IKT, _, _, IKT, ground(Uniq, no)).
get_single_arg_inst(bound(_Uniq, List), IKT, _, ConsId, IKT, ArgInst) :-
	( get_single_arg_inst_2(List, ConsId, ArgInst0) ->
		ArgInst = ArgInst0
	;
		% the code is unreachable
		ArgInst = not_reached
	).
get_single_arg_inst(free, IKT, _, _, IKT, free).
get_single_arg_inst(free(_Type), IKT, _, _, IKT, free).	% XXX loses type info
get_single_arg_inst(alias(Key), IKT0, ModuleInfo, ConsId, IKT, Inst) :-
	inst_key_table_lookup(IKT0, Key, Inst0),
	get_single_arg_inst(Inst0, IKT0, ModuleInfo, ConsId, IKT, Inst).
get_single_arg_inst(any(Uniq), IKT, _, _, IKT, any(Uniq)).
get_single_arg_inst(abstract_inst(_, _), _, _, _, _, _) :-
	error("get_single_arg_inst: abstract insts not supported").
get_single_arg_inst(inst_var(_), _, _, _, _, _) :-
	error("get_single_arg_inst: inst_var").

:- pred get_single_arg_inst_2(list(bound_inst), cons_id, inst).
:- mode get_single_arg_inst_2(in, in, out) is semidet.

get_single_arg_inst_2([BoundInst | BoundInsts], ConsId, ArgInst) :-
	(
		BoundInst = functor(ConsId, [ArgInst0])
	->
		ArgInst = ArgInst0
	;
		get_single_arg_inst_2(BoundInsts, ConsId, ArgInst)
	).

%-----------------------------------------------------------------------------%

	% Given two lists of modes (inst mappings) of equal length,
	% convert them into a single list of inst pair mappings.

mode_util__modes_to_uni_modes([], [], _ModuleInfo, []).
mode_util__modes_to_uni_modes([], [_|_], _, _) :-
	error("mode_util__modes_to_uni_modes: length mismatch").
mode_util__modes_to_uni_modes([_|_], [], _, _) :-
	error("mode_util__modes_to_uni_modes: length mismatch").
mode_util__modes_to_uni_modes([X|Xs], [Y|Ys], ModuleInfo, [A|As]) :-
	mode_get_insts(ModuleInfo, X, InitialX, FinalX),
	mode_get_insts(ModuleInfo, Y, InitialY, FinalY),
	A = ((InitialX - InitialY) -> (FinalX - FinalY)),
	mode_util__modes_to_uni_modes(Xs, Ys, ModuleInfo, As).

%-----------------------------------------------------------------------------%

functors_to_cons_ids([], []).
functors_to_cons_ids([Functor | Functors], [ConsId | ConsIds]) :-
	Functor = functor(ConsId, _ArgInsts),
	functors_to_cons_ids(Functors, ConsIds).

%-----------------------------------------------------------------------------%

get_arg_insts(not_reached, _ConsId, Arity, ArgInsts) :-
	list__duplicate(Arity, not_reached, ArgInsts).
get_arg_insts(ground(Uniq, _PredInst), _ConsId, Arity, ArgInsts) :-
	list__duplicate(Arity, ground(Uniq, no), ArgInsts).
get_arg_insts(bound(_Uniq, List), ConsId, Arity, ArgInsts) :-
	( get_arg_insts_2(List, ConsId, ArgInsts0) ->
		ArgInsts = ArgInsts0
	;
		% the code is unreachable
		list__duplicate(Arity, not_reached, ArgInsts)
	).
get_arg_insts(free, _ConsId, Arity, ArgInsts) :-
	list__duplicate(Arity, free, ArgInsts).
get_arg_insts(free(_Type), _ConsId, Arity, ArgInsts) :-
	list__duplicate(Arity, free, ArgInsts).
get_arg_insts(any(Uniq), _ConsId, Arity, ArgInsts) :-
	list__duplicate(Arity, any(Uniq), ArgInsts).

:- pred get_arg_insts_2(list(bound_inst), cons_id, list(inst)).
:- mode get_arg_insts_2(in, in, out) is semidet.

get_arg_insts_2([BoundInst | BoundInsts], ConsId, ArgInsts) :-
	(
		BoundInst = functor(ConsId, ArgInsts0)
	->
		ArgInsts = ArgInsts0
	;
		get_arg_insts_2(BoundInsts, ConsId, ArgInsts)
	).

%-----------------------------------------------------------------------------%

inst_lookup(IKT0, ModuleInfo, InstName, IKT, Inst) :-
	inst_lookup_2(InstName, IKT0, ModuleInfo, IKT, Inst).

:- pred inst_lookup_2(inst_name, inst_key_table, module_info, inst_key_table,
		inst).
:- mode inst_lookup_2(in, in, in, out, out) is det.

inst_lookup_2(InstName, IKT0, ModuleInfo, IKT, Inst) :-
	( InstName = unify_inst(_, _, _, _),
		module_info_insts(ModuleInfo, InstTable),
		inst_table_get_unify_insts(InstTable, UnifyInstTable),
		map__lookup(UnifyInstTable, InstName, MaybeInst),
		( MaybeInst = known(Inst0, InstIKT, _) ->
			inst_key_table_create_sub(IKT0, InstIKT, Sub, IKT),
			inst_apply_sub(Sub, Inst0, Inst)
		;
			Inst = defined_inst(InstName),
			IKT = IKT0
		)
	; InstName = merge_inst(A, B),
		module_info_insts(ModuleInfo, InstTable),
		inst_table_get_merge_insts(InstTable, MergeInstTable),
		map__lookup(MergeInstTable, A - B, MaybeInst),
		( MaybeInst = known(Inst0, InstIKT) ->
			inst_key_table_create_sub(IKT0, InstIKT, Sub, IKT),
			inst_apply_sub(Sub, Inst0, Inst)
		;
			Inst = defined_inst(InstName),
			IKT = IKT0
		)
	; InstName = ground_inst(_, _, _, _),
		module_info_insts(ModuleInfo, InstTable),
		inst_table_get_ground_insts(InstTable, GroundInstTable),
		map__lookup(GroundInstTable, InstName, MaybeInst),
		( MaybeInst = known(Inst0, InstIKT, _) ->
			inst_key_table_create_sub(IKT0, InstIKT, Sub, IKT),
			inst_apply_sub(Sub, Inst0, Inst)
		;
			Inst = defined_inst(InstName),
			IKT = IKT0
		)
	; InstName = any_inst(_, _, _, _),
		module_info_insts(ModuleInfo, InstTable),
		inst_table_get_any_insts(InstTable, AnyInstTable),
		map__lookup(AnyInstTable, InstName, MaybeInst),
		( MaybeInst = known(Inst0, InstIKT, _) ->
			inst_key_table_create_sub(IKT0, InstIKT, Sub, IKT),
			inst_apply_sub(Sub, Inst0, Inst)
		;
			Inst = defined_inst(InstName),
			IKT = IKT0
		)
	; InstName = shared_inst(SharedInstName),
		module_info_insts(ModuleInfo, InstTable),
		inst_table_get_shared_insts(InstTable, SharedInstTable),
		map__lookup(SharedInstTable, SharedInstName, MaybeInst),
		( MaybeInst = known(Inst0, InstIKT) ->
			inst_key_table_create_sub(IKT0, InstIKT, Sub, IKT),
			inst_apply_sub(Sub, Inst0, Inst)
		;
			Inst = defined_inst(InstName),
			IKT = IKT0
		)
	; InstName = mostly_uniq_inst(NondetLiveInstName),
		module_info_insts(ModuleInfo, InstTable),
		inst_table_get_mostly_uniq_insts(InstTable,
			NondetLiveInstTable),
		map__lookup(NondetLiveInstTable, NondetLiveInstName, MaybeInst),
		( MaybeInst = known(Inst0, InstIKT) ->
			inst_key_table_create_sub(IKT0, InstIKT, Sub, IKT),
			inst_apply_sub(Sub, Inst0, Inst)
		;
			Inst = defined_inst(InstName),
			IKT = IKT0
		)
	; InstName = user_inst(Name, Args),
		module_info_insts(ModuleInfo, InstTable),
		inst_table_get_user_insts(InstTable, UserInstTable),
		user_inst_table_get_inst_defns(UserInstTable, InstDefns),
		list__length(Args, Arity),
		( map__search(InstDefns, Name - Arity, InstDefn) ->
			InstDefn = hlds_inst_defn(_VarSet, Params, Inst0,
					_Cond, _C, _),
			inst_lookup_subst_args(Inst0, Params, Name, IKT0,
				Args, IKT, Inst)
		;
			Inst = abstract_inst(Name, Args),
			IKT = IKT0
		)
	; InstName = typed_ground(Uniq, Type),
		map__init(Subst),
		propagate_type_into_inst(Type, Subst, IKT, ModuleInfo,
			ground(Uniq, no), Inst),
		IKT = IKT0
	; InstName = typed_inst(Type, TypedInstName),
		inst_lookup_2(TypedInstName, IKT0, ModuleInfo, IKT, Inst0),
		map__init(Subst),
		propagate_type_into_inst(Type, Subst, IKT, ModuleInfo,
			Inst0, Inst)
	),
	!.

%-----------------------------------------------------------------------------%

:- pred inst_list_has_no_duplicate_inst_keys(set(inst_key), set(inst_key),
		list(inst), inst_key_table, module_info).
:- mode inst_list_has_no_duplicate_inst_keys(in, out, in, in, in) is semidet.

inst_list_has_no_duplicate_inst_keys(Set, Set, [], _IKT, _ModuleInfo).
inst_list_has_no_duplicate_inst_keys(Set0, Set, [Inst | Insts],
		IKT, ModuleInfo) :-
	inst_has_no_duplicate_inst_keys(Set0, Set1, Inst, IKT, ModuleInfo),
	inst_list_has_no_duplicate_inst_keys(Set1, Set, Insts, IKT, ModuleInfo).

:- pred inst_has_no_duplicate_inst_keys(set(inst_key), set(inst_key),
		inst, inst_key_table, module_info).
:- mode inst_has_no_duplicate_inst_keys(in, out, in, in, in) is semidet.

inst_has_no_duplicate_inst_keys(Set, Set, any(_), _IKT, _ModuleInfo).
inst_has_no_duplicate_inst_keys(Set0, Set, alias(Key), IKT, ModuleInfo) :-
	\+ set__member(Key, Set0),
	set__insert(Set0, Key, Set1),
	inst_key_table_lookup(IKT, Key, Inst),
	inst_has_no_duplicate_inst_keys(Set1, Set, Inst, IKT, ModuleInfo).
inst_has_no_duplicate_inst_keys(Set, Set, free(_), _IKT, _ModuleInfo).
inst_has_no_duplicate_inst_keys(Set, Set, free, _IKT, _ModuleInfo).
inst_has_no_duplicate_inst_keys(Set0, Set, bound(_, BoundInsts), IKT,
		ModuleInfo) :-
	bound_insts_list_has_no_duplicate_inst_keys(Set0, Set, BoundInsts,
		IKT, ModuleInfo).
inst_has_no_duplicate_inst_keys(Set, Set, ground(_, _), _IKT, _ModuleInfo).
inst_has_no_duplicate_inst_keys(Set, Set, not_reached, _IKT, _ModuleInfo) :-
	error("inst_has_no_duplicate_inst_keys: not_reached").
inst_has_no_duplicate_inst_keys(Set, Set, inst_var(_), _IKT, _ModuleInfo).
inst_has_no_duplicate_inst_keys(Set, Set, defined_inst(_), _IKT, _ModuleInfo).
inst_has_no_duplicate_inst_keys(Set0, Set, abstract_inst(_, Insts),
		IKT, ModuleInfo) :-
	inst_list_has_no_duplicate_inst_keys(Set0, Set, Insts, IKT, ModuleInfo).

:- pred bound_insts_list_has_no_duplicate_inst_keys(set(inst_key),
		set(inst_key), list(bound_inst), inst_key_table, module_info).
:- mode bound_insts_list_has_no_duplicate_inst_keys(in, out, in, in, in)
		is semidet.

bound_insts_list_has_no_duplicate_inst_keys(Set, Set, [], _IKT, _ModuleInfo).
bound_insts_list_has_no_duplicate_inst_keys(Set0, Set,
		[functor(_, Insts) | BoundInsts], IKT, ModuleInfo) :-
	inst_list_has_no_duplicate_inst_keys(Set0, Set1, Insts, IKT,
		ModuleInfo),
	bound_insts_list_has_no_duplicate_inst_keys(Set1, Set, BoundInsts,
		IKT, ModuleInfo).

%-----------------------------------------------------------------------------%

	% Given corresponding lists of types and modes, produce a new
	% list of modes which includes the information provided by the
	% corresponding types.

propagate_types_into_mode_list(Types, IKT, ModuleInfo, Modes0, Modes) :-
	mode_list_get_initial_insts(Modes0, ModuleInfo, Initials0),
	mode_list_get_final_insts(Modes0, ModuleInfo, Finals0),
	(
		set__init(InitDups0),
		inst_list_has_no_duplicate_inst_keys(InitDups0, _, Initials0,
			IKT, ModuleInfo),
		set__init(FinalDups0),
		inst_list_has_no_duplicate_inst_keys(FinalDups0, _, Finals0,
			IKT, ModuleInfo)
	->
		propagate_types_into_mode_list_2(Types, IKT, ModuleInfo,
			Modes0, Modes)
	;
		error("propagate_types_into_mode_list: Duplicate inst_keys NYI")
	).

:- pred propagate_types_into_mode_list_2(list(type), inst_key_table,
		module_info, list(mode), list(mode)).
:- mode propagate_types_into_mode_list_2(in, in, in, in, out) is det.

propagate_types_into_mode_list_2([], _, _, [], []).
propagate_types_into_mode_list_2([Type | Types], IKT, ModuleInfo,
		[Mode0 | Modes0], [Mode | Modes]) :-
	propagate_type_into_mode(Type, IKT, ModuleInfo, Mode0, Mode),
	propagate_types_into_mode_list_2(Types, IKT, ModuleInfo, Modes0, Modes).
propagate_types_into_mode_list_2([], _, _, [_|_], []) :-
	error("propagate_types_into_mode_list: length mismatch").
propagate_types_into_mode_list_2([_|_], _, _, [], []) :-
	error("propagate_types_into_mode_list: length mismatch").

propagate_types_into_inst_list(Types, Subst, IKT, ModuleInfo, Insts0, Insts) :-
	(
		set__init(Dups0),
		inst_list_has_no_duplicate_inst_keys(Dups0, _, Insts0,
			IKT, ModuleInfo)
	->
		propagate_types_into_inst_list_2(Types, Subst, IKT, ModuleInfo,
			Insts0, Insts)
	;
		error("propagate_types_into_inst_list: Duplicate inst_keys NYI")
	).

:- pred propagate_types_into_inst_list_2(list(type), tsubst, inst_key_table,
			module_info, list(inst), list(inst)).
:- mode propagate_types_into_inst_list_2(in, in, in, in, in, out) is det.

propagate_types_into_inst_list_2([], _, _, _, [], []).
propagate_types_into_inst_list_2([Type | Types], Subst, IKT, ModuleInfo,
		[Inst0 | Insts0], [Inst | Insts]) :-
	propagate_type_into_inst(Type, Subst, IKT, ModuleInfo, Inst0, Inst),
	propagate_types_into_inst_list_2(Types, Subst, IKT, ModuleInfo,
		Insts0, Insts).
propagate_types_into_inst_list_2([], _, _, _, [_|_], []) :-
	error("propagate_types_into_inst_list: length mismatch").
propagate_types_into_inst_list_2([_|_], _, _, _, [], []) :-
	error("propagate_types_into_inst_list: length mismatch").

	% Given a type and a mode, produce a new mode which includes
	% the information provided by the type.

:- pred propagate_type_into_mode(type, inst_key_table, module_info, mode, mode).
:- mode propagate_type_into_mode(in, in, in, in, out) is det.

propagate_type_into_mode(Type, IKT, ModuleInfo, Mode0, Mode) :-
	mode_get_insts(ModuleInfo, Mode0, InitialInst0, FinalInst0),
	map__init(Subst),
	propagate_type_into_inst_lazily(Type, Subst, IKT, ModuleInfo,
		InitialInst0, InitialInst),
	propagate_type_into_inst_lazily(Type, Subst, IKT, ModuleInfo,
			FinalInst0, FinalInst),
	Mode = (InitialInst -> FinalInst).

	% Given a type, an inst and a substitution for the type variables in
	% the type, produce a new inst which includes the information provided
	% by the type.
	%
	% There are three sorts of information added:
	%	1.  Module qualifiers.
	%	2.  The set of constructors in the type.
	%	3.  For higher-order function types
	%	    (but not higher-order predicate types),
	%	    the higher-order inst, i.e. the argument modes
	%	    and the determinism.
	%
	% Currently #2 is not yet implemented, due to unsolved
	% efficiency problems.  (See the XXX's below.)
	%
	% There are two versions, an "eager" one and a "lazy" one.
	% In general eager expansion is to be preferred, because
	% the expansion is done just once, whereas with lazy expansion
	% the work will be done N times.
	% However, for recursive insts we must use lazy expansion
	% (otherwise we would get infinite regress).
	% Also, usually many of the imported procedures will not be called,
	% so for the insts in imported mode declarations N is often zero.

:- pred propagate_type_into_inst(type, tsubst, inst_key_table, module_info,
		inst, inst).
:- mode propagate_type_into_inst(in, in, in, in, in, out) is det.

:- pred propagate_type_into_inst_lazily(type, tsubst, inst_key_table,
		module_info, inst, inst).
:- mode propagate_type_into_inst_lazily(in, in, in, in, in, out) is det.

/*********
	% XXX We ought to expand things eagerly here, using the commented
	% out code below.  However, that causes efficiency problems,
	% so for the moment it is disabled.
propagate_type_into_inst(Type, Subst, IKT, ModuleInfo, Inst0, Inst) :-
	apply_type_subst(Type0, Subst, Type),
	(
	        type_constructors(Type, ModuleInfo, Constructors)
	->
	        propagate_ctor_info(Inst0, Type, Constructors, IKT, ModuleInfo,
	               Inst) 
	;
	        Inst = Inst0
	).
*********/

propagate_type_into_inst(Type, Subst, IKT, ModuleInfo, Inst0, Inst) :-
	propagate_ctor_info_lazily(Inst0, Type, Subst, IKT, ModuleInfo, Inst).

propagate_type_into_inst_lazily(Type, Subst, IKT, ModuleInfo, Inst0, Inst) :-
	propagate_ctor_info_lazily(Inst0, Type, Subst, IKT, ModuleInfo, Inst).

%-----------------------------------------------------------------------------%

:- pred propagate_ctor_info(inst, type, list(constructor), inst_key_table,
		module_info, inst_key_table, inst).
:- mode propagate_ctor_info(in, in, in, in, in, out, out) is det.

propagate_ctor_info(any(Uniq), _Type, _, IKT, _, IKT, any(Uniq)).
			% XXX loses type info!
propagate_ctor_info(alias(Key), Type, Constructors, IKT0, ModuleInfo, IKT,
			alias(Key)) :-
	inst_key_table_lookup(IKT0, Key, Inst0),
	propagate_ctor_info(Inst0, Type, Constructors, IKT0, ModuleInfo, IKT1,
			Inst),
	inst_key_table_update(IKT1, Key, Inst, IKT).

% propagate_ctor_info(free, Type, _, IKT, _, IKT, free(Type)).
				% temporarily disabled
propagate_ctor_info(free, _Type, _, IKT, _, IKT, free).	% XXX temporary hack

propagate_ctor_info(free(_), _, _, _, _, _, _) :-
	error("propagate_ctor_info: type info already present").
propagate_ctor_info(bound(Uniq, BoundInsts0), Type, _Constructors, IKT,
		ModuleInfo, IKT, Inst) :-
	propagate_ctor_info_2(BoundInsts0, Type, IKT, ModuleInfo, BoundInsts),
	( BoundInsts = [] ->
		Inst = not_reached
	;
		% XXX do we need to sort the BoundInsts?
		Inst = bound(Uniq, BoundInsts)
	).
propagate_ctor_info(ground(Uniq, no), Type, Constructors, IKT, ModuleInfo,
		IKT, Inst) :-
	( type_is_higher_order(Type, function, ArgTypes) ->
		default_higher_order_func_inst(ArgTypes, ModuleInfo,
			HigherOrderInstInfo),
		Inst = ground(Uniq, yes(HigherOrderInstInfo))
	;
		constructors_to_bound_insts(Constructors, Uniq, ModuleInfo,
			BoundInsts0),
		list__sort_and_remove_dups(BoundInsts0, BoundInsts),
		Inst = bound(Uniq, BoundInsts)
	).
propagate_ctor_info(ground(Uniq, yes(PredInstInfo0)), Type, _Ctors, IKT,
		ModuleInfo, IKT, ground(Uniq, yes(PredInstInfo))) :-
	PredInstInfo0 = pred_inst_info(PredOrFunc,
		argument_modes(ArgIKT, ArgModes0), Det),
	PredInstInfo = pred_inst_info(PredOrFunc,
		argument_modes(ArgIKT, ArgModes), Det),
	(
		type_is_higher_order(Type, PredOrFunc, ArgTypes),
		list__same_length(ArgTypes, ArgModes0)
	->
		propagate_types_into_mode_list(ArgTypes, ArgIKT, ModuleInfo,
			ArgModes0, ArgModes)
	;
		% The inst is not a valid inst for the type,
		% so leave it alone. This can only happen if the user
		% has made a mistake.  A mode error should hopefully
		% be reported if anything tries to match with the inst.
		ArgModes = ArgModes0
	).

propagate_ctor_info(not_reached, _Type, _Constructors, IKT, _ModuleInfo,
		IKT, not_reached).
propagate_ctor_info(inst_var(V), _, _, IKT, _, IKT, inst_var(V)).
propagate_ctor_info(abstract_inst(Name, Args), _, _, IKT, _, IKT,
		abstract_inst(Name, Args)).	% XXX loses info
propagate_ctor_info(defined_inst(InstName), Type, Ctors, IKT0, ModuleInfo,
		IKT, Inst) :-
	inst_lookup(IKT0, ModuleInfo, InstName, IKT1, Inst0),
	propagate_ctor_info(Inst0, Type, Ctors, IKT1, ModuleInfo, IKT, Inst).

:- pred propagate_ctor_info_lazily(inst, type, tsubst, inst_key_table,
		module_info, inst).
:- mode propagate_ctor_info_lazily(in, in, in, in, in, out) is det.

propagate_ctor_info_lazily(alias(Key), Type, Constructors, IKT, ModuleInfo,
		Inst) :-
        inst_key_table_lookup(IKT, Key, Inst0),
        propagate_ctor_info_lazily(Inst0, Type, Constructors, IKT,
			ModuleInfo, Inst).

propagate_ctor_info_lazily(any(Uniq), _Type, _, _, _, any(Uniq)).
						% XXX loses type info!

% propagate_ctor_info_lazily(free, Type, _, _, _, free(Type)).
							% temporarily disabled
propagate_ctor_info_lazily(free, _Type, _, _, _, free).	% XXX temporary hack

propagate_ctor_info_lazily(free(_), _, _, _, _, _) :-
	error("propagate_ctor_info_lazily: type info already present").
propagate_ctor_info_lazily(bound(Uniq, BoundInsts0), Type0, Subst, 
		IKT, ModuleInfo, Inst) :-
	apply_type_subst(Type0, Subst, Type),
	propagate_ctor_info_2(BoundInsts0, Type, IKT, ModuleInfo, BoundInsts),
	( BoundInsts = [] ->
		Inst = not_reached
	;
		% XXX do we need to sort the BoundInsts?
		Inst = bound(Uniq, BoundInsts)
	).
propagate_ctor_info_lazily(ground(Uniq, no), Type0, Subst, _IKT, ModuleInfo,
		Inst) :-
	apply_type_subst(Type0, Subst, Type),
	( type_is_higher_order(Type, function, ArgTypes) ->
		default_higher_order_func_inst(ArgTypes, ModuleInfo,
			HigherOrderInstInfo),
		Inst = ground(Uniq, yes(HigherOrderInstInfo))
	;
		% XXX The information added by this is not yet used,
		% so it's disabled since it unnecessarily complicates
		% the insts.
		/*********
		Inst = defined_inst(typed_ground(Uniq, Type)) 
		*********/
		Inst = ground(Uniq, no)
	).

propagate_ctor_info_lazily(ground(Uniq, yes(PredInstInfo0)), Type0, Subst,
		_IKT, ModuleInfo, ground(Uniq, yes(PredInstInfo))) :-
	PredInstInfo0 = pred_inst_info(PredOrFunc,
		argument_modes(ArgIKT, ArgModes0), Det),
	PredInstInfo = pred_inst_info(PredOrFunc,
		argument_modes(ArgIKT, ArgModes), Det),
	apply_type_subst(Type0, Subst, Type),
	(
		type_is_higher_order(Type, PredOrFunc, ArgTypes),
		list__same_length(ArgTypes, ArgModes0)
	->
		propagate_types_into_mode_list(ArgTypes, ArgIKT, ModuleInfo,
			ArgModes0, ArgModes)
	;
		% The inst is not a valid inst for the type,
		% so leave it alone. This can only happen if the user
		% has made a mistake.  A mode error should hopefully
		% be reported if anything tries to match with the inst.
		ArgModes = ArgModes0
	).
propagate_ctor_info_lazily(not_reached, _Type, _, _IKT, _M, not_reached).
propagate_ctor_info_lazily(inst_var(Var), _, _, _, _, inst_var(Var)).
propagate_ctor_info_lazily(abstract_inst(Name, Args), _, _, _, _,
		abstract_inst(Name, Args)).	% XXX loses info
propagate_ctor_info_lazily(defined_inst(InstName0), Type0, Subst, _, _,
		defined_inst(InstName)) :-
	apply_type_subst(Type0, Subst, Type),
	( InstName0 = typed_inst(_, _) ->
		% If this happens, it means that we have already
		% lazily propagated type info into this inst.
		% We want to avoid creating insts of the form
		% typed_inst(_, typed_inst(...)), because that would be
		% unnecessary, and could cause efficiency problems
		% or perhaps even infinite loops (?).
		InstName = InstName0
	;
		InstName = typed_inst(Type, InstName0)
	).

	%
	% If the user does not explicitly specify a higher-order inst
	% for a higher-order function type, it defaults to
	% `func(in, in, ..., in) = out is det',
	% i.e. all args input, return value output, and det.
	% This applies recursively to the arguments and return
	% value too.
	%
:- pred default_higher_order_func_inst(list(type), module_info, pred_inst_info).
:- mode default_higher_order_func_inst(in, in, out) is det.

default_higher_order_func_inst(PredArgTypes, ModuleInfo, PredInstInfo) :-
	In = (ground(shared, no) -> ground(shared, no)),
	Out = (free -> ground(shared, no)),
	list__length(PredArgTypes, NumPredArgs),
	NumFuncArgs is NumPredArgs - 1,
	list__duplicate(NumFuncArgs, In, FuncArgModes),
	FuncRetMode = Out,
	list__append(FuncArgModes, [FuncRetMode], PredArgModes0),
	inst_key_table_init(IKT),
	propagate_types_into_mode_list(PredArgTypes, IKT, ModuleInfo,
		PredArgModes0, PredArgModes),
	PredInstInfo = pred_inst_info(function,
		argument_modes(IKT, PredArgModes), det).

:- pred constructors_to_bound_insts(list(constructor), uniqueness, module_info,
				list(bound_inst)).
:- mode constructors_to_bound_insts(in, in, in, out) is det.

constructors_to_bound_insts([], _, _, []).
constructors_to_bound_insts([Ctor | Ctors], Uniq, ModuleInfo,
		[BoundInst | BoundInsts]) :-
	Ctor = Name - Args,
	ctor_arg_list_to_inst_list(Args, Uniq, Insts),
	list__length(Insts, Arity),
	BoundInst = functor(cons(Name, Arity), Insts),
	constructors_to_bound_insts(Ctors, Uniq, ModuleInfo, BoundInsts).

:- pred ctor_arg_list_to_inst_list(list(constructor_arg), uniqueness,
	list(inst)).
:- mode ctor_arg_list_to_inst_list(in, in, out) is det.

ctor_arg_list_to_inst_list([], _, []).
ctor_arg_list_to_inst_list([_Name - _Type | Args], Uniq, [Inst | Insts]) :-
	% The information added by this is not yet used, so it's disabled 
	% since it unnecessarily complicates the insts.
	% Inst = defined_inst(typed_ground(Uniq, Type)), 
	Inst = ground(Uniq, no),
	ctor_arg_list_to_inst_list(Args, Uniq, Insts).

:- pred propagate_ctor_info_2(list(bound_inst), (type), inst_key_table,
		module_info, list(bound_inst)).
:- mode propagate_ctor_info_2(in, in, in, in, out) is det.

propagate_ctor_info_2(BoundInsts0, Type, IKT, ModuleInfo, BoundInsts) :-
	(
		type_to_type_id(Type, TypeId, TypeArgs),
		TypeId = qualified(TypeModule, _) - _,
		module_info_types(ModuleInfo, TypeTable),
		map__search(TypeTable, TypeId, TypeDefn),
		hlds_data__get_type_defn_tparams(TypeDefn, TypeParams0),
		hlds_data__get_type_defn_body(TypeDefn, TypeBody),
		TypeBody = du_type(Constructors, _, _, _)
	->
		term__term_list_to_var_list(TypeParams0, TypeParams),
		map__from_corresponding_lists(TypeParams, TypeArgs, ArgSubst),
		propagate_ctor_info_3(BoundInsts0, TypeModule, Constructors,
			ArgSubst, IKT, ModuleInfo, BoundInsts1),
		list__sort(BoundInsts1, BoundInsts)
	;
		% Builtin types don't need processing.
		BoundInsts = BoundInsts0
	).

:- pred propagate_ctor_info_3(list(bound_inst), string, list(constructor),
		tsubst, inst_key_table, module_info, list(bound_inst)).
:- mode propagate_ctor_info_3(in, in, in, in, in, in, out) is det.

propagate_ctor_info_3([], _, _, _, _, _, []).
propagate_ctor_info_3([BoundInst0 | BoundInsts0], TypeModule, Constructors,
		Subst, IKT, ModuleInfo, [BoundInst | BoundInsts]) :-
	BoundInst0 = functor(ConsId0, ArgInsts0),
	( ConsId0 = cons(unqualified(Name), Ar) ->
		ConsId = cons(qualified(TypeModule, Name), Ar)
	;
		ConsId = ConsId0
	),
	(
		ConsId = cons(ConsName, Arity),
		GetCons = lambda([Ctor::in] is semidet, (
				Ctor = ConsName - CtorArgs,
				list__length(CtorArgs, Arity)
			)),
		list__filter(GetCons, Constructors, [Constructor])
	->
		Constructor = _ - Args,
		GetArgTypes = lambda([CtorArg::in, ArgType::out] is det, (
				CtorArg = _ArgName - ArgType
			)),
		list__map(GetArgTypes, Args, ArgTypes),
		propagate_types_into_inst_list(ArgTypes, Subst,
			IKT, ModuleInfo, ArgInsts0, ArgInsts),
		BoundInst = functor(ConsId, ArgInsts)
	;
		% The cons_id is not a valid constructor for the type,
		% so leave it alone. This can only happen in a user defined
		% bound_inst. A mode error should be reported if anything
		% tries to match with the inst.
		BoundInst = functor(ConsId, ArgInsts0)
	),
	propagate_ctor_info_3(BoundInsts0, TypeModule,
		Constructors, Subst, IKT, ModuleInfo, BoundInsts).

:- pred apply_type_subst(type, tsubst, type).
:- mode apply_type_subst(in, in, out) is det.

apply_type_subst(Type0, Subst, Type) :-
	% optimize common case
	( map__is_empty(Subst) ->
		Type = Type0
	;
		term__apply_substitution(Type0, Subst, Type)
	).

%-----------------------------------------------------------------------------%

:- pred inst_lookup_subst_args(hlds_inst_body, list(inst_param), sym_name,
		inst_key_table, list(inst), inst_key_table, inst).
:- mode inst_lookup_subst_args(in, in, in, in, in, out, out) is det.

inst_lookup_subst_args(eqv_inst(InstIKT, Inst0), Params, _Name, IKT0,
			Args, IKT, Inst) :-
	inst_key_table_create_sub(IKT0, InstIKT, Sub, IKT),
	inst_apply_sub(Sub, Inst0, Inst1),
	inst_substitute_arg_list(Inst1, Params, Args, Inst).
inst_lookup_subst_args(abstract_inst, _Params, Name, IKT, Args, IKT,
		abstract_inst(Name, Args)).

%-----------------------------------------------------------------------------%
	% mode_get_insts returns the initial instantiatedness and
	% the final instantiatedness for a given mode.

mode_get_insts_semidet(_ModuleInfo, (InitialInst -> FinalInst), 
		InitialInst, FinalInst).
mode_get_insts_semidet(ModuleInfo, user_defined_mode(Name, Args), 
		Initial, Final) :-
	list__length(Args, Arity),
	module_info_modes(ModuleInfo, Modes),
	mode_table_get_mode_defns(Modes, ModeDefns),
	map__search(ModeDefns, Name - Arity, HLDS_Mode),
	HLDS_Mode = hlds_mode_defn(_VarSet, Params, ModeDefn, _Cond,
						_Context, _Status),
	ModeDefn = eqv_mode(Mode0),
	mode_substitute_arg_list(Mode0, Params, Args, Mode),
	mode_get_insts(ModuleInfo, Mode, Initial, Final).

mode_get_insts(ModuleInfo, Mode, Inst1, Inst2) :-
	( mode_get_insts_semidet(ModuleInfo, Mode, Inst1a, Inst2a) ->
		Inst1 = Inst1a,
		Inst2 = Inst2a
	;
		error("mode_get_insts_semidet failed")
	).


	% mode_substitute_arg_list(Mode0, Params, Args, Mode) is true
	% iff Mode is the mode that results from substituting all
	% occurrences of Params in Mode0 with the corresponding
	% value in Args.

:- pred mode_substitute_arg_list(mode, list(inst_param), list(inst), mode).
:- mode mode_substitute_arg_list(in, in, in, out) is det.

mode_substitute_arg_list(Mode0, Params, Args, Mode) :-
	( Params = [] ->
		Mode = Mode0	% optimize common case
	;
		map__from_corresponding_lists(Params, Args, Subst),
		mode_apply_substitution(Mode0, Subst, Mode)
	).

	% inst_substitute_arg_list(Inst0, Params, Args, Inst) is true
	% iff Inst is the inst that results from substituting all
	% occurrences of Params in Inst0 with the corresponding
	% value in Args.

:- pred inst_substitute_arg_list(inst, list(inst_param), list(inst), inst).
:- mode inst_substitute_arg_list(in, in, in, out) is det.

inst_substitute_arg_list(Inst0, Params, Args, Inst) :-
	( Params = [] ->
		Inst = Inst0	% optimize common case
	;
		map__from_corresponding_lists(Params, Args, Subst),
		inst_apply_substitution(Inst0, Subst, Inst)
	).

	% mode_apply_substitution(Mode0, Subst, Mode) is true iff
	% Mode is the mode that results from apply Subst to Mode0.

:- type inst_subst == map(inst_param, inst).

:- pred mode_apply_substitution(mode, inst_subst, mode).
:- mode mode_apply_substitution(in, in, out) is det.

mode_apply_substitution((I0 -> F0), Subst, (I -> F)) :-
	inst_apply_substitution(I0, Subst, I),
	inst_apply_substitution(F0, Subst, F).
mode_apply_substitution(user_defined_mode(Name, Args0), Subst,
		    user_defined_mode(Name, Args)) :-
	inst_list_apply_substitution(Args0, Subst, Args).

	% inst_list_apply_substitution(Insts0, Subst, Insts) is true
	% iff Inst is the inst that results from applying Subst to Insts0.

:- pred inst_list_apply_substitution(list(inst), inst_subst, list(inst)).
:- mode inst_list_apply_substitution(in, in, out) is det.

inst_list_apply_substitution([], _, []).
inst_list_apply_substitution([A0 | As0], Subst, [A | As]) :-
	inst_apply_substitution(A0, Subst, A),
	inst_list_apply_substitution(As0, Subst, As).

	% inst_substitute_arg(Inst0, Subst, Inst) is true
	% iff Inst is the inst that results from substituting all
	% occurrences of Param in Inst0 with Arg.

:- pred inst_apply_substitution(inst, inst_subst, inst).
:- mode inst_apply_substitution(in, in, out) is det.

inst_apply_substitution(any(Uniq), _, any(Uniq)).
inst_apply_substitution(alias(Var), _, alias(Var)) :-
	error("inst_apply_substitution: alias").
inst_apply_substitution(free, _, free).
inst_apply_substitution(free(T), _, free(T)).
inst_apply_substitution(ground(Uniq, PredStuff0), Subst,
			ground(Uniq, PredStuff)) :-
	maybe_pred_inst_apply_substitution(PredStuff0, Subst, PredStuff).
inst_apply_substitution(bound(Uniq, Alts0), Subst, bound(Uniq, Alts)) :-
	alt_list_apply_substitution(Alts0, Subst, Alts).
inst_apply_substitution(not_reached, _, not_reached).
inst_apply_substitution(inst_var(Var), Subst, Result) :-
	(
		% XXX should params be vars?
		map__search(Subst, term__variable(Var), Replacement)
	->
		Result = Replacement
	;
		Result = inst_var(Var)
	).
inst_apply_substitution(defined_inst(InstName0), Subst,
		    defined_inst(InstName)) :-
	inst_name_apply_substitution(InstName0, Subst, InstName).
inst_apply_substitution(abstract_inst(Name, Args0), Subst,
		    abstract_inst(Name, Args)) :-
	inst_list_apply_substitution(Args0, Subst, Args).

:- pred inst_name_apply_substitution(inst_name, inst_subst, inst_name).
:- mode inst_name_apply_substitution(in, in, out) is det.

inst_name_apply_substitution(user_inst(Name, Args0), Subst,
		user_inst(Name, Args)) :-
	inst_list_apply_substitution(Args0, Subst, Args).
inst_name_apply_substitution(unify_inst(Live, InstA0, InstB0, Real), Subst,
		unify_inst(Live, InstA, InstB, Real)) :-
	inst_apply_substitution(InstA0, Subst, InstA),
	inst_apply_substitution(InstB0, Subst, InstB).
inst_name_apply_substitution(merge_inst(InstA0, InstB0), Subst,
		merge_inst(InstA, InstB)) :-
	inst_apply_substitution(InstA0, Subst, InstA),
	inst_apply_substitution(InstB0, Subst, InstB).
inst_name_apply_substitution(ground_inst(Inst0, IsLive, Uniq, Real), Subst,
				ground_inst(Inst, IsLive, Uniq, Real)) :-
	inst_name_apply_substitution(Inst0, Subst, Inst).
inst_name_apply_substitution(any_inst(Inst0, IsLive, Uniq, Real), Subst,
				any_inst(Inst, IsLive, Uniq, Real)) :-
	inst_name_apply_substitution(Inst0, Subst, Inst).
inst_name_apply_substitution(shared_inst(InstName0), Subst,
				shared_inst(InstName)) :-
	inst_name_apply_substitution(InstName0, Subst, InstName).
inst_name_apply_substitution(mostly_uniq_inst(InstName0), Subst,
				mostly_uniq_inst(InstName)) :-
	inst_name_apply_substitution(InstName0, Subst, InstName).
inst_name_apply_substitution(typed_inst(T, Inst0), Subst,
		typed_inst(T, Inst)) :-
	inst_name_apply_substitution(Inst0, Subst, Inst).
inst_name_apply_substitution(typed_ground(Uniq, T), _, typed_ground(Uniq, T)).

:- pred alt_list_apply_substitution(list(bound_inst), inst_subst,
				list(bound_inst)).
:- mode alt_list_apply_substitution(in, in, out) is det.

alt_list_apply_substitution([], _, []).
alt_list_apply_substitution([Alt0|Alts0], Subst, [Alt|Alts]) :-
	Alt0 = functor(Name, Args0),
	inst_list_apply_substitution(Args0, Subst, Args),
	Alt = functor(Name, Args),
	alt_list_apply_substitution(Alts0, Subst, Alts).

:- pred maybe_pred_inst_apply_substitution(maybe(pred_inst_info), inst_subst,
					maybe(pred_inst_info)).
:- mode maybe_pred_inst_apply_substitution(in, in, out) is det.

maybe_pred_inst_apply_substitution(no, _, no).
maybe_pred_inst_apply_substitution(yes(pred_inst_info(PredOrFunc, Modes0, Det)),
			Subst, yes(pred_inst_info(PredOrFunc, Modes, Det))) :-
	% XXX This will not work properly if the pred has aliasing in
	%     its argument_modes.
	Modes0 = argument_modes(ArgIKT, ArgModes0),
	Modes  = argument_modes(ArgIKT, ArgModes),
	mode_list_apply_substitution(ArgModes0, Subst, ArgModes).

	% mode_list_apply_substitution(Modes0, Subst, Modes) is true
	% iff Mode is the mode that results from applying Subst to Modes0.

:- pred mode_list_apply_substitution(list(mode), inst_subst, list(mode)).
:- mode mode_list_apply_substitution(in, in, out) is det.

mode_list_apply_substitution([], _, []).
mode_list_apply_substitution([A0 | As0], Subst, [A | As]) :-
	mode_apply_substitution(A0, Subst, A),
	mode_list_apply_substitution(As0, Subst, As).

%-----------------------------------------------------------------------------%

	% In case we later decided to change the representation
	% of mode_ids.

mode_id_to_int(_ - X, X).

%-----------------------------------------------------------------------------%
%-----------------------------------------------------------------------------%

	% Use the instmap deltas for all the atomic sub-goals to recompute
	% the instmap deltas for all the non-atomic sub-goals of a goal.
	% Used to ensure that the instmap deltas remain valid after
	% code has been re-arranged, e.g. by followcode.
	% After common.m has been run, it may be necessary to recompute
	% instmap deltas for atomic goals, since more outputs of calls
	% and deconstructions may become non-local (XXX does this require
	% rerunning mode analysis rather than just recompute_instmap_delta?).

:- type recompute_info --->
		recompute_info(
			bool,		% Recompute atomic?
			module_info,
			inst_key_table
		).

recompute_instmap_delta(RecomputeAtomic, Goal0, Goal, Instmap, IKT0, IKT,
		M0, M) :-
	RI0 = recompute_info(RecomputeAtomic, M0, IKT0),
	recompute_instmap_delta_2(Goal0, Goal, Instmap, RI0, RI),
	RI  = recompute_info(_RecomputeAtomic, M, IKT).

:- pred recompute_instmap_delta_2(hlds_goal, hlds_goal, instmap,
		recompute_info, recompute_info).
:- mode recompute_instmap_delta_2(in, out, in, in, out) is det.

recompute_instmap_delta_2(Goal0, Goal, InstMap0) -->
	recompute_instmap_delta_2(Goal0, Goal, InstMap0, _, _).

:- pred recompute_instmap_delta_2(hlds_goal, hlds_goal, instmap,
		instmap, instmap_delta, recompute_info, recompute_info).
:- mode recompute_instmap_delta_2(in, out, in, out, out, in, out) is det.

recompute_instmap_delta_2(Goal0 - GoalInfo0, Goal - GoalInfo,
		InstMap0, InstMap, InstMapDelta, RI0, RI) :-
/************
		% YYY Is there any situation where we can get away with
		%     not recomputing atomics?
		{ RecomputeAtomic = no },
		{ goal_is_atomic(Goal0) }
	->
		{ Goal = Goal0 },
		{ GoalInfo = GoalInfo0 },
		{ goal_info_get_instmap_delta(GoalInfo, InstMapDelta) } 
	;
************/
	recompute_instmap_delta_3(Goal0, GoalInfo0, Goal, InstMap0,
			InstMapDelta0, RI0, RI),
	goal_info_get_nonlocals(GoalInfo0, NonLocals),
	instmap_delta_restrict(InstMapDelta0, NonLocals, InstMapDelta),
	goal_info_set_instmap_delta(GoalInfo0, InstMapDelta, GoalInfo),
	instmap__apply_instmap_delta(InstMap0, InstMapDelta, InstMap).

:- pred recompute_instmap_delta_3(hlds_goal_expr, hlds_goal_info,
		hlds_goal_expr, instmap, instmap_delta,
		recompute_info, recompute_info).
:- mode recompute_instmap_delta_3(in, in, out, in, out, in, out) is det.

recompute_instmap_delta_3(switch(Var, Det, Cases0, SM), GoalInfo,
		switch(Var, Det, Cases, SM), InstMap, InstMapDelta) -->
	{ goal_info_get_nonlocals(GoalInfo, NonLocals) },
	recompute_instmap_delta_cases(Var, Cases0, Cases,
		InstMap, NonLocals, InstMapDelta).

recompute_instmap_delta_3(conj(Goals0), _, conj(Goals),
		InstMap, InstMapDelta) -->
	recompute_instmap_delta_conj(Goals0, Goals,
		InstMap, InstMapDelta).

recompute_instmap_delta_3(disj(Goals0, SM), GoalInfo, disj(Goals, SM),
		InstMap, InstMapDelta) -->
	{ goal_info_get_nonlocals(GoalInfo, NonLocals) },
	recompute_instmap_delta_disj(Goals0, Goals,
		InstMap, NonLocals, InstMapDelta).

recompute_instmap_delta_3(not(Goal0), _, not(Goal), InstMap, InstMapDelta) -->
	{ instmap_delta_init_reachable(InstMapDelta) },
	recompute_instmap_delta_2(Goal0, Goal, InstMap).

recompute_instmap_delta_3(if_then_else(Vars, A0, B0, C0, SM), GoalInfo,
		if_then_else(Vars, A, B, C, SM), InstMap0, InstMapDelta,
		RI0, RI) :-
	recompute_instmap_delta_2(A0, A, InstMap0, InstMap1,
		 InstMapDelta1, RI0, RI1),
	recompute_instmap_delta_2(B0, B, InstMap1, _, InstMapDelta2, RI1, RI2),
	recompute_instmap_delta_2(C0, C, InstMap0, _, InstMapDelta3, RI2, RI3),
	instmap_delta_apply_instmap_delta(InstMapDelta1, InstMapDelta2,
		InstMapDelta4),
	goal_info_get_nonlocals(GoalInfo, NonLocals),
	RI3 = recompute_info(Atomic, M0, IKT0),
	merge_instmap_delta(InstMap0, NonLocals, InstMapDelta3,
		InstMapDelta4, InstMapDelta, IKT0, IKT, M0, M),
	RI = recompute_info(Atomic, M, IKT).

recompute_instmap_delta_3(some(Vars, Goal0), _, some(Vars, Goal),
		InstMap, InstMapDelta) -->
	recompute_instmap_delta_2(Goal0, Goal, InstMap, _, InstMapDelta).

recompute_instmap_delta_3(higher_order_call(A, Vars, B, Modes, C, D), _,
		higher_order_call(A, Vars, B, Modes, C, D),
		InstMap0, InstMapDelta, RI0, RI) :-
	RI0 = recompute_info(Atomic, ModuleInfo, IKT0),
	Modes = argument_modes(ArgIKT, ArgModes0),
	inst_key_table_create_sub(IKT0, ArgIKT, Sub, IKT),
	list__map(apply_inst_key_sub_mode(Sub), ArgModes0, ArgModes),
	RI1 = recompute_info(Atomic, ModuleInfo, IKT),
	recompute_instmap_delta_call_2(Vars, InstMap0, ArgModes, InstMap,
		RI1, RI),
	instmap__vars(InstMap, NonLocals),
	compute_instmap_delta(InstMap0, InstMap, NonLocals, InstMapDelta).

recompute_instmap_delta_3(call(PredId, ProcId, Args, D, E, F), _,
		call(PredId, ProcId, Args, D, E, F), InstMap, InstMapDelta) -->
	recompute_instmap_delta_call(PredId, ProcId,
		Args, InstMap, InstMapDelta).

recompute_instmap_delta_3(unify(Var, UnifyRhs0, UniMode0, Uni, E),
		GoalInfo, unify(Var, UnifyRhs, UniMode, Uni, E), InstMap,
		InstMapDelta) -->
	recompute_instmap_delta_unify(Var, UnifyRhs0, Uni, UniMode0,
		UniMode, GoalInfo, InstMap, InstMapDelta, UnifyRhs).

recompute_instmap_delta_3(pragma_c_code(A, B, PredId, ProcId, Args, F, G,
		H), _, pragma_c_code(A, B, PredId, ProcId, Args, F, G, H),
		InstMap, InstMapDelta) -->
	recompute_instmap_delta_call(PredId, ProcId,
		Args, InstMap, InstMapDelta).

%-----------------------------------------------------------------------------%

:- pred recompute_instmap_delta_conj(list(hlds_goal), list(hlds_goal),
		instmap, instmap_delta, recompute_info, recompute_info).
:- mode recompute_instmap_delta_conj(in, out, in, out, in, out) is det.

recompute_instmap_delta_conj([], [], _InstMap, InstMapDelta) -->
	{ instmap_delta_init_reachable(InstMapDelta) }.
recompute_instmap_delta_conj([Goal0 | Goals0], [Goal | Goals],
		InstMap0, InstMapDelta) -->
	recompute_instmap_delta_2(Goal0, Goal, InstMap0, InstMap1,
			InstMapDelta0),
	recompute_instmap_delta_conj(Goals0, Goals, InstMap1, InstMapDelta1),
	{ instmap_delta_apply_instmap_delta(InstMapDelta0, InstMapDelta1,
			InstMapDelta) }.

%-----------------------------------------------------------------------------%

:- pred recompute_instmap_delta_disj(list(hlds_goal), list(hlds_goal), instmap,
		set(var), instmap_delta, recompute_info, recompute_info).
:- mode recompute_instmap_delta_disj(in, out, in, in, out, in, out) is det.

recompute_instmap_delta_disj([], [], _, _, InstMapDelta) -->
	{ instmap_delta_init_unreachable(InstMapDelta) }.
recompute_instmap_delta_disj([Goal0], [Goal],
		InstMap, _, InstMapDelta) -->
	recompute_instmap_delta_2(Goal0, Goal, InstMap, _, InstMapDelta).
recompute_instmap_delta_disj([Goal0 | Goals0], [Goal | Goals],
		InstMap, NonLocals, InstMapDelta, RI0, RI) :-
	Goals0 = [_|_],
	recompute_instmap_delta_2(Goal0, Goal, InstMap, _, InstMapDelta0,
			RI0, RI1),
	recompute_instmap_delta_disj(Goals0, Goals,
			InstMap, NonLocals, InstMapDelta1, RI1, RI2),
	RI2 = recompute_info(Atomic, M0, IKT0),
	merge_instmap_delta(InstMap, NonLocals, InstMapDelta0,
		InstMapDelta1, InstMapDelta, IKT0, IKT, M0, M),
	RI  = recompute_info(Atomic, M, IKT).

%-----------------------------------------------------------------------------%

:- pred recompute_instmap_delta_cases(var, list(case), list(case), instmap,
		set(var), instmap_delta, recompute_info, recompute_info).
:- mode recompute_instmap_delta_cases(in, in, out, in, in, out, in, out) is det.

recompute_instmap_delta_cases(_, [], [], _, _, InstMapDelta, RI, RI) :-
	instmap_delta_init_unreachable(InstMapDelta).
recompute_instmap_delta_cases(Var, [Case0 | Cases0], [Case | Cases],
		InstMap0, NonLocals, InstMapDelta, RI0, RI) :-
	Case0 = case(Functor, Goal0),
	RI0 = recompute_info(Atomic0, M0, IKT0),
	instmap_bind_var_to_functor(Var, Functor, InstMap0, InstMap1,
		IKT0, IKT1, M0, M1),
	RI3 = recompute_info(Atomic0, M1, IKT1),
	recompute_instmap_delta_2(Goal0, Goal, InstMap1, InstMap, _, RI3, RI4),
	compute_instmap_delta(InstMap0, InstMap, NonLocals, InstMapDelta1),
	Case = case(Functor, Goal),
	recompute_instmap_delta_cases(Var, Cases0, Cases,
		InstMap0, NonLocals, InstMapDelta2, RI4, RI5),
	RI5 = recompute_info(Atomic5, M5, IKT5),
	merge_instmap_delta(InstMap0, NonLocals, InstMapDelta1,
		InstMapDelta2, InstMapDelta, IKT5, IKT, M5, M),
	RI  = recompute_info(Atomic5, M, IKT).

%-----------------------------------------------------------------------------%

:- pred recompute_instmap_delta_call(pred_id, proc_id, list(var), instmap,
		instmap_delta, recompute_info, recompute_info).
:- mode recompute_instmap_delta_call(in, in, in, in, out, in, out) is det.

recompute_instmap_delta_call(PredId, ProcId, Args, InstMap0,
		InstMapDelta, RI0, RI) :-
	RI0 = recompute_info(Atomic, ModuleInfo0, IKT0),
	module_info_pred_proc_info(ModuleInfo0, PredId, ProcId, _, ProcInfo),
	proc_info_interface_determinism(ProcInfo, Detism),
	( determinism_components(Detism, _, at_most_zero) ->
		instmap_delta_init_unreachable(InstMapDelta),
		RI = RI0
	;
		proc_info_argmodes(ProcInfo, argument_modes(ArgIKT, ArgModes0)),
		inst_key_table_create_sub(IKT0, ArgIKT, Sub, IKT),
		list__map(apply_inst_key_sub_mode(Sub), ArgModes0, ArgModes),
		RI1 = recompute_info(Atomic, ModuleInfo0, IKT),
		recompute_instmap_delta_call_2(Args, InstMap0,
			ArgModes, InstMap, RI1, RI),
		instmap__vars(InstMap, NonLocals),
		compute_instmap_delta(InstMap0, InstMap, NonLocals,
			InstMapDelta)
	).

:- pred recompute_instmap_delta_call_2(list(var), instmap, list(mode),
		instmap, recompute_info, recompute_info).
:- mode recompute_instmap_delta_call_2(in, in, in, out, in, out) is det.

recompute_instmap_delta_call_2([], InstMap, [], InstMap,
		ModuleInfo, ModuleInfo).
recompute_instmap_delta_call_2([_|_], _, [], _, _, _) :-
	error("recompute_instmap_delta_call_2").
recompute_instmap_delta_call_2([], _, [_|_], _, _, _) :-
	error("recompute_instmap_delta_call_2").
recompute_instmap_delta_call_2([Arg | Args], InstMap0, [Mode | Modes],
		InstMap, RI0, RI) :-
	% This is similar to modecheck_set_var_inst.
	RI0 = recompute_info(Atomic, ModuleInfo0, IKT0),
	( instmap__is_reachable(InstMap0) ->
		instmap__lookup_var(InstMap0, Arg, ArgInst0),
		mode_get_insts(ModuleInfo0, Mode, _, FinalInst),
		(
			map__init(Sub0),
			abstractly_unify_inst(dead, ArgInst0, FinalInst,
				fake_unify, IKT0, ModuleInfo0, Sub0, UnifyInst,
				_, IKT1, ModuleInfo1, Sub)
		->
			ModuleInfo = ModuleInfo1,
			instmap__set(InstMap0, Arg, UnifyInst, InstMap1),
			apply_inst_key_sub(Sub, InstMap1, InstMap2,
				IKT1, IKT),
			RI1 = recompute_info(Atomic, ModuleInfo, IKT),
			recompute_instmap_delta_call_2(Args, InstMap2,
				Modes, InstMap, RI1, RI)
		;
			error("recompute_instmap_delta_call_2: unify_inst failed")
		)
	;
		instmap__init_unreachable(InstMap),
		RI = RI0
	).

:- pred recompute_instmap_delta_unify(var, unify_rhs, unification,
	unify_mode, unify_mode, hlds_goal_info, instmap, instmap_delta,
	unify_rhs, recompute_info, recompute_info).
:- mode recompute_instmap_delta_unify(in, in, in, in, out,
	in, in, out, out, in, out) is det.

recompute_instmap_delta_unify(Var, UnifyRhs0, _Unification,
		UniMode0, UniMode, GoalInfo, InstMap0, InstMapDelta,
		UnifyRhs, RI0, RI) :-

	( UnifyRhs0 = functor(ConsId, Vars),

		% var-functor unification

		% Make aliases for the arguments of the functor.  Note
		% that we do not need to make one for the var on the
		% LHS because:
		%	- If the unification is a construction, the
		%	  LHS variable was either free or aliased to
		%	  free.  In the latter case, we do not need
		%	  to make a new alias since one already exists,
		%	  in the former case the variable is not aliased
		%	  to anything and therefore
		%	  abstractly_unify_inst_functor will not demand
		%	  that the variable have an alias.
		%	- If the unification is a deconstruction, then
		%	  whatever defined the variable will have given
		%	  it an alias.

		RI0 = recompute_info(Atomic, ModuleInfo0, IKT0),
		make_var_aliases(Vars, InstMap0, InstMap1, IKT0, IKT1),
		instmap__lookup_var(InstMap1, Var, InitialInst),

		list__length(Vars, Arity),
                list__duplicate(Arity, live, ArgLives),
		list__map(instmap__lookup_var(InstMap1), Vars, ArgInsts),
        	(
                	map__init(Sub0),
                	abstractly_unify_inst_functor(dead, InitialInst, ConsId,
                        	ArgInsts, ArgLives, real_unify, IKT1,
				ModuleInfo0, Sub0,
				UnifyInst0, _, IKT2, ModuleInfo2, Sub1)
        	->
			ModuleInfo = ModuleInfo2,
			apply_inst_key_sub(Sub1, InstMap1, InstMap2,
				IKT2, IKT),
			UnifyInst = UnifyInst0
        	;
                	error("recompute_instmap_delta_unify: var-functor unify failed")
        	),
		instmap__set(InstMap2, Var, UnifyInst, InstMap),
		UniMode = UniMode0,
		UnifyRhs = UnifyRhs0,
		goal_info_get_nonlocals(GoalInfo, NonLocals),
		compute_instmap_delta(InstMap0, InstMap, NonLocals,
			InstMapDelta),
		RI = recompute_info(Atomic, ModuleInfo, IKT)
	; UnifyRhs0 = lambda_goal(PredOrFunc, Vars, LambdaModes, LambdaDet,
			_, Goal0),

		% var-lambda unification

		% First, compute the instmap_delta of the goal.

		% Set the head modes of the lambda.
		RI0 = recompute_info(Atomic, ModuleInfo0, IKT0),
		instmap__pre_lambda_update(ModuleInfo0, Vars, LambdaModes,
			IMDelta, IKT0, IKT1, InstMap0, InstMap1),
		RI1 = recompute_info(Atomic, ModuleInfo0, IKT1),

		% Analyse the lambda goal
		recompute_instmap_delta_2(Goal0, Goal, InstMap1,
			_, _, RI1, RI2),

		instmap__lookup_var(InstMap0, Var, InstOfX),

		LambdaPredInfo = pred_inst_info(PredOrFunc, LambdaModes,
			LambdaDet),

		RI2 = recompute_info(_, ModuleInfo2, IKT2),
		InstOfY = ground(unique, yes(LambdaPredInfo)),

		(
			map__init(Sub0),
			abstractly_unify_inst(dead, InstOfX, InstOfY,
				real_unify, IKT2, ModuleInfo2, Sub0, UnifyInst0,
				_Det, IKT3, ModuleInfo3, Sub)
		->
			apply_inst_key_sub(Sub, InstMap1, InstMap2, IKT3, IKT),
			UnifyInst0 = UnifyInst,
			ModuleInfo = ModuleInfo3
		;
			error("recompute_instmap_delta_unify: var-lambda unify failed")
		),
		instmap__set(InstMap2, Var, UnifyInst, InstMapUnify),
		goal_info_get_nonlocals(GoalInfo, NonLocals),
		compute_instmap_delta(InstMap0, InstMapUnify, NonLocals,
			InstMapDelta),

		UniMode = UniMode0,
		UnifyRhs = lambda_goal(PredOrFunc, Vars, LambdaModes,
				LambdaDet, IMDelta, Goal),
		RI = recompute_info(Atomic, ModuleInfo, IKT)

	; UnifyRhs0 = var(VarY),

		% var-var unification

		% Make a new alias for one of the vars (either one
		% will do).  abstractly_unify_inst will not demand
		% both vars to have aliases since it will create a
		% new alias for the unified inst if only one does.
		% We will then set both VarX and VarY to the new
		% alias.

		RI0 = recompute_info(Atomic, ModuleInfo0, IKT0),
		make_var_alias(Var, InstMap0, InstMap1, IKT0, IKT1),
		VarX = Var,	% Keep the names orthogonal
		instmap__lookup_var(InstMap1, VarX, InitialInstX),
		instmap__lookup_var(InstMap1, VarY, InitialInstY),
		(
			map__init(Sub0),
			abstractly_unify_inst(dead, InitialInstX, InitialInstY,
				real_unify, IKT1, ModuleInfo0, Sub0, UnifyInst0,
				_Det, IKT2, ModuleInfo, Sub1)
		->
			apply_inst_key_sub(Sub1, InstMap1, InstMap2,
				IKT2, IKT),
			UnifyInst = UnifyInst0,
			RI = recompute_info(Atomic, ModuleInfo, IKT)
		;
			error("recompute_instmap_delta_unify: var-var unify failed")
		),
		instmap__set(InstMap2, VarX, UnifyInst, InstMap3),
		instmap__set(InstMap3, VarY, UnifyInst, InstMap),
		UniMode = UniMode0,
		UnifyRhs = UnifyRhs0,
		goal_info_get_nonlocals(GoalInfo, NonLocals),
		compute_instmap_delta(InstMap0, InstMap, NonLocals,
			InstMapDelta)
	).

%-----------------------------------------------------------------------------%

:- pred make_var_alias(var, instmap, instmap, inst_key_table, inst_key_table).
:- mode make_var_alias(in, in, out, in, out) is det.

make_var_alias(Var, InstMap0, InstMap, IKT0, IKT) :-
	instmap__lookup_var(InstMap0, Var, Inst),
	( Inst = alias(_) ->
		InstMap0 = InstMap,
		IKT0 = IKT
	;
		inst_key_table_add(IKT0, Inst, InstKey, IKT),
		instmap__set(InstMap0, Var, alias(InstKey), InstMap)
	).

:- pred make_var_aliases(list(var), instmap, instmap,
		inst_key_table, inst_key_table).
:- mode make_var_aliases(in, in, out, in, out) is det.

make_var_aliases([], InstMap, InstMap) --> [].
make_var_aliases([V | Vs], InstMap0, InstMap) -->
	make_var_alias(V, InstMap0, InstMap1),
	make_var_aliases(Vs, InstMap1, InstMap).

%-----------------------------------------------------------------------------%

	% Arguments with final inst `clobbered' are dead, any
	% others are assumed to be live.

get_arg_lives([], _, _, []).
get_arg_lives([Mode|Modes], IKT, ModuleInfo, [IsLive|IsLives]) :-
	mode_get_insts(ModuleInfo, Mode, _InitialInst, FinalInst),
	( inst_is_clobbered(FinalInst, IKT, ModuleInfo) ->
		IsLive = dead
	;
		IsLive = live
	),
	get_arg_lives(Modes, IKT, ModuleInfo, IsLives).

%-----------------------------------------------------------------------------%

	% 
	% Predicates to make error messages more readable by stripping
	% "mercury_builtin" module qualifiers from modes and insts.
	% The interesting part is strip_builtin_qualifier_from_sym_name;
	% the rest is basically just recursive traversals.
	%

strip_builtin_qualifiers_from_mode_list(Modes0, Modes) :-
	list__map(strip_builtin_qualifiers_from_mode, Modes0, Modes).

:- pred strip_builtin_qualifiers_from_mode((mode)::in, (mode)::out) is det.

strip_builtin_qualifiers_from_mode((Initial0 -> Final0), (Initial -> Final)) :-
	strip_builtin_qualifiers_from_inst(Initial0, Initial),
	strip_builtin_qualifiers_from_inst(Final0, Final).

strip_builtin_qualifiers_from_mode(user_defined_mode(SymName0, Insts0),
				user_defined_mode(SymName, Insts)) :-
	strip_builtin_qualifiers_from_inst_list(Insts0, Insts),
	strip_builtin_qualifier_from_sym_name(SymName0, SymName).

strip_builtin_qualifier_from_cons_id(ConsId0, ConsId) :-
	( ConsId0 = cons(Name0, Arity) ->
		strip_builtin_qualifier_from_sym_name(Name0, Name),
		ConsId = cons(Name, Arity)
	;
		ConsId = ConsId0
	).

:- pred strip_builtin_qualifier_from_sym_name(sym_name::in,
						sym_name::out) is det.

strip_builtin_qualifier_from_sym_name(SymName0, SymName) :-
	( SymName0 = qualified("mercury_builtin", Name) ->
		SymName = unqualified(Name)
	;
		SymName = SymName0
	).

strip_builtin_qualifiers_from_inst_list(Insts0, Insts) :-
	list__map(strip_builtin_qualifiers_from_inst, Insts0, Insts).

strip_builtin_qualifiers_from_inst(inst_var(V), inst_var(V)).
strip_builtin_qualifiers_from_inst(alias(V), alias(V)).
strip_builtin_qualifiers_from_inst(not_reached, not_reached).
strip_builtin_qualifiers_from_inst(free, free).
strip_builtin_qualifiers_from_inst(free(Type), free(Type)).
strip_builtin_qualifiers_from_inst(any(Uniq), any(Uniq)).
strip_builtin_qualifiers_from_inst(ground(Uniq, Pred0), ground(Uniq, Pred)) :-
	strip_builtin_qualifiers_from_pred_inst(Pred0, Pred).
strip_builtin_qualifiers_from_inst(bound(Uniq, BoundInsts0),
					bound(Uniq, BoundInsts)) :-
	strip_builtin_qualifiers_from_bound_inst_list(BoundInsts0, BoundInsts).
strip_builtin_qualifiers_from_inst(defined_inst(Name0), Inst) :-
	strip_builtin_qualifiers_from_inst_name(Name0,
		defined_inst(Name0), Inst).
strip_builtin_qualifiers_from_inst(abstract_inst(Name0, Args0),
				abstract_inst(Name, Args)) :-
	strip_builtin_qualifier_from_sym_name(Name0, Name),
	strip_builtin_qualifiers_from_inst_list(Args0, Args).

:- pred strip_builtin_qualifiers_from_bound_inst_list(list(bound_inst)::in,
					list(bound_inst)::out) is det.
strip_builtin_qualifiers_from_bound_inst_list(Insts0, Insts) :-
	list__map(strip_builtin_qualifiers_from_bound_inst, Insts0, Insts).

:- pred strip_builtin_qualifiers_from_bound_inst(bound_inst::in,
					bound_inst::out) is det.
strip_builtin_qualifiers_from_bound_inst(BoundInst0, BoundInst) :-
	BoundInst0 = functor(ConsId0, Insts0),
	strip_builtin_qualifier_from_cons_id(ConsId0, ConsId),
	BoundInst = functor(ConsId, Insts),
	list__map(strip_builtin_qualifiers_from_inst, Insts0, Insts).

:- pred strip_builtin_qualifiers_from_inst_name(inst_name::in, (inst)::in,
		(inst)::out) is det.

strip_builtin_qualifiers_from_inst_name(InstName0, Inst0, Inst) :-
	( InstName0 = user_inst(SymName0, Insts0) ->
		strip_builtin_qualifier_from_sym_name(SymName0, SymName),
		strip_builtin_qualifiers_from_inst_list(Insts0, Insts),
		Inst = defined_inst(user_inst(SymName, Insts))
	; InstName0 = typed_inst(_, InstName1) ->
		% Don't output the $typed_inst in error messages.
		strip_builtin_qualifiers_from_inst_name(InstName1, Inst0, Inst)
	; InstName0 = typed_ground(Uniq, _Type) ->
		% Don't output the $typed_ground in error messages.
		Inst = ground(Uniq, no)
	;
		% for the compiler-generated insts, don't bother.
		Inst = Inst0
	).

:- pred strip_builtin_qualifiers_from_pred_inst(maybe(pred_inst_info)::in,
					maybe(pred_inst_info)::out) is det.

strip_builtin_qualifiers_from_pred_inst(no, no).
strip_builtin_qualifiers_from_pred_inst(yes(Pred0), yes(Pred)) :-
	Pred0 = pred_inst_info(Uniq, Modes0, Det),
	Pred = pred_inst_info(Uniq, Modes, Det),
	Modes0 = argument_modes(ArgIKT, ArgModes0),
	Modes = argument_modes(ArgIKT, ArgModes),
	strip_builtin_qualifiers_from_mode_list(ArgModes0, ArgModes).

%-----------------------------------------------------------------------------%
%-----------------------------------------------------------------------------%

normalise_insts([], _, _, []).
normalise_insts([Inst0|Insts0], IKT, ModuleInfo, [Inst|Insts]) :-
	normalise_inst(Inst0, IKT, ModuleInfo, Inst),
	normalise_insts(Insts0, IKT, ModuleInfo, Insts).

	% This is a bit of a hack.
	% The aim is to avoid non-termination due to the creation
	% of ever-expanding insts.
	% XXX should also normalise partially instantiated insts.

normalise_inst(Inst0, IKT0, ModuleInfo, NormalisedInst) :-
	inst_expand(IKT0, ModuleInfo, Inst0, IKT, Inst),
	( Inst = bound(_, _) ->
		(
			inst_is_ground(Inst, IKT, ModuleInfo),
			inst_is_unique(Inst, IKT, ModuleInfo)
		->
			NormalisedInst = ground(unique, no)
		;
			inst_is_ground(Inst, IKT, ModuleInfo),
			inst_is_mostly_unique(Inst, IKT, ModuleInfo)
		->
			NormalisedInst = ground(mostly_unique, no)
		;
			inst_is_ground(Inst, IKT, ModuleInfo),
			\+ inst_is_clobbered(Inst, IKT, ModuleInfo)
		->
			NormalisedInst = ground(shared, no)
		;
			% XXX need to limit the potential size of insts
			% here in order to avoid infinite loops in
			% mode inference
			NormalisedInst = Inst
		)
	;
		NormalisedInst = Inst
	).

%-----------------------------------------------------------------------------%

fixup_switch_var(Var, InstMap0, InstMap, Goal0, Goal) :-
	Goal0 = GoalExpr - GoalInfo0,
	goal_info_get_instmap_delta(GoalInfo0, InstMapDelta0),
	instmap__lookup_var(InstMap0, Var, Inst0),
	instmap__lookup_var(InstMap, Var, Inst),
	( Inst = Inst0 ->
		GoalInfo = GoalInfo0
	;
		instmap_delta_set(InstMapDelta0, Var, Inst, InstMapDelta),
		goal_info_set_instmap_delta(GoalInfo0, InstMapDelta, GoalInfo)
	),
	Goal = GoalExpr - GoalInfo.

%-----------------------------------------------------------------------------%
%-----------------------------------------------------------------------------%

instmap_bind_var_to_functor(Var, ConsId, InstMap0, InstMap,
		IKT0, IKT, ModuleInfo0, ModuleInfo) :-
	instmap__lookup_var(InstMap0, Var, Inst0),
	bind_inst_to_functor(Inst0, ConsId, Inst, Sub, IKT0, ModuleInfo0,
			IKT1, ModuleInfo),
	instmap__set(InstMap0, Var, Inst, InstMap1),
	apply_inst_key_sub(Sub, InstMap1, InstMap, IKT1, IKT).

:- pred bind_inst_to_functor((inst), cons_id, (inst), inst_key_sub,
		inst_key_table, module_info, inst_key_table, module_info).
:- mode bind_inst_to_functor(in, in, out, out, in, in, out, out) is det.

bind_inst_to_functor(Inst0, ConsId, Inst, Sub, IKT0, ModuleInfo0,
		IKT, ModuleInfo) :-
	( ConsId = cons(_, Arity) ->
		list__duplicate(Arity, dead, ArgLives),
		list__duplicate(Arity, free, ArgInsts)
	;
		ArgLives = [],
		ArgInsts = []
	),
	(
		map__init(Sub0),
		abstractly_unify_inst_functor(dead, Inst0, ConsId,
			ArgInsts, ArgLives, real_unify, IKT0, ModuleInfo0,
			Sub0, Inst1, _, IKT1, ModuleInfo1, Sub1)
	->
		ModuleInfo = ModuleInfo1,
		IKT = IKT1,
		Inst = Inst1,
		Sub = Sub1
	;
		ModuleInfo = ModuleInfo0,
		IKT = IKT0,
		Inst = not_reached,
		map__init(Sub)
	).

%-----------------------------------------------------------------------------%
%-----------------------------------------------------------------------------%

apply_inst_key_sub(Sub, InstMap0, InstMap, IKT0, IKT) :-
	set__init(DeadKeys),
	apply_inst_key_sub_2(Sub, DeadKeys, InstMap0, InstMap, IKT0, IKT).

:- pred apply_inst_key_sub_2(inst_key_sub, set(inst_key), instmap, instmap,
		inst_key_table, inst_key_table).
:- mode apply_inst_key_sub_2(in, in, in, out, in, out) is det.

apply_inst_key_sub_2(Sub, DeadKeys0, InstMap0, InstMap, IKT0, IKT) :-
	( map__is_empty(Sub) ->
		InstMap0 = InstMap,
		IKT0 = IKT
	;
		map__keys(Sub, SubDomain),
		set__init(KeysToChange0),
		list__foldl(lambda([K :: in, Ks0 :: in, Ks :: out] is det,
				(inst_key_table_dependent_keys(IKT0, K, Ks1),
				set__insert_list(Ks0, Ks1, Ks))
			), SubDomain, KeysToChange0, KeysToChange1),
		set__difference(KeysToChange1, DeadKeys0, KeysToChange),
		set__to_sorted_list(KeysToChange, KeysToChangeList),

		map__init(NewSub0),

		apply_inst_key_sub_inst_key_table(KeysToChangeList, Sub,
			DeadKeys0, DeadKeys, NewSub0, NewSub, IKT0, IKT1),

		set__init(VarsToChange0),
		list__foldl(lambda([V :: in, Vs0 :: in, Vs :: out] is det,
				(instmap__lookup_dependent_vars(InstMap0, V,
					Vs1),
				set__insert_list(Vs0, Vs1, Vs))
			), SubDomain, VarsToChange0, VarsToChange),
		set__to_sorted_list(VarsToChange, VarsToChangeList),

		apply_inst_key_sub_instmap(VarsToChangeList, Sub,
			InstMap0, InstMap1),

		apply_inst_key_sub_2(NewSub, DeadKeys, InstMap1, InstMap,
			IKT1, IKT)
	).

:- pred apply_inst_key_sub_instmap(list(var), inst_key_sub, instmap, instmap).
:- mode apply_inst_key_sub_instmap(in, in, in, out) is det.

apply_inst_key_sub_instmap([], _Sub, InstMap, InstMap).
apply_inst_key_sub_instmap([V | Vs], Sub, 
		InstMap0, InstMap) :-
	instmap__lookup_var(InstMap0, V, Inst0),
	inst_apply_sub(Sub, Inst0, Inst),
	instmap__set(InstMap0, V, Inst, InstMap1),
	apply_inst_key_sub_instmap(Vs, Sub, InstMap1, InstMap).

:- pred apply_inst_key_sub_inst_key_table(list(inst_key),
		inst_key_sub, set(inst_key), set(inst_key),
		inst_key_sub, inst_key_sub, inst_key_table, inst_key_table).
:- mode apply_inst_key_sub_inst_key_table(in, in, in, out, in, out, in, out)
		is det.

apply_inst_key_sub_inst_key_table([], _Sub, DeadKeys, DeadKeys, NewSub, NewSub,
		IKT, IKT).
apply_inst_key_sub_inst_key_table([Key0 | Keys], Sub, DeadKeys0, DeadKeys,
		NewSub0, NewSub, IKT0, IKT) :-
	inst_key_table_lookup(IKT0, Key0, Inst0),
	inst_apply_sub(Sub, Inst0, Inst),
	( Inst0 = Inst ->
		IKT0 = IKT1,
		NewSub1 = NewSub0,
		DeadKeys1 = DeadKeys0
	;
		inst_key_table_add(IKT0, Inst, Key, IKT1),
		set__insert(DeadKeys0, Key0, DeadKeys1),
		map__det_insert(NewSub0, Key0, Key, NewSub1)
	),
	apply_inst_key_sub_inst_key_table(Keys, Sub, DeadKeys1, DeadKeys,
		NewSub1, NewSub, IKT1, IKT).

%-----------------------------------------------------------------------------%

apply_inst_key_sub_mode(Sub, (I0 -> F0), (I -> F)) :-
	inst_apply_sub(Sub, I0, I),
	inst_apply_sub(Sub, F0, F).
apply_inst_key_sub_mode(Sub, user_defined_mode(SymName, Insts0),
		user_defined_mode(SymName, Insts)) :-
	list__map(inst_apply_sub(Sub), Insts0, Insts).

%-----------------------------------------------------------------------------%
%-----------------------------------------------------------------------------%
