/*
** Copyright (C) 1995-1997 University of Melbourne.
** This file may only be copied under the terms of the GNU Library General
** Public License - see the file COPYING.LIB in the Mercury distribution.
*/

/*
** label.h defines the interface to the label table, which is a pair of
** hash tables mapping from procedure names to addresses and vice versa.
*/

#ifndef	LABEL_H
#define	LABEL_H

#include "mercury_types.h"	/* for `Code *' */
#include "dlist.h"		/* for `List' */

typedef struct s_label {
	const char	*e_name;   /* name of the procedure	     */
	Code		*e_addr;   /* address of the code	     */
} Label;

extern	void	do_init_entries(void);
extern	Label	*insert_entry(const char *name, Code *addr);
extern	Label	*lookup_label_name(const char *name);
extern	Label	*lookup_label_addr(const Code *addr);
extern	List	*get_all_labels(void);

extern  int 	entry_table_size;
	/* expected number of entries in the table */
	/* we allocate 8 bytes per entry */

#endif /* not LABEL_H */
