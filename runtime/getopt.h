/*
** Copyright (C) 1995 University of Melbourne.
** This file may only be copied under the terms of the GNU Library General
** Public License - see the file COPYING.LIB in the Mercury distribution.
*/

/*
** getopt.h - declares the interface to the system function getopt()
**
** We use this file rather than the system's <getopt.h>
** because different systems have different ideas about
** where the `const's should go on the declaration of getopt().
** Also, some systems might have getopt() but not <getopt.h>.
*/

#ifndef	GETOPT_H
#define	GETOPT_H

#define	GETOPTHUH	'?'
#define	GETOPTDONE	(-1)

extern int	getopt(int, char *const*, const char *);

extern char	*optarg;
extern int	opterr;
extern int	optind;
extern int	optopt;

#endif
