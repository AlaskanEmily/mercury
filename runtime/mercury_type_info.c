/*
INIT mercury_sys_init_type_info
ENDINIT
*/
/*
** Copyright (C) 1995-1999 The University of Melbourne.
** This file may only be copied under the terms of the GNU Library General
** Public License - see the file COPYING.LIB in the Mercury distribution.
*/

/*
** type_info.c -
**	Definitions for type_infos, type_layouts, and
**	type_functors tables needed by the Mercury runtime system..
*/

#include "mercury_imp.h"
#include "mercury_type_info.h"

/*---------------------------------------------------------------------------*/

	/* type_ctor_layout for `pred' */
	/* (this is used for all higher-order types) */

const struct mercury_data___type_ctor_layout_pred_0_struct {
	TYPE_LAYOUT_FIELDS
} mercury_data___type_ctor_layout_pred_0 = {
	make_typelayout_for_all_tags(TYPE_CTOR_LAYOUT_CONST_TAG, 
		mkbody(MR_TYPE_CTOR_LAYOUT_PREDICATE_VALUE))
};

	/* type_ctor_functors for `pred' */
	/* (this is used for all higher-order types) */

const struct mercury_data___type_ctor_functors_pred_0_struct {
	Integer f1;
} mercury_data___type_ctor_functors_pred_0 = {
	MR_TYPE_CTOR_FUNCTORS_SPECIAL
};


	/* 
	** type_ctor_info for `func' 
	** (this is used for all higher-order func types) 
	**
	** Note: we use the special predicates, functors and layout for
	** `pred'.
	*/

Declare_entry(mercury__builtin_unify_pred_2_0);
Declare_entry(mercury__builtin_index_pred_2_0);
Declare_entry(mercury__builtin_compare_pred_3_0);
MR_STATIC_CODE_CONST struct mercury_data___type_ctor_info_func_0_struct {
	Integer f1;
	Code *f2;
	Code *f3;
	Code *f4;
#ifdef USE_TYPE_LAYOUT
	const Word *f5;
	const Word *f6;
	const Word *f7;
	const Word *f8;
	const Word *f9;
#endif
} mercury_data___type_ctor_info_func_0 = {
	((Integer) 0),
	MR_MAYBE_STATIC_CODE(ENTRY(mercury__builtin_unify_pred_2_0)),
	MR_MAYBE_STATIC_CODE(ENTRY(mercury__builtin_index_pred_2_0)),
	MR_MAYBE_STATIC_CODE(ENTRY(mercury__builtin_compare_pred_3_0)),
#ifdef  USE_TYPE_LAYOUT
	(const Word *) & mercury_data___type_ctor_layout_pred_0,
	(const Word *) & mercury_data___type_ctor_functors_pred_0,
	(const Word *) & mercury_data___type_ctor_layout_pred_0,
	(const Word *) string_const("builtin", 7),
	(const Word *) string_const("func", 4)
#endif
};

	/*
	** type_ctor_info for `pred' 
	** (this is used for all higher-order pred types) 
	*/

Declare_entry(mercury__builtin_unify_pred_2_0);
Declare_entry(mercury__builtin_index_pred_2_0);
Declare_entry(mercury__builtin_compare_pred_3_0);
MR_STATIC_CODE_CONST struct mercury_data___type_ctor_info_pred_0_struct {
	Integer f1;
	Code *f2;
	Code *f3;
	Code *f4;
#ifdef USE_TYPE_LAYOUT
	const Word *f5;
	const Word *f6;
	const Word *f7;
	const Word *f8;
	const Word *f9;
#endif
} mercury_data___type_ctor_info_pred_0 = {
	((Integer) 0),
	MR_MAYBE_STATIC_CODE(ENTRY(mercury__builtin_unify_pred_2_0)),
	MR_MAYBE_STATIC_CODE(ENTRY(mercury__builtin_index_pred_2_0)),
	MR_MAYBE_STATIC_CODE(ENTRY(mercury__builtin_compare_pred_3_0)),
#ifdef  USE_TYPE_LAYOUT
	(const Word *) & mercury_data___type_ctor_layout_pred_0,
	(const Word *) & mercury_data___type_ctor_functors_pred_0,
	(const Word *) & mercury_data___type_ctor_layout_pred_0,
	(const Word *) string_const("builtin", 7),
	(const Word *) string_const("pred", 4)
#endif
};

Define_extern_entry(mercury__builtin_unify_pred_2_0);
Define_extern_entry(mercury__builtin_index_pred_2_0);
Define_extern_entry(mercury__builtin_compare_pred_3_0);

BEGIN_MODULE(mercury__builtin_unify_pred_module)
	init_entry_ai(mercury__builtin_unify_pred_2_0);
BEGIN_CODE

/* code for predicate 'builtin_unify_pred'/2 in mode 0 */
Define_entry(mercury__builtin_unify_pred_2_0);
	incr_sp_push_msg(2, "private_builtin:builtin_unify_pred");
	fatal_error("attempted unification of higher-order terms");
END_MODULE


BEGIN_MODULE(mercury__builtin_index_pred_module)
	init_entry_ai(mercury__builtin_index_pred_2_0);
BEGIN_CODE

/* code for predicate 'builtin_index_pred'/2 in mode 0 */
Define_entry(mercury__builtin_index_pred_2_0);
	r1 = (Integer) -1;
	proceed();
END_MODULE

BEGIN_MODULE(mercury__builtin_compare_pred_module)
	init_entry_ai(mercury__builtin_compare_pred_3_0);
BEGIN_CODE

/* code for predicate 'builtin_compare_pred'/3 in mode 0 */
Define_entry(mercury__builtin_compare_pred_3_0);
	incr_sp_push_msg(2, "private_builtin:builtin_compare_pred");
	fatal_error("attempted comparison of higher-order terms");
END_MODULE

	/* 
	** MR_create_type_info():
	**
	** Given a type_info (term_type_info) which contains a
	** type_ctor_info pointer and possibly other type_infos
	** giving the values of the type parameters of this type,
	** and a pseudo-type_info (arg_pseudo_type_info), which contains a
	** type_ctor_info pointer and possibly other type_infos
	** giving EITHER
	** 	- the values of the type parameters of this type,
	** or	- an indication of the type parameter of the
	** 	  term_type_info that should be substituted here
	**
	** This returns a fully instantiated type_info, a version of the
	** arg_pseudo_type_info with all the type variables filled in.
	**
	** We allocate memory for a new type_info on the Mercury heap,
	** copy the necessary information, and return a pointer to the
	** new type_info.  You need to wrap save_transient_hp()
	** and restore_transient_hp() around calls to this function.
	**
	** In the case where the argument's pseudo_type_info is a
	** type_ctor_info with no arguments, we don't copy the
	** type_ctor_info - we just return a pointer to it - no memory
	** is allocated. The caller can check this by looking at the
	** first cell of the returned pointer - if it is zero, this is a
	** type_ctor_info. Otherwise, it is an allocated copy of a
	** type_info.
	**
	** NOTE: If you are changing this code, you might also need
	** to change the code in MR_make_type_info in this module 
	** which does much the same thing, only allocating using newmem
	** instead of on the heap.
	*/

Word * 
MR_create_type_info(Word *term_type_info, Word *arg_pseudo_type_info)
{
	int i, arity, extra_args;
	Word *type_ctor_info;
	Word *arg_type_info;
	Word *type_info;

	/* 
	** The arg_pseudo_type_info might be a polymorphic variable.
	** If so, then substitute it's value, and then we're done.
	*/
	if (TYPEINFO_IS_VARIABLE(arg_pseudo_type_info)) {
		arg_type_info = (Word *) 
			term_type_info[(Word) arg_pseudo_type_info];

		if (TYPEINFO_IS_VARIABLE(arg_type_info)) {
			fatal_error("MR_create_type_info: "
					"unbound type variable");
		}

		return arg_type_info;
	}

	type_ctor_info = MR_TYPEINFO_GET_TYPE_CTOR_INFO(arg_pseudo_type_info);

	/* no arguments - optimise common case */
	if (type_ctor_info == arg_pseudo_type_info) {
		return arg_pseudo_type_info;
	}

	if (MR_TYPE_CTOR_INFO_IS_HO(type_ctor_info)) {
		arity = MR_TYPEINFO_GET_HIGHER_ARITY(arg_pseudo_type_info);
		extra_args = 2;
	} else {
		arity = MR_TYPE_CTOR_INFO_GET_TYPE_ARITY(type_ctor_info);
		extra_args = 1;
	}

	/*
	** Iterate over the arguments, figuring out whether we
	** need to make any substitutions.
	** If so, copy the resulting argument type-infos into
	** a new type_info.
	*/
	type_info = NULL;
	for (i = extra_args; i < arity + extra_args; i++) {
		arg_type_info = MR_create_type_info(term_type_info,
				(Word *) arg_pseudo_type_info[i]);
		if (TYPEINFO_IS_VARIABLE(arg_type_info)) {
			fatal_error("MR_create_type_info: "
				"unbound type variable");
		}
		if (arg_type_info != (Word *) arg_pseudo_type_info[i]) {
			/*
			** We made a substitution.
			** We need to allocate a new type_info,
			** if we haven't done so already.
			*/
			if (type_info == NULL) {
				incr_saved_hp(LVALUE_CAST(Word, type_info),
					arity + extra_args);
				memcpy(type_info, arg_pseudo_type_info,
					(arity + extra_args) * sizeof(Word));
			}
			type_info[i] = (Word) arg_type_info;
		}
	}
	if (type_info == NULL) {
		return arg_pseudo_type_info;
	} else {
		return type_info;
	}
}

/*
** MR_compare_type_info(type_info_1, type_info_2):
**
** Compare two type_info structures, using an arbitrary ordering
** (based on the addresses of the type_ctor_infos, or in
** the case of higher order types, the arity).
**
** You need to wrap save/restore_transient_hp() around
** calls to this function.
*/

int
MR_compare_type_info(Word t1, Word t2)
{
	Word	*type_info_1, *type_info_2;
	Word	*type_ctor_info_1, *type_ctor_info_2;
	int	num_arg_types;
	int	i;

	/* 
	** Try to optimize a common case:
	** If type_info addresses are equal, they must represent the
	** same type.
	*/
	if (t1 == t2) {
		return COMPARE_EQUAL;
	}

	/* 
	** Otherwise, we need to expand equivalence types, if any.
	*/
	type_info_1 = (Word *) MR_collapse_equivalences(t1);
	type_info_2 = (Word *) MR_collapse_equivalences(t2);

	/* 
	** Perhaps they are equal now...
	*/
	if (type_info_1 == type_info_2) {
		return COMPARE_EQUAL;
	}

	/*
	** Otherwise find the addresses of the type_ctor_infos,
	** and compare those.
	**
	** Note: this is an arbitrary ordering. It doesn't matter
	** what the ordering is, just so long as it is consistent.
	** ANSI C doesn't guarantee much about pointer comparisons,
	** so it is possible that this might not do the right thing
	** on some obscure systems.
	** The casts to (Word) here are in the hope of increasing
	** the chance that this will work on a segmented architecture.
	*/
	type_ctor_info_1 = MR_TYPEINFO_GET_TYPE_CTOR_INFO(type_info_1);
	type_ctor_info_2 = MR_TYPEINFO_GET_TYPE_CTOR_INFO(type_info_2);
	if ((Word) type_ctor_info_1 < (Word) type_ctor_info_2) {
		return COMPARE_LESS;
	}
	if ((Word) type_ctor_info_1 > (Word) type_ctor_info_2) {
		return COMPARE_GREATER;
	}

	/*
	** If the type_ctor_info addresses are equal, we don't need to
	** compare the arity of the types - they must be the same -
	** unless they are higher-order (which are all mapped to
	** pred/0). 
	** But we need to recursively compare the argument types, if any.
	*/
		/* Check for higher order */
	if (MR_TYPE_CTOR_INFO_IS_HO(type_ctor_info_1)) 
	{
		int num_arg_types_2;

			/* Get number of arguments from type_info */
		num_arg_types = field(mktag(0), type_info_1, 
			TYPEINFO_OFFSET_FOR_PRED_ARITY);

		num_arg_types_2 = field(mktag(0), type_info_2, 
			TYPEINFO_OFFSET_FOR_PRED_ARITY);

			/* Check arity */
		if (num_arg_types < num_arg_types_2) {
			return COMPARE_LESS;
		}
		if (num_arg_types > num_arg_types_2) {
			return COMPARE_GREATER;
		}

			/*
			** Increment, so arguments are at the
			** expected offset.
			*/
		type_info_1++;
		type_info_2++;
	} else {
		num_arg_types = field(mktag(0), type_ctor_info_1,
				OFFSET_FOR_COUNT);
	}
		/* compare the argument types */
	for (i = 0; i < num_arg_types; i++) {
		Word arg_type_info_1 = field(mktag(0), type_info_1,
			OFFSET_FOR_ARG_TYPE_INFOS + i);
		Word arg_type_info_2 = field(mktag(0), type_info_2,
			OFFSET_FOR_ARG_TYPE_INFOS + i);
		int comp = MR_compare_type_info(
				arg_type_info_1, arg_type_info_2);
		if (comp != COMPARE_EQUAL)
			return comp;
	}
	return COMPARE_EQUAL;
}

	/*
	** MR_collapse_equivalences:
	**
	** Keep looking past equivalences until the there are no more.
	** This only looks past equivalences of the top level type, not
	** the argument typeinfos.
	** 
	** You need to wrap save/restore_transient_hp() around
	** calls to this function.
	*/

Word
MR_collapse_equivalences(Word maybe_equiv_type_info) 
{
	Word *functors, equiv_type_info;
	
	functors = MR_TYPE_CTOR_INFO_GET_TYPE_CTOR_FUNCTORS(
			MR_TYPEINFO_GET_TYPE_CTOR_INFO((Word *) 
					maybe_equiv_type_info));

		/* Look past equivalences */
	while (MR_TYPE_CTOR_FUNCTORS_INDICATOR(functors) == MR_TYPE_CTOR_FUNCTORS_EQUIV) {
		equiv_type_info = (Word) MR_TYPE_CTOR_FUNCTORS_EQUIV_TYPE(functors);
		equiv_type_info = (Word) MR_create_type_info(
				(Word *) maybe_equiv_type_info, 
				(Word *) equiv_type_info);
		functors = MR_TYPE_CTOR_INFO_GET_TYPE_CTOR_FUNCTORS(
			MR_TYPEINFO_GET_TYPE_CTOR_INFO((Word *) 
				equiv_type_info));
		maybe_equiv_type_info = equiv_type_info;
	}

	return maybe_equiv_type_info;
}


/*
** MR_deallocate() frees up a list of memory cells
*/
void
MR_deallocate(MR_MemoryList allocated)
{
	while (allocated != NULL) {
		MR_MemoryList next = allocated->next;
		oldmem(allocated->data);
		oldmem(allocated);
		allocated = next;
	}
}

	/* 
	** Given a type_info (term_type_info) which contains a
	** type_ctor_info pointer and possibly other type_infos
	** giving the values of the type parameters of this type,
	** and a pseudo-type_info (arg_pseudo_type_info), which contains a
	** type_ctor_info pointer and possibly other type_infos
	** giving EITHER
	** 	- the values of the type parameters of this type,
	** or	- an indication of the type parameter of the
	** 	  term_type_info that should be substituted here
	**
	** This returns a fully instantiated type_info, a version of the
	** arg_pseudo_type_info with all the type variables filled in.
	** If there are no type variables to fill in, we return the
	** arg_pseudo_type_info, unchanged. Otherwise, we allocate
	** memory using newmem().  Any such memory allocated will be
	** inserted into the list of allocated memory cells.
	** It is the caller's responsibility to free these cells
	** by calling MR_deallocate() on the list when they are no longer
	** needed.
	**
	** This code could be tighter. In general, we want to
	** handle our own allocations rather than using newmem().
	** (Note: we need to use newmem() rather than malloc()
	** because the Boehm collector doesn't trace memory
	** allocated with malloc().)
	**
	** NOTE: If you are changing this code, you might also need
	** to change the code in MR_create_type_info (defined above),
	** which does much the same thing, only allocating on the 
	** heap instead of using newmem.
	*/

Word *
MR_make_type_info(const Word *term_type_info, const Word *arg_pseudo_type_info,
	MR_MemoryList *allocated) 
{
	int i, arity, extra_args;
	Word *type_ctor_info;
	Word *arg_type_info;
	Word *type_info;

	/* 
	** The arg_pseudo_type_info might be a polymorphic variable.
	** If so, then substitute its value, and then we're done.
	*/
	if (TYPEINFO_IS_VARIABLE(arg_pseudo_type_info)) {
		arg_type_info = (Word *) 
			term_type_info[(Word) arg_pseudo_type_info];
		if (TYPEINFO_IS_VARIABLE(arg_type_info)) {
			fatal_error("make_type_info: "
				"unbound type variable");
		}
		return arg_type_info;
	}

	type_ctor_info = MR_TYPEINFO_GET_TYPE_CTOR_INFO(arg_pseudo_type_info);

	/* no arguments - optimise common case */
	if (type_ctor_info == arg_pseudo_type_info) {
		return type_ctor_info;
	} 

	if (MR_TYPE_CTOR_INFO_IS_HO(type_ctor_info)) {
		arity = MR_TYPEINFO_GET_HIGHER_ARITY(arg_pseudo_type_info);
			extra_args = 2;
	} else {
		arity = MR_TYPE_CTOR_INFO_GET_TYPE_ARITY(type_ctor_info);
			extra_args = 1;
	}

	/*
	** Iterate over the arguments, figuring out whether we
	** need to make any substitutions.
	** If so, copy the resulting argument type-infos into
	** a new type_info.
	*/
	type_info = NULL;
	for (i = extra_args; i < arity + extra_args; i++) {
		arg_type_info = MR_make_type_info(term_type_info,
			(Word *) arg_pseudo_type_info[i], allocated);
		if (TYPEINFO_IS_VARIABLE(arg_type_info)) {
			fatal_error("MR_make_type_info: "
				"unbound type variable");
		}
		if (arg_type_info != (Word *) arg_pseudo_type_info[i]) {
			/*
			** We made a substitution.
			** We need to allocate a new type_info,
			** if we haven't done so already.
			*/
			if (type_info == NULL) {
				MR_MemoryList node;
				/*
				** allocate a new type_info and copy the
				** data across from arg_pseudo_type_info
				*/
				type_info = newmem(
					(arity + extra_args) * sizeof(Word));
				memcpy(type_info, arg_pseudo_type_info,
					(arity + extra_args) * sizeof(Word));
				/*
				** insert this type_info cell into the linked
				** list of allocated memory cells, so we can
				** free it later on
				*/
				node = newmem(sizeof(*node));
				node->data = type_info;
				node->next = *allocated;
				*allocated = node;
			}
			type_info[i] = (Word) arg_type_info;
		}
	}
	if (type_info == NULL) {
		return (Word *) (Word) arg_pseudo_type_info;
	} else {
		return type_info;
	}

} /* end MR_make_type_info() */

/*---------------------------------------------------------------------------*/

enum MR_DataRepresentation
MR_categorize_data(Word functors_indicator, Word layout_entry)
{
	switch ((int) functors_indicator) { 
		case MR_TYPE_CTOR_FUNCTORS_ENUM: 
			return MR_DATAREP_ENUM;
		case MR_TYPE_CTOR_FUNCTORS_DU: 
			switch ((int) tag(layout_entry)) {
				case TYPE_CTOR_LAYOUT_SIMPLE_TAG:
					return MR_DATAREP_SIMPLE;
				case TYPE_CTOR_LAYOUT_COMPLICATED_TAG:
					return MR_DATAREP_COMPLICATED;
				case TYPE_CTOR_LAYOUT_CONST_TAG:
					return MR_DATAREP_COMPLICATED_CONST;
				default:
					return MR_DATAREP_UNKNOWN;
			}
		case MR_TYPE_CTOR_FUNCTORS_NO_TAG:
			return MR_DATAREP_NOTAG;
		case MR_TYPE_CTOR_FUNCTORS_EQUIV:
			if (TYPEINFO_IS_VARIABLE(strip_tag(layout_entry))) {
				return MR_DATAREP_EQUIV_VAR;
			} else {
				return MR_DATAREP_EQUIV;
			}
		case MR_TYPE_CTOR_FUNCTORS_SPECIAL:
		{
			int builtin_type = unmkbody(strip_tag(layout_entry));

			switch (builtin_type) {
				case MR_TYPE_CTOR_LAYOUT_UNASSIGNED_VALUE:
					return MR_DATAREP_UNKNOWN;
				case MR_TYPE_CTOR_LAYOUT_UNUSED_VALUE:
					return MR_DATAREP_UNKNOWN;
				case MR_TYPE_CTOR_LAYOUT_STRING_VALUE:
					return MR_DATAREP_STRING;
				case MR_TYPE_CTOR_LAYOUT_FLOAT_VALUE:
					return MR_DATAREP_FLOAT;
				case MR_TYPE_CTOR_LAYOUT_INT_VALUE:
					return MR_DATAREP_INT;
				case MR_TYPE_CTOR_LAYOUT_CHARACTER_VALUE:
					return MR_DATAREP_CHAR;
				case MR_TYPE_CTOR_LAYOUT_PREDICATE_VALUE:
					return MR_DATAREP_PRED;
				case MR_TYPE_CTOR_LAYOUT_VOID_VALUE:
					return MR_DATAREP_VOID;
				case MR_TYPE_CTOR_LAYOUT_ARRAY_VALUE:
					return MR_DATAREP_ARRAY;
				case MR_TYPE_CTOR_LAYOUT_TYPEINFO_VALUE:
					return MR_DATAREP_TYPEINFO;
				case MR_TYPE_CTOR_LAYOUT_C_POINTER_VALUE:
					return MR_DATAREP_C_POINTER;
				case MR_TYPE_CTOR_LAYOUT_TYPECLASSINFO_VALUE:
					return MR_DATAREP_TYPECLASSINFO;
				default: 
					return MR_DATAREP_UNKNOWN;
			}
		}
		case MR_TYPE_CTOR_FUNCTORS_UNIV:
			return MR_DATAREP_UNIV;
		default:
			return MR_DATAREP_UNKNOWN;
	}
}



/*---------------------------------------------------------------------------*/

void mercury_sys_init_type_info(void); /* suppress gcc warning */
void mercury_sys_init_type_info(void) {
	mercury__builtin_unify_pred_module();
	mercury__builtin_index_pred_module();
	mercury__builtin_compare_pred_module();

	MR_INIT_BUILTIN_TYPE_CTOR_INFO(
		mercury_data___type_ctor_info_pred_0, _pred_);
}

