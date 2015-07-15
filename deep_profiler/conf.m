%-----------------------------------------------------------------------------%
% vim: ft=mercury ts=4 sw=4 et
%-----------------------------------------------------------------------------%
% Copyright (C) 2001-2002, 2004-2008, 2010 The University of Melbourne.
% This file may only be copied under the terms of the GNU General
% Public License - see the file COPYING in the Mercury distribution.
%-----------------------------------------------------------------------------%
%
% Author: zs.
%
% This module contains primitives whose parameters are decided by
% ../configure.in. This module picks them up from the #defines put into
% runtime/mercury_conf.h by the configure script.

:- module conf.

:- interface.

:- import_module io.

%-----------------------------------------------------------------------------%

    % Given a pathname, return a shell command that will create a named pipe
    % with that pathname.
    %
:- func make_pipe_cmd(string) = string.

    % The name of the server and, optionally, the port on which mdprof is
    % being run.
    %
:- pred server_name_port(string::out, io::di, io::uo) is det.

    % The virtual path under which this program is being executed, used for
    % self-referencing URLs.
    %
:- pred script_name(string::out, io::di, io::uo) is det.

:- func getpid = int.

%-----------------------------------------------------------------------------%
%-----------------------------------------------------------------------------%

:- implementation.

:- import_module list.
:- import_module maybe.
:- import_module require.
:- import_module string.

%-----------------------------------------------------------------------------%

make_pipe_cmd(PipeName) = Cmd :-
    mkfifo_cmd(CmdName),
    ( if CmdName = "" then
        unexpected($module, $pred, "do not know what command to use")
    else
        string.format("%s %s", [s(CmdName), s(PipeName)], Cmd)
    ).

server_name_port(Machine, !IO) :-
    server_name(ServerName, !IO),
    maybe_server_port(MaybeServerPort, !IO),
    (
        MaybeServerPort = yes(Port),
        Machine = ServerName ++ ":" ++ Port
    ;
        MaybeServerPort = no,
        Machine = ServerName
    ).

:- pred server_name(string::out, io::di, io::uo) is det.

server_name(ServerName, !IO) :-
    io.get_environment_var("SERVER_NAME", MaybeServerName, !IO),
    (
        MaybeServerName = yes(ServerName)
    ;
        MaybeServerName = no,
        server_name_2(ServerName, !IO)
    ).

:- pred server_name_2(string::out, io::di, io::uo) is det.

server_name_2(ServerName, !IO) :-
    io.make_temp(TmpFile, !IO),
    hostname_cmd(HostnameCmd),
    ServerRedirectCmd =
        string.format("%s > %s", [s(HostnameCmd), s(TmpFile)]),
    io.call_system(ServerRedirectCmd, Res1, !IO),
    (
        Res1 = ok(ResCode),
        ( if ResCode = 0 then
            io.open_input(TmpFile, TmpRes, !IO),
            (
                TmpRes = ok(TmpStream),
                io.read_file_as_string(TmpStream, TmpReadRes, !IO),
                (
                    TmpReadRes = ok(ServerNameNl),
                    ( if
                        string.remove_suffix(ServerNameNl, "\n",
                            ServerNamePrime)
                    then
                        ServerName = ServerNamePrime
                    else
                        unexpected($module, $pred, "malformed server name")
                    )
                ;
                    TmpReadRes = error(_, _),
                    unexpected($module, $pred, "cannot read server's name")
                ),
                io.close_input(TmpStream, !IO)
            ;
                TmpRes = error(_),
                unexpected($module, $pred,
                    "cannot open file to find the server's name")
            ),
            io.remove_file(TmpFile, _, !IO)
        else
            unexpected($module, $pred,
                "cannot execute cmd to find the server's name")
        )
    ;
        Res1 = error(_),
        unexpected($module, $pred,
            "cannot execute cmd to find the server's name")
    ).

:- pred maybe_server_port(maybe(string)::out, io::di, io::uo) is det.

maybe_server_port(MaybeServerPort, !IO) :-
    io.get_environment_var("SERVER_PORT", MaybeServerPort, !IO).

script_name(ScriptName, !IO) :-
    io.get_environment_var("SCRIPT_NAME", MaybeScriptName, !IO),
    (
        MaybeScriptName = yes(ScriptName)
    ;
        MaybeScriptName = no,
        % Should not happen if this predicate is called as a CGI program,
        % but this predicate is also called by other tools.
        ScriptName = "/cgi-bin/mdprof_cgi"
    ).

:- pred mkfifo_cmd(string::out) is det.

:- pragma foreign_proc("C",
    mkfifo_cmd(Mkfifo::out),
    [will_not_call_mercury, promise_pure, thread_safe],
"
    /* shut up warnings about casting away const */
    Mkfifo = (MR_String) (MR_Integer) MR_MKFIFO;
").

:- pred hostname_cmd(string::out) is det.

:- pragma foreign_proc("C",
    hostname_cmd(Hostname::out),
    [will_not_call_mercury, promise_pure, thread_safe],
"
    /* shut up warnings about casting away const */
    Hostname = (MR_String) (MR_Integer) MR_HOSTNAMECMD;
").

:- pragma foreign_decl("C",
"
#ifdef  MR_DEEP_PROFILER_ENABLED
#include    <sys/types.h>
#include    <unistd.h>
#endif
").

:- pragma foreign_proc("C",
    getpid = (Pid::out),
    [will_not_call_mercury, promise_pure],
"
#ifdef  MR_DEEP_PROFILER_ENABLED
    Pid = getpid();
#else
    MR_fatal_error(""the deep profiler is not supported"");
#endif
").

%-----------------------------------------------------------------------------%
:- end_module conf.
%-----------------------------------------------------------------------------%
