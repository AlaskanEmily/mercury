/*
**  File: code/io.mod.
**  Main author: fjh.
** 
**  This file implements parts of the Mercury standard library
**  modules `io', `require', and `std_util'.
*/

#include "imp.h"
#include "wrapper.h"

/*
** Mercury files are not quite the same as C stdio FILEs,
** because we keep track of a little bit more information.
*/

typedef struct {
	FILE *file;
	int line_number;
} MercuryFile;

MercuryFile mercury_stdin = { NULL, 0 };
MercuryFile mercury_stdout = { NULL, 0 };
MercuryFile mercury_stderr = { NULL, 0 };
MercuryFile *mercury_current_input = &mercury_stdin;
MercuryFile *mercury_current_output = &mercury_stdout;

#define initial_external_state()	0	/* some random number */
#define update_io(r_src, r_dest)	((r_dest) = (r_src))
#define final_io_state(r)		((void)0)

static void
mercury_init_io(void)
{
	mercury_stdin.file = stdin;
	mercury_stdout.file = stdout;
	mercury_stderr.file = stderr;
}

static MercuryFile*
mercury_open(const char *filename, const char *type)
{
	MercuryFile *mf;
	FILE *f;
	
	f = fopen(filename, type);
	if (!f) return NULL;
	mf = (MercuryFile*) newmem(sizeof(MercuryFile));
	if (!mf) {
		fclose(f);
		return NULL;
	}
	mf->file = f;
	mf->line_number = 0;
	return mf;
}

static void
mercury_print_string(MercuryFile* mf, const char *s)
{
	fprintf(mf->file, "%s", s);
	while (*s) {
		if (*s++ == '\n') {
			mf->line_number++;
		}
	}
}
	
static int
mercury_getc(MercuryFile* mf)
{
	int c = getc(mf->file);
	if (c == '\n') {
		mf->line_number++;
	}
	return c;
}

static void
mercury_close(MercuryFile* mf)
{
	assert(mf != &mercury_stdin);
	assert(mf != &mercury_stdout);
	assert(mf != &mercury_stderr);
	fclose(mf->file);
	oldmem(mf);
}

#define COMPARE_EQUAL 0
#define COMPARE_LESS 1
#define COMPARE_GREATER 2

BEGIN_MODULE(io_module)
	mercury_init_io();
BEGIN_CODE

mercury__io__run_0_0:
	incr_sp(1);
	detstackvar(1) = (int) succip;
	r1 = initial_external_state();
	{ extern EntryPoint ENTRY(mercury__io__init_state_2_0); 
	  call(ENTRY(mercury__io__init_state_2_0),
		LABEL(mercury__io__run_0_0_i1),
		LABEL(mercury__io__run_0_0)); }
mercury__io__run_0_0_i1:
	r1 = r2;
	{ extern EntryPoint ENTRY(mercury__main_2_0); 
	  call(ENTRY(mercury__main_2_0),
		LABEL(mercury__io__run_0_0_i2),
		LABEL(mercury__io__run_0_0)); }
mercury__io__run_0_0_i2:
	final_io_state(r2);
	LVALUE_CAST(Word, succip) = detstackvar(1);
	decr_sp(1);
	proceed();

/* input predicates */

mercury__io__read_char_code_4_0:
	r2 = mercury_getc((MercuryFile*)r1);
	update_io(r3, r4);
	proceed();

/* output predicates - with output to mercury_current_output */

mercury__io__write_string_3_0:
	mercury_print_string(mercury_current_output, (char *) r1);
	update_io(r2, r3);
	proceed();

mercury__io__write_char_3_0:
	fprintf(mercury_current_output->file, "%c", (int) r1);
	update_io(r2, r3);
	proceed();

mercury__io__write_int_3_0:
	fprintf(mercury_current_output->file, "%d", (int) r1);
	update_io(r2, r3);
	proceed();

mercury__io__write_float_3_0:
	fatal_error("floating point not implemented");

mercury__io__write_anything_3_0:
	fprintf(mercury_current_output->file,
		"<write_anything not implemented>\n");
	update_io(r2, r3);
	proceed();

mercury__io__flush_output_2_0:
	fflush(mercury_current_output->file);
	update_io(r1, r2);
	proceed();

/* output predicates - with output to the specified stream */

mercury__io__write_string_4_0:
	mercury_print_string((MercuryFile*)r1, (char *)r2);
	update_io(r3, r4);
	proceed();

mercury__io__write_char_4_0:
	fprintf(((MercuryFile*)r1)->file, "%c", (int) r2);
	update_io(r3, r4);
	proceed();

mercury__io__write_int_4_0:
	fprintf(((MercuryFile*)r1)->file, "%d", (int) r2);
	update_io(r3, r4);
	proceed();

mercury__io__write_float_4_0:
	fatal_error("floating point not implemented");

mercury__io__write_anything_4_0:
	fprintf(((MercuryFile*)r1)->file,
		"<write_anything not implemented>\n");
	update_io(r3, r4);
	proceed();

mercury__io__flush_output_3_0:
	fflush(((MercuryFile*)r1)->file);
	update_io(r2, r3);
	proceed();

/* stream predicates */

mercury____Unify___io__stream_0_0:
	r1 = ((MercuryFile*) r2 == (MercuryFile *)r3);
	proceed();

mercury____Compare___io__stream_0_0:
	r1 = ((r2 < r3) ? COMPARE_LESS :
	      (r2 > r3) ? COMPARE_GREATER :
			  COMPARE_EQUAL);
	proceed();

mercury____Index___io__stream_0_0:
	r2 = -1;
	proceed();

mercury__io__stdin_stream_3_0:
	r1 = (int) &mercury_stdin;
	update_io(r2, r3);
	proceed();

mercury__io__stdout_stream_3_0:
	r1 = (int) &mercury_stdout;
	update_io(r2, r3);
	proceed();

mercury__io__stderr_stream_3_0:
	r1 = (int) &mercury_stderr;
	update_io(r2, r3);
	proceed();

mercury__io__input_stream_3_0:
	r1 = (int) mercury_current_input;
	update_io(r2, r3);
	proceed();

mercury__io__get_line_number_3_0:
	r1 = mercury_current_input->line_number;
	update_io(r2, r3);
	proceed();
	
mercury__io__get_line_number_4_0:
	r2 = ((MercuryFile*) r1)->line_number;
	update_io(r3, r4);
	proceed();
	
mercury__io__output_stream_3_0:
	r1 = (int) mercury_current_output;
	update_io(r2, r3);
	proceed();

mercury__io__set_input_stream_4_0:
	r1 = (int) mercury_current_input;
	mercury_current_input = (MercuryFile*) r2;
	update_io(r3, r4);
	proceed();

mercury__io__set_output_stream_4_0:
	r1 = (int) mercury_current_output;
	mercury_current_output = (MercuryFile*) r2;
	update_io(r3, r4);
	proceed();

/* stream open/close predicates */

mercury__io__do_open_input_5_0:
	r3 = (int)mercury_open((char*)r1, "r");
	r2 = (r3) ? 0 : -1;
	update_io(r4, r5);
	proceed();

mercury__io__do_open_output_5_0:
	r3 = r2 = (int)mercury_open((char*)r1, "w");
	r2 = (r3) ? 0 : -1;
	update_io(r4, r5);
	proceed();

mercury__io__do_open_append_5_0:
	r2 = (int)mercury_open((char*)r1, "a");
	r2 = (r3) ? 0 : -1;
	update_io(r4, r5);
	proceed();

mercury__io__close_input_3_0:
	mercury_close((MercuryFile*)r1);
	update_io(r2, r3);
	proceed();

mercury__io__close_output_3_0:
	mercury_close((MercuryFile*)r1);
	update_io(r2, r3);
	proceed();

/* miscellaneous predicates */

mercury__io__progname_4_0:
	r2 = (progname ? (int) progname : r1);
	update_io(r3, r4);
	proceed();

mercury__io__command_line_arguments_3_0:
	/* convert mercury_argv from a vector to a list */
	{ char **p = mercury_argv + mercury_argc;
	  r1 = mkword(TAG_NIL, 0);
	  while (--p >= mercury_argv) {
		r1 = mkword(TAG_CONS, create2((Word)*p, r1));
	  }
	}
	update_io(r2, r3);
	proceed();

mercury__io__preallocate_heap_space_3_0:
	/* don't do anything - preallocate_heap_space was just a
	   hack for NU-Prolog */
	update_io(r2, r3);
	proceed();

mercury__io__call_system_code_4_0:
	r2 = system((char *)r1);
	update_io(r3, r4);
	proceed();

mercury____Unify___io__external_state_0_0:
mercury____Compare___io__external_state_0_0:
mercury____Index___io__external_state_0_0:
	/* the unique mode system should prevent these */
	fatal_error("cannot unify/compare/index io__external_state");

/*---------------------------------------------------------------------------*/

/* error/1, from require.nl */

mercury__error_1_0:
	fprintf(stderr, "Software error: %s\n", (char *) r1);
	abort();
#ifndef	USE_GCC_NONLOCAL_GOTOS
	return 0;	/* suppress some dumb warnings */
#endif

/*---------------------------------------------------------------------------*/

/* report_stats/0 and type_to_univ/2, from std_util.nl */

mercury__report_stats_0_0:
	fprintf(mercury_current_output->file, 
		"[Heap: %.3fk, D Stack: %.3fk, ND Stack: %.3fk]\n",
		((char *)hp - (char *)heapmin) / 1000.0,
		((char *)sp - (char *)detstackmin) / 1000.0,
		((char *)maxfr - (char *)nondstackmin) / 1000.0
	);
	proceed();

/*
	:- pred type_to_univ(T, univ).
	:- mode type_to_univ(in, out) is det.
	:- mode type_to_univ(out, in) is semidet.
*/
mercury__type_to_univ_2_0:
	/*
	 *  Forward mode - convert from type to univ.
	 *  On entry r1 contains type_info for type T,
	 *  and r2 contains the input argument of type T.
	 *  On exit r3 contains the output argument of type univ.
	 */
	incr_hp(r3, 2); /* allocate heap space */
	field(mktag(0), r3, 0) = r1;
		/* set the first field to contain the address of the
		   unification predicate */
	field(mktag(0), r3, 1) = r2;
		/* store the input argument in the second field */
	proceed();

mercury__type_to_univ_2_1:
	/*
	 *  Backward mode - convert from univ to type.
	 *  On entry r2 contains type_info for type T,
	 *  and r4 contains the input argument of type univ.
	 *  On successful exit r3 contains the output argument of type T;
	 *  r1 is for the success/failure indication.
	 *
	 *  XXX We check that the type_info addresses match.
	 *	This is incorrect - the type_info structures could
	 *	have been created in different places.
	 *  XXX As a tempory hack, we don't check.
	 */
/***
	if (field(mktag(0), r4, 0) != r2) {
		r1 = FALSE;
		proceed();
	}
***/
	r3 = field(mktag(0), r4, 1);
	r1 = TRUE;
	proceed();

mercury____Unify___univ_0_0:
	/* Unification for univ:
	** This is probably bogus, but who cares?
	*/

	/* first check the type_info addresses match */
	r1 = field(mktag(0), r2, 0);
	if (r1 != field(mktag(0), r3, 0)) {
		r1 = FALSE;
		proceed();
	}

	/* then invoke the generic unification predicate on the
	   unwrapped args */
	r4 = field(mktag(0), r3, 1);
	r3 = field(mktag(0), r2, 1);
	r2 = r1;
	tailcallentry(mercury__unify_2_0);

mercury____Compare___univ_0_0:
	/* Comparison for univ:
	** This is probably bogus, but who cares?
	*/

	/* first compare the type_info, then if
	   they are equal invoke the generic compare/3 predicate on
	   the unwrapped args */
	r1 = field(mktag(0), r2, 0);
	r4 = field(mktag(0), r3, 0);
	if (r1 < r4) {
		r1 = COMPARE_LESS;
		proceed();
	}
	if (r1 > r4) {
		r1 = COMPARE_GREATER;
		proceed();
	}
	r4 = field(mktag(0), r3, 1);
	r3 = field(mktag(0), r2, 1);
	tailcall((Code *)r1);

mercury____Index___univ_0_0:
	r2 = -1;
	proceed();

/*---------------------------------------------------------------------------*/

/* from string.nl */

mercury__string__to_float_2_0:
		/* mode string__to_float(in, out) is semidet */
	{ float tmp;
		/* use a temporary, since we can't take the address of a reg */
	  r1 = sscanf((char *)r2, "%f", &tmp);
		/* r1 is TRUE if sscanf succeeds, FALSE otherwise */
	  r3 = *(Word*)&tmp;
	}
	proceed();

mercury__string__to_int_list_2_0:
		/* mode (in, out) is det */
	{ char *p = (char*)r1 + strlen((char*)r1);
	  r2 = mkword(TAG_NIL, 0);
	  while (--p >= (char*)r1) {
		r2 = mkword(TAG_CONS, create2(*p, r2));
	  }
	}
	proceed();

/*-----------------------------------------------------------------------*/

mercury__string__to_int_list_2_1:
		/* mode (out, in) is det */
/*
** save int_list in r3;
*/
	r3 = r2;
/*
** loop to calculate list length + 4 in r4 using list in r2
*/
	r4 = 4;
	GOTO_LABEL(mercury__string__to_int_list_2_1_i4);
mercury__string__to_int_list_2_1_i3:
	r2 = field(TAG_CONS, r2, 1);
	r4 = ((int) r4 + 1);
mercury__string__to_int_list_2_1_i4:
	if (r2 != mkword(TAG_NIL, mkbody(0)))
		GOTO_LABEL(mercury__string__to_int_list_2_1_i3);
/*
** allocate (length + 1) bytes of heap space for string
** i.e. (length + 4) / 4 words
*/
	incr_hp(r1, r4 / 4);
/*
** loop to copy the characters from the int_list to the string
*/
	r4 = 0;
	GOTO_LABEL(mercury__string__to_int_list_2_1_i5);
mercury__string__to_int_list_2_1_i6:
	((char *) r1) [r4] = (char) field(TAG_CONS, r3, 0);
	r4 = ((int) r4 + 1);
	r3 = field(TAG_CONS, r3, 1);
mercury__string__to_int_list_2_1_i5:
	if (r3 != mkword(TAG_NIL, mkbody(0)))
		GOTO_LABEL(mercury__string__to_int_list_2_1_i6);
/*
** null terminate the string and return
*/
	((char *) r1) [r4] = '\0';
	proceed();

/*-----------------------------------------------------------------------*/

mercury__string__to_int_list_2_2:
		/* mode (in, in) is semidet */
	incr_sp(2);
	detstackvar(1) = (int) succip;
	detstackvar(2) = r2;
	r2 = r3;
	localcall(mercury__string__to_int_list_2_1,
		LABEL(mercury__string__to_int_list_2_2_i1),
		LABEL(mercury__string__to_int_list_2_2));
mercury__string__to_int_list_2_2_i1:
	r1 = string_equal(r1, detstackvar(2));
	LVALUE_CAST(Word,succip) = (int) detstackvar(1);
	decr_sp(1);
	proceed();

mercury__builtin_strcmp_3_0:
	r1 = strcmp((char *)r2, (char *)r3);
	proceed();

/*-----------------------------------------------------------------------*/

mercury__term_io__read_term_3_0:
	{ extern EntryPoint ENTRY(mercury__parser__read_term_3_0);
	  tailcall(ENTRY(mercury__parser__read_term_3_0)); }

/*-----------------------------------------------------------------------*/

/* XXX The following predicates have not yet been implemented! */

mercury__opt_debug__write_1_0:
	fatal_error("opt_debug__write/1 not implemented");

END_MODULE
