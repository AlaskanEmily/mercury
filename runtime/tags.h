/*
** Copyright (C) 1993-1997 University of Melbourne.
** This file may only be copied under the terms of the GNU Library General
** Public License - see the file COPYING.LIB in the Mercury distribution.
*/

/*
** tags.h - defines macros for tagging and untagging words.
** Also defines macros for accessing the Mercury list type from C.
*/

#ifndef TAGS_H
#define TAGS_H

#include <limits.h>		/* for `CHAR_BIT' */
#include "conf.h"		/* for `LOW_TAG_BITS' */
#include "mercury_types.h"	/* for `Word' */

/* DEFINITIONS FOR WORD LAYOUT */

#define	WORDBITS	(CHAR_BIT * sizeof(Word))

/* TAGBITS specifies the number of bits in each word that we can use for tags */
#ifndef TAGBITS
  #ifdef HIGHTAGS
    #error "HIGHTAGS defined but TAGBITS undefined"
  #else
    #define TAGBITS	LOW_TAG_BITS
  #endif
#endif

#if TAGBITS > 0 && defined(HIGHTAGS) && defined(CONSERVATIVE_GC)
  #error "Conservative GC does not work with high tag bits"
#endif

#ifdef	HIGHTAGS

#define	mktag(t)	((Word)(t) << (WORDBITS - TAGBITS))
#define	unmktag(w)	((Word)(w) >> (WORDBITS - TAGBITS))
#define	tag(w)		((w) & ~(~(Word)0 >> TAGBITS))
#define mkbody(i)	(i)
#define unmkbody(w)	(w)
#define	body(w, t)	((w) & (~(Word)0 >> TAGBITS))

#else /* ! HIGHTAGS */

#define	mktag(t)	(t)
#define	unmktag(w)	(w)
#define	tag(w)		((w) & ((1 << TAGBITS) - 1))
#define mkbody(i)	((i) << TAGBITS)
#define unmkbody(w)	((Word) (w) >> TAGBITS)
#define	body(w, t)	((w) - (t))

#endif /* ! HIGHTAGS */

/*
** the result of mkword() is cast to (const Word *), not to (Word)
** because mkword() may be used in initializers for static constants
** and casts from pointers to integral types are not valid
** constant-expressions in ANSI C.
*/
/* XXX can't implement the above comment yet due to bootstrapping problems! */
#define	mkword(t, p)	((Word)((const char *)(p) + (t)))

#define	field(t, p, i)		((Word *) body((p), (t)))[i]
#define	const_field(t, p, i)	((const Word *) body((p), (t)))[i]

/*
** the following list_* macros are used by handwritten C code
** that needs to access Mercury lists.
*/

#define	bTAG_NIL	0
#define	bTAG_CONS	1
#define	bTAG_VAR	3 	/* for Prolog-style variables */
				/* ... but currently not used */

#define	TAG_NIL		mktag(bTAG_NIL)
#define	TAG_CONS	mktag(bTAG_CONS)
#define	TAG_VAR		mktag(bTAG_VAR)

#if TAGBITS > 0

#define list_is_empty(list)	(tag(list) == TAG_NIL)
#define list_head(list)		field(TAG_CONS, (list), 0)
#define list_tail(list)		field(TAG_CONS, (list), 1)
#define list_empty()		mkword(TAG_NIL, mkbody(0))
#define list_cons(head,tail)	mkword(TAG_CONS, create2((head),(tail)))

#else

#define list_is_empty(list)	(field(mktag(0), (list), 0) == bTAG_NIL)
#define list_head(list)		field(mktag(0), (list), 1)
#define list_tail(list)		field(mktag(0), (list), 2)
#define list_empty()		mkword(mktag(0), create1(bTAG_NIL))
#define list_cons(head,tail)	\
		mkword(mktag(0), create3(bTAG_CONS, (head), (tail)))

#endif

/* for Prolog-style variables... currently not used */
#define	deref(pt)	do {						\
				while (tag(pt) == TAG_VAR)		\
					(pt) = * (Word *)		\
						body((pt), TAG_VAR);	\
			} while(0)

#endif	/* TAGS_H */
