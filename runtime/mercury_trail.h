/*
** Copyright (C) 1997 The University of Melbourne.
** This file may only be copied under the terms of the GNU Library General
** Public License - see the file COPYING.LIB in the Mercury distribution.
*/

/*
** mercury_trail.h - code for handling the trail.
**
** The trail is used to record values that need to be
** restored on backtracking.
*/

#ifndef MERCURY_TRAIL_H
#define MERCURY_TRAIL_H

#include "memory.h"

/*---------------------------------------------------------------------------*/
/*
** The following macros define how to store and retrieve a 'ticket' -
** the information that we need to be able to backtrack. 
** This is the interface with the code generator;
** the macros here are used by the generated code.
**
** MR_store_ticket()
**	called when creating a choice point, or before a commit
** MR_reset_ticket()
**	called when resuming forward execution after failing (MR_undo),
**	or after a commit (MR_commit)
** MR_discard_ticket()
**	called when cutting away or failing over the topmost choice point
** MR_mark_ticket_stack()
**	called before a commit
** MR_discard_tickets_to()
**	called after a commit
*/
/*---------------------------------------------------------------------------*/

/* void MR_mark_ticket_stack(Word &); */
#define MR_mark_ticket_stack(save_ticket_counter)		\
	do {							\
		save_ticket_counter = MR_ticket_counter;	\
	} while(0)

/* void MR_discard_ticket(void); */
#define MR_discard_ticket()					\
	do {							\
		--MR_ticket_counter;				\
	} while(0)

/* void MR_discard_tickets_to(Word); */
#define MR_discard_tickets_to(save_ticket_counter)		\
	do {							\
		MR_ticket_counter = save_ticket_counter;	\
	} while(0)

	/* 
	** Called when we create a choice point
	** (including semidet choice points).
	*/
/* void MR_store_ticket(Word &); */
#define MR_store_ticket(save_trail_ptr)				\
	do {							\
		(save_trail_ptr) = (Word) MR_trail_ptr; 	\
		++MR_ticket_counter;				\
	} while(0)

	  /*
	  ** Unwind restoration info back to `old'.  `kind' indicates
	  ** whether we are restoring or just discarding the info.
	  */
/* void MR_reset_ticket(Word, MR_untrail_reason); */
#define MR_reset_ticket(old, kind)				\
	do {							\
		MR_TrailEntry *old_trail_ptr =  		\
			(MR_TrailEntry *)old;			\
		if (MR_trail_ptr != old_trail_ptr) {		\
			save_transient_registers();		\
			MR_untrail_to(old_trail_ptr, kind);	\
			restore_transient_registers();		\
		}						\
	} while(0)

/*---------------------------------------------------------------------------*/
/*
** The following stuff defines the Mercury trail.
** All of the stuff in the section below is implementation details.
** Do not use it.  Instead, use the interface functions/macros
** defined in the next section.
*/
/*---------------------------------------------------------------------------*/

/*
** MR_untrail_reason defines the possible reasons why the trail is to be
** traversed.
*/
typedef enum {
        MR_undo,        /* Ordinary backtracking on failure.  Function */
                        /* trail entries are invoked and value trail */
                        /* entries are used to restore memory.  Then */
                        /* these trail entries are discarded. */
        MR_commit,      /* Pruning.  Function trail entries are invoked */
                        /* and discarded; value trail entries are just */
                        /* discarded. */
        MR_exception,   /* (reserved for future use) An exception was */
                        /* thrown.  Behaves as MR_undo, except that */
                        /* function trail entries may choose to behave */
                        /* differently for exceptions than for failure. */
        MR_gc           /* (reserved for future use) Garbage collection. */
                        /* The interface between the trail and accurate */
                        /* garbage collection is not yet designed. */
} MR_untrail_reason;

typedef enum {
	MR_val_entry,
	MR_func_entry
} MR_trail_entry_kind;
#define MR_LAST_TRAIL_ENTRY_KIND MR_func_entry

/*
** MR_USE_TAGGED_TRAIL is true iff we have enough tag bits to store
** an MR_trail_entry_kind as a pointer tag.
*/
#define MR_USE_TAGGED_TRAIL ((1<<TAGBITS) > MR_LAST_TRAIL_ENTRY_KIND)

typedef void MR_untrail_func_type(Word datum, MR_untrail_reason);

typedef struct {
#if !(MR_USE_TAGGED_TRAIL)
	MR_trail_entry_kind MR_entry_kind;
#endif
	union {
		struct {
			Word *MR_address;
			Word MR_value;
		} MR_val;
		struct {
			MR_untrail_func_type *MR_untrail_func;
			Word MR_datum;
		} MR_func;
	} MR_union;
} MR_TrailEntry;

/*
** Macros for accessing these fields, taking tagging into account.
** DO NOT ACCESS THE FIELDS DIRECTLY.
*/

#if MR_USE_TAGGED_TRAIL
  #define MR_func_trail_tag mktag(MR_func_entry)
  #define MR_value_trail_tag mktag(MR_val_entry)

  /*
  ** MR_trail_entry_kind MR_get_trail_entry_kind(const MR_trail_entry *);
  */
  #define MR_get_trail_entry_kind(entry)				\
	((MR_trail_entry_kind)						\
	  (tag((Word) (entry)->MR_union.MR_val.MR_address)))

  /*
  ** Word * MR_get_trail_entry_address(const MR_trail_entry *);
  */
  #define MR_get_trail_entry_address(entry) \
	((Word *)							\
	  body((entry)->MR_union.MR_val.MR_address, MR_value_trail_tag))

  /*
  ** MR_untrail_func_type *
  ** MR_get_trail_entry_untrail_func(const MR_trail_entry *);
  */
  #define MR_get_trail_entry_untrail_func(entry)			\
	((MR_untrail_func_type *)					\
	    body((Word) (entry)->MR_union.MR_func.MR_untrail_func,	\
		     MR_func_trail_tag))

  /*
  ** void MR_store_value_trail_entry(
  **		MR_trail_entry *entry, MR_untrail_func *func, Word datum);
  */
  #define MR_store_value_trail_entry(entry, address, value)		\
	  do {								\
		(entry)->MR_union.MR_val.MR_address =			\
			(Word *) (Word)					\
			  mkword(MR_value_trail_tag, (address));	\
		(entry)->MR_union.MR_val.MR_value = (value);		\
	  } while (0)

  /*
  ** void MR_store_function_trail_entry(
  **		MR_trail_entry * func, MR_untrail_func entry, Word datum);
  */
  #define MR_store_function_trail_entry(entry, func, datum)		\
	  do {								\
		(entry)->MR_union.MR_func.MR_untrail_func =		\
			(MR_untrail_func_type *) (Word)			\
			  mkword(MR_func_trail_tag, (func));		\
		(entry)->MR_union.MR_func.MR_datum = (datum);		\
	  } while (0)
#else /* !MR_USE_TAGGED_TRAIL */
  #define MR_get_trail_entry_kind(entry) ((entry)->MR_kind)

  #define MR_get_trail_entry_address(entry) \
	((entry)->MR_union.MR_val.MR_address)

  #define MR_get_trail_entry_untrail_func(entry) \
	((entry)->MR_union.MR_func.MR_untrail_func)

  /*
  ** void MR_store_value_trail_entry(
  **		MR_trail_entry *entry, Word *address, Word value);
  */
  #define MR_store_value_trail_entry(entry, address, value)		\
	  do {								\
		(entry)->MR_kind = MR_val_entry;			\
		(entry)->MR_union.MR_val.MR_address = (address);	\
		(entry)->MR_union.MR_val.MR_value = (value);		\
	  } while (0)

  /*
  ** void MR_store_value_trail_entry_kind(
  **		MR_trail_entry *entry, MR_untrail_func *func, Word datum);
  */
  #define MR_store_function_trail_entry(entry, func, datum)		\
	  do {								\
		(entry)->MR_kind = MR_func_entry;			\
		(entry)->MR_union.MR_func.MR_untrail_func = (func);	\
		(entry)->MR_union.MR_func.MR_datum = (datum);		\
	  } while (0)
#endif

/*
** Word MR_get_trail_entry_value(const MR_trail_entry *);
*/
#define MR_get_trail_entry_value(entry) \
	((entry)->MR_union.MR_val.MR_value)

/*
** Word MR_get_trail_entry_datum(const MR_trail_entry *);
*/
#define MR_get_trail_entry_datum(entry) \
	((entry)->MR_union.MR_func.MR_datum)

/*---------------------------------------------------------------------------*/

/* The Mercury trail */
extern MemoryZone *MR_trail_zone;

/* Pointer to the current top of the Mercury trail */
/* N.B. Use `MR_trail_ptr', defined in regorder.h, not `MR_trail_ptr_var'. */
extern MR_TrailEntry *MR_trail_ptr_var;

/*
** An integer variable that is incremented whenever we create a choice
** point (including semidet choice points, e.g. in an if-then-else)
** and decremented whenever we remove one.
**
** N.B.  Use `MR_ticket_counter', defined in regorder,h,
** not `MR_ticket_counter_var'.
*/
extern Unsigned MR_ticket_counter_var;

/*---------------------------------------------------------------------------*/
/*
** This is the interface that should be used by C code that wants to
** do trailing.
*/
/*---------------------------------------------------------------------------*/

/*
** void  MR_trail_value(Word *address, Word value);
**
** Make sure that when the current execution is
** backtracked over, `value' is placed in `address'.
*/
#define MR_trail_value(address, value)		\
	do {							\
		MR_store_value_trail_entry(MR_trail_ptr,	\
			(address), (value));			\
		MR_trail_ptr++;					\
	} while(0);

/*
** void  MR_trail_value_at_address(Word *address);
**
** Make sure that when the current execution is
** backtracked over, the value currently in `address'
** is restored.
*/
#define MR_trail_value_at_address(address) \
	MR_trail_value((address), *(address))

/*
** void MR_trail_function(void (*untrail_func)(Word, MR_untrail_reason),
**		Word value);
**
** Make sure that when the current execution is
** backtracked over, (*untrail_func)(value, MR_undo) is called.
** Also make sure that if the current choicepoint is
** trimmed without being backtracked over (ie, the
** current choice is committed to), then
** (*untrail_func)(value, MR_commit) is called.
*/
#define MR_trail_function(untrail_func, datum)				\
	do {								\
		MR_store_function_trail_entry((MR_trail_ptr),		\
			(untrail_func), (datum));			\
		MR_trail_ptr++;						\
	} while(0);

/*
** Apply all the trail entries between MR_trail_ptr and old_trail_ptr.
*/
void MR_untrail_to(MR_TrailEntry *old_trail_ptr, MR_untrail_reason reason);

/* abstract type */
typedef Unsigned MR_ChoicepointId;

/*
** MR_ChoicepointId MR_current_choicepoint_id(void);
**
** Returns a value indicative of the current
** choicepoint.  If we execute
** 
** 	oldcp = MR_current_choicepoint_id();
** 	... and a long time later ...
** 	if (oldcp == MR_current_choicepoint_id()) {A}
** 
** then we can be assured that if the choicepoint current
** at the time of the first call to MR_current_choicepoint()
** has not been backtracked over before the second call,
** then code A will be executed if and only if the
** current choicepoint is the same in both calls.
*/
#define MR_current_choicepoint_id() ((const MR_ChoicepointId)MR_ticket_counter)

#endif /* not MERCURY_TRAIL_H */
