% A test of the pragma(inline, ...) declarations.

:- module pragma_inline.

:- interface.

:- import_module io, string.

:- pred main(io__state::di, io__state::uo) is det.

:- implementation.

main -->
	{ L = "l"},
	{ append_strings(L, L, LL) },
	{ string__append_list(["He", LL, "o, world\n"], String) },
	c_write_string(String).

:- pragma(c_header_code, "#include <stdio.h>").

:- pred c_write_string(string::in, io__state::di, io__state::uo) is det.

:- pragma(c_code, c_write_string(Message::in, IO0::di, IO::uo),
will_not_call_mercury, "
        printf(""%s"", Message);
        IO = IO0;
").

:- pragma(inline, c_write_string/3).

:- pred append_strings(string::in, string::in, string::out) is det.
:- pragma inline(append_strings/3).
:- pragma c_code(append_strings(S1::in, S2::in, S3::out),
will_not_call_mercury, "{
        size_t len_1, len_2;
	Word tmp;
	len_1 = strlen(S1);
	len_2 = strlen(S2);
	incr_hp_atomic(tmp, (len_1 + len_2 + sizeof(Word)) / sizeof(Word));
	S3 = (char *) tmp;
	strcpy(S3, S1);
	strcpy(S3 + len_1, S2);
}").

