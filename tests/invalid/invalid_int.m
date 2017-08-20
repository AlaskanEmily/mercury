%---------------------------------------------------------------------------%
% vim: ts=4 sw=4 et ft=mercury
%---------------------------------------------------------------------------%

:- module invalid_int.
:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

main(!IO) :-
    X = {
        0b11111111111111111111111111111111,
        0b100000000000000000000000000000000,
        0b1111111111111111111111111111111111111111111111111111111111111111,
        0b10000000000000000000000000000000000000000000000000000000000000000,

        0o37777777777,
        0o40000000000,
        0o1777777777777777777777,
        0o2000000000000000000000,

        0xffffffff,
        0x100000000,
        0x110000000,
        0xffffffffffffffff,
        0x10000000000000000,

        2147483647,
        2147483648,
        9223372036854775807,
        9223372036854775808
    },
    io.write(X, !IO),

    I8 = {
        -129_i8,
        -128_i8,
         127_i8,
         128_i8
    },
    io.write(I8, !IO),

    U8 = {
        256_u8,
        257_u8
    },
    io.write(U8, !IO),

    I16 = {
        -32_769_i16,
        -32_768_i16,
         32_767_i16,
         32_768_i16
    },
    io.write(I16, !IO),

    U16 = {
         65_535_u16,
         65_536_u16
    },
    io.write(U16, !IO),

    I32 = {
        -2_147_483_649_i32,
        -2_147_483_648_i32,
         2_147_483_647_i32,
         2_147_483_648_i32
    },
    io.write(I32, !IO),

    U32 = {
         4_294_967_295_u32,
         4_294_967_296_u32
    },
    io.write(U32, !IO).
