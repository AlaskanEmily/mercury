/*
** Copyright (C) 1995 University of Melbourne.
** This file may only be copied under the terms of the GNU Library General
** Public License - see the file COPYING.LIB in the Mercury distribution.
*/

#ifndef	LABEL_H
#define	LABEL_H

#include	"list.h"

typedef struct s_label
{
	const char	*e_name;   /* name of the procedure	     */
	Code		*e_addr;   /* address of the code	     */
} Label;

extern	void	init_entries(void);
extern	Label	*insert_entry(const char *name, Code *addr);
extern	Label	*lookup_label_name(const char *name);
extern	Label	*lookup_label_addr(const Code *addr);
extern	List	*get_all_labels(void);

#endif
