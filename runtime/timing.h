/*
** Copyright (C) 1997 University of Melbourne.
** This file may only be copied under the terms of the GNU Library General
** Public License - see the file COPYING.LIB in the Mercury distribution.
*/

/*
** timing.h - interface to timing routines.
**	Defines `MR_CLOCK_TICKS_PER_SECOND'
**	and `MR_get_user_cpu_miliseconds()'.
*/

#ifndef TIMING_H
#define TIMING_H

#include "conf.h"

#ifdef HAVE_SYS_PARAM
#include <sys/param.h>		/* for HZ */
#endif

#include <unistd.h>		/* for sysconf() and _SC_CLK_TCK */
#include <limits.h>		/* CLK_TCK defined here, on some systems */

/* 
** `HZ' is the number of clock ticks per second.
** It is used when converting a clock_t value to a time in seconds.
** It may be defined by <sys/time.h>, but if it is not defined there,
** we may be able to use `sysconf(_SC_CLK_TCK)' or CLK_TCK instead.
*/
#ifdef HZ
  #define MR_CLOCK_TICKS_PER_SECOND	HZ
#elif defined(HAVE_SYSCONF) && defined(_SC_CLK_TCK)
  #define MR_CLOCK_TICKS_PER_SECOND	((int) sysconf(_SC_CLK_TCK))
#elif defined(CLK_TCK)
  #define MR_CLOCK_TICKS_PER_SECOND	CLK_TCK
#else
  /* just leave it undefined */
#endif

/*
** MR_get_user_cpu_miliseconds() returns the CPU time consumed by the
** process, in miliseconds, from an arbitrary initial time.
*/
int MR_get_user_cpu_miliseconds(void);

#endif /* TIMING_H */
