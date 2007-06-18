/*
** vim:sw=4 ts=4 expandtab
*/
/*
** Copyright (C) 2007 The University of Melbourne.
** This file may only be copied under the terms of the GNU General
** Public License - see the file COPYING in the Mercury distribution.
*/

/*
** File: mkinit_erl.c
** Main authors: zs, fjh, wangp
**
** Given a list of .erl or .init files on the command line, this program
** produces the initialization file (usually called *_init.erl) on stdout.
** The initialization file is a small program that calls the initialization
** functions for all the modules in a Mercury program.
**
** Alternatively, if invoked with the -k option, this program produces a
** list of intialization directives on stdout.  This mode of operation is
** is used when building .init files for libraries.
**
** NOTE: any changes to this program may need to be reflected in the
** following places:
**
**      - scripts/c2init.in
**      - compiler/compile_target_code.m
**          in particular the predicates make_init_obj/7 and 
**          make_standalone_interface/3.
**      - util/mkinit.c
**
*/

/*---------------------------------------------------------------------------*/

/* mercury_std.h includes mercury_regs.h, and must precede system headers */
#include    "mercury_conf.h"
#include    "mercury_std.h"
#include    "getopt.h"
#include    "mercury_array_macros.h"
#include    "mkinit_common.h"

#include    <stdio.h>
#include    <stdlib.h>
#include    <string.h>
#include    <ctype.h>
#include    <errno.h>

#ifdef MR_HAVE_SYS_STAT_H
  #include  <sys/stat.h>
#endif

#ifdef MR_HAVE_UNISTD_H
  #include  <unistd.h>
#endif

typedef enum
{
    TASK_OUTPUT_INIT_PROG = 0,
    TASK_OUTPUT_LIB_INIT  = 1
} Task;

typedef enum
{
    PURPOSE_INIT = 0,
    PURPOSE_REQ_INIT = 1,
    PURPOSE_REQ_FINAL = 2
} Purpose;

const char  *main_func_name[] =
{
    "init_modules",
    "init_modules_required",
    "final_modules_required"
};

const char  *module_suffix[] =
{
    "init",
    "",
    "",
};

/*
** List of names of the modules to call all the usual initialization
** functions (in the Erlang backend, just "init").
*/

static const char   **std_modules = NULL;
static int          std_module_max = 0;
static int          std_module_next = 0;
#define MR_INIT_STD_MODULE_SIZE     100

/*
** List of names of modules that have initialization functions that should
** always be run.  We call an "init_required" function for each such module.
*/
static const char   **req_init_modules = NULL;
static int          req_init_module_max = 0;
static int          req_init_module_next = 0;
#define MR_INIT_REQ_MODULE_SIZE     10

/*
** List of names of modules that have finalisation functions that should
** always be run.  We call a "final_required" function for each such module.
*/
static const char   **req_final_modules = NULL;
static int          req_final_module_max = 0;
static int          req_final_module_next = 0;
#define MR_FINAL_REQ_MODULE_SIZE    10

/*
** List of names of environment variables whose values should be sampled
** at initialization.
*/
static const char   **mercury_env_vars = NULL;
static int          mercury_env_var_max = 0;
static int          mercury_env_var_next = 0;
#define MR_ENV_VAR_LIST_SIZE    10

/* options and arguments, set by parse_options() */
static const char   *output_file_name = NULL;
static const char   *grade = "";
static const char   *module_name = "unknown_module_name";
static Task         output_task = TASK_OUTPUT_INIT_PROG;

/* --- code fragments to put in the output file --- */
static const char header1[] =
    "%%\n"
    "%% This code was automatically generated by mkinit_erl - do not edit.\n"
    "%%\n"
    "%% Grade: %s\n"
    "%% Input files:\n"
    "%%\n"
    ;

/* --- function prototypes --- */
static  void    parse_options(int argc, char *argv[]);
static  void    usage(void);
static  void    output_headers(void);
static  void    output_init_function(Purpose purpose,
                    const char **func_names, int num_func_names);
static  int     output_lib_init_file(void);
static  int     output_init_program(void);
static  void    process_file(const char *filename);
static  void    process_init_file(const char *filename, const char *prefix);

/*---------------------------------------------------------------------------*/

int
main(int argc, char **argv)
{
    int exit_status;

    MR_progname = argv[0];

    parse_options(argc, argv);

    set_output_file(output_file_name);

    switch (output_task) {
        case TASK_OUTPUT_LIB_INIT:
            /* Output a .init file */
            exit_status = output_lib_init_file();
            break;
        
        case TASK_OUTPUT_INIT_PROG:
            /* Output a _init.erl file. */
            exit_status = output_init_program();
            break;
        
        default:
            fprintf(stderr, "%s: unknown task\n", MR_progname);
            exit(EXIT_FAILURE);
    }
    
    return exit_status;
}

/*---------------------------------------------------------------------------*/

/*
** Output the initialisation file for a Mercury library, the .init file.
*/
static int
output_lib_init_file(void)
{
    int filenum;
    int i;

    for (filenum = 0; filenum < num_files; filenum++) {
        process_file(files[filenum]);
    }

    for (i = 0; i < std_module_next; i++) {
        printf("INIT %s%s\n", std_modules[i], module_suffix[PURPOSE_INIT]);
    }

    for (i = 0; i < req_init_module_next; i++) {
        printf("REQUIRED_INIT %s\n", req_init_modules[i]);
    }

    for (i = 0; i < req_final_module_next; i++) {
        printf("REQUIRED_FINAL %s\n", req_final_modules[i]);
    }

    for (i = 0; i < mercury_env_var_next; i++) {
        printf("ENVVAR %s\n", mercury_env_vars[i]);
    }

    if (num_errors > 0) {
        fprintf(stderr, "%s: error while creating .init file.\n", MR_progname);
        return EXIT_FAILURE;
    } else {
        return EXIT_SUCCESS;
    }

}

/*---------------------------------------------------------------------------*/

/*
** Output the initialisation program for a Mercury executable, the *_init.erl
** file.
*/
static int
output_init_program(void)
{
    int filenum;
    int num_bunches;
    int i;

    do_path_search(files, num_files);
    output_headers();

    for (filenum = 0; filenum < num_files; filenum++) {
        process_file(files[filenum]);
    }

    fputs("\n", stdout);
    fputs("-module('", stdout);
    /* Make some effort at printing weird module names. */
    for (i = 0; module_name[i] != '\0'; i++) {
        switch (module_name[i]) {
            case '\'':
            case '\\':
                fputc('\\', stdout);
        }
        fputc(module_name[i], stdout);
    }
    fputs("').\n", stdout);
    fputs("-compile(export_all).\n\n", stdout);

    output_init_function(PURPOSE_INIT,
        std_modules, std_module_next);

    output_init_function(PURPOSE_REQ_INIT,
        req_init_modules, req_init_module_next);

    output_init_function(PURPOSE_REQ_FINAL,
        req_final_modules, req_final_module_next);

    printf("init_env_vars() -> \n");
    for (i = 0; i < mercury_env_var_next; i++) {
        printf("\t'ML_erlang_global_server' ! {init_env_var, \"%s\"},\n",
            mercury_env_vars[i]);
    }
    printf("\tvoid.\n");

    if (num_errors > 0) {
        fputs("% Force syntax error, since there were\n", stdout);
        fputs("% errors in the generation of this file\n", stdout);
        fputs("#error \"You need to remake this file\"\n", stdout);
        if (output_file_name != NULL) {
            (void) fclose(stdout);
            (void) remove(output_file_name);
        }
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}

/*---------------------------------------------------------------------------*/

static void
parse_options(int argc, char *argv[])
{
    int         c;
    int         i;
    String_List *tmp_slist;
    int         seen_f_option = 0;

    /*
    ** The set of options for mkinit and mkinit_erl should be
    ** kept in sync, even if they may not necessarily make sense.
    */
    while ((c = getopt(argc, argv, "A:c:f:g:iI:lo:r:tw:xX:ksm:")) != EOF) {
        switch (c) {
        case 'f':
            process_file_list_file(optarg);
            seen_f_option = 1;
            break;

        case 'g':
            grade = optarg;
            break;

        case 'I':
            add_init_file_dir(optarg);
            break;

        case 'm':
            module_name = optarg;
            break;

        case 'o':
            if (strcmp(optarg, "-") == 0) {
                output_file_name = NULL; /* output to stdout */
            } else {
                output_file_name = optarg;
            }
            break;

        case 'x':
            /* We always assume this option. */
            break;

        case 'k':
            output_task = TASK_OUTPUT_LIB_INIT;
            break;

        case 'A':
        case 'c':
        case 'l':
        case 'i':
        case 'r':
        case 't':
        case 'w':
        case 'X':
        case 's':
            /* Used by mkinit. */
            usage();

        default:
            usage();
        }
    }

    if (seen_f_option) {
        /* 
        ** -f could be made compatible if we copied the filenames
        ** from argv into files.
        ** 
        */
        if ((argc - optind) > 0) {
            fprintf(stderr,
                "%s: -f incompatible with filenames on the command line\n",
                MR_progname);
            exit(EXIT_FAILURE);
        }
    } else {
        num_files = argc - optind;
        files = argv + optind;
    }

    if (num_files <= 0) {
        usage();
    }
}

static void
usage(void)
{
    fputs("Usage: mkinit_erl [options] files...\n", stderr);
    fputs("Options:\n", stderr);
    fputs("  -c maxcalls:\t(error)\n", stderr);
    fputs("  -g grade:\tset the grade of the executable\n", stderr);
    fputs("  -f filename:\tprocess the files one per line in filename\n", stderr);
    fputs("  -i:\t\t(error)\n", stderr);
    fputs("  -l:\t\t(error)\n", stderr);
    fputs("  -o file:\toutput to the named file\n", stderr);
    fputs("  -r word:\t(error)\n", stderr);
    fputs("  -t:\t\t(error)\n", stderr);
    fputs("  -w entry:\t(error)\n", stderr);
    fputs("  -I dir:\tadd dir to the search path for init files\n", stderr);
    fputs("  -k:\t\tgenerate the .init for a library\n", stderr);
    fputs("  -s:\t\t(error)\n", stderr);
    fputs("  -m:\t\tset the name of the module\n", stderr);
    exit(EXIT_FAILURE);
}

/*---------------------------------------------------------------------------*/

static void
output_headers(void)
{
    int filenum;

    printf(header1, grade);

    for (filenum = 0; filenum < num_files; filenum++) {
        fputs("% ", stdout);
        fputs(files[filenum], stdout);
        putc('\n', stdout);
    }
}

static void
output_init_function(Purpose purpose, const char **func_names,
    int num_func_names)
{
    int funcnum;

    printf("%s() ->\n",
        main_func_name[purpose]);

    for (funcnum = 0; funcnum < num_func_names; funcnum++) {
        printf("\t%s%s(),\n",
            func_names[funcnum], module_suffix[purpose]);
    }

    fputs("\tvoid.\n", stdout);
}

/*---------------------------------------------------------------------------*/

static void
process_file(const char *filename)
{
    int len;

    len = strlen(filename);
    if (len >= 4 && strcmp(filename + len - 4, ".erl") == 0) {
        process_init_file(filename, "% ");
    } else if (len >= 5 && strcmp(filename + len - 5, ".init") == 0) {
        process_init_file(filename, "");
    } else {
        fprintf(stderr,
            "%s: filename `%s' must end in `.erl' or `.init'\n",
            MR_progname, filename);
        num_errors++;
    }
}

static void
process_init_file(const char *filename, const char *prefix_str)
{
    /*
    ** The strings that are supposed to be followed by other information
    ** (INIT, REQUIRED_INIT, and REQUIRED_FINAL) should end with
    ** the space that separates the keyword from the following data.
    ** The string that is not supposed to be following by other information
    ** (ENDINIT) should not have a following space, since elds_to_erlang.m
    ** does not add that space.
    */

    const char * const  init_str = "INIT ";
    const char * const  reqinit_str = "REQUIRED_INIT ";
    const char * const  reqfinal_str = "REQUIRED_FINAL ";
    const char * const  envvar_str = "ENVVAR ";
    const char * const  endinit_str = "ENDINIT";
    const int           prefix_strlen = strlen(prefix_str);
    const int           init_strlen = strlen(init_str);
    const int           reqinit_strlen = strlen(reqinit_str);
    const int           reqfinal_strlen = strlen(reqfinal_str);
    const int           envvar_strlen = strlen(envvar_str);
    const int           endinit_strlen = strlen(endinit_str);
    char                line0[MAXLINE];
    char *              line;
    int                 len;
    FILE                *erl_file;

    erl_file = fopen(filename, "r");
    if (erl_file == NULL) {
        fprintf(stderr, "%s: error opening file `%s': %s\n",
            MR_progname, filename, strerror(errno));
        num_errors++;
        return;
    }

    while (get_line(erl_file, line0, MAXLINE) > 0) {
        if (strncmp(line0, prefix_str, prefix_strlen) != 0) {
            continue;
        }
        line = line0 + prefix_strlen;

        /* Remove trailing whitespace. */
        len = strlen(line);
        while (len > 0 && isspace(line[len - 1])) {
            line[len - 1] = '\0';
            len--;
        }

        if (strncmp(line, init_str, init_strlen) == 0) {
            char    *func_name;
            int     func_name_len;
            int     j;
            MR_bool special;

            func_name = line + init_strlen;
            func_name_len = strlen(func_name);

            func_name[func_name_len - 4] = '\0';
            MR_ensure_room_for_next(std_module, const char *,
                MR_INIT_STD_MODULE_SIZE);
            std_modules[std_module_next] = checked_strdup(func_name);
            std_module_next++;
        } else if (strncmp(line, reqinit_str, reqinit_strlen) == 0) {
            char    *func_name;
            int     j;

            func_name = line + reqinit_strlen;
            MR_ensure_room_for_next(req_init_module, const char *,
                MR_INIT_REQ_MODULE_SIZE);
            req_init_modules[req_init_module_next] = checked_strdup(func_name);
            req_init_module_next++;
        } else if (strncmp(line, reqfinal_str, reqfinal_strlen) == 0) {
            char    *func_name;
            int     j;

            func_name = line + reqfinal_strlen;
            MR_ensure_room_for_next(req_final_module, const char *,
                MR_FINAL_REQ_MODULE_SIZE);
            req_final_modules[req_final_module_next] =
                checked_strdup(func_name);
            req_final_module_next++;
        } else if (strncmp(line, envvar_str, envvar_strlen) == 0) {
            char    *envvar_name;
            int     i;
            MR_bool found;

            envvar_name = line + envvar_strlen;

            /*
            ** Since the number of distinct environment variables used by
            ** a program is likely to be in the single digits, linear search
            ** should be efficient enough.
            */
            found = MR_FALSE;
            for (i = 0; i < mercury_env_var_next; i++) {
                if (strcmp(envvar_name, mercury_env_vars[i]) == 0) {
                    found = MR_TRUE;
                    break;
                }
            }

            if (!found) {
                MR_ensure_room_for_next(mercury_env_var, const char *,
                    MR_ENV_VAR_LIST_SIZE);
                mercury_env_vars[mercury_env_var_next] =
                    checked_strdup(envvar_name);
                mercury_env_var_next++;
            }
        } else if (strncmp(line, endinit_str, endinit_strlen) == 0) {
            break;
        }
    }

    fclose(erl_file);
}

/*---------------------------------------------------------------------------*/
