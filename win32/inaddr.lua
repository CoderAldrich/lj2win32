local ffi = require("ffi")
local intsafe = require("win32.intsafe")

-- Basic socket definitions
--[[
 s_addr  S_un.S_addr /* can be used for most tcp & ip code */
 s_host  S_un.S_un_b.s_b2    // host on imp
 s_net   S_un.S_un_b.s_b1    // network
 s_imp   S_un.S_un_w.s_w2    // imp
 s_impno S_un.S_un_b.s_b4    // imp #
 s_lh    S_un.S_un_b.s_b3    // logical host
--]]

ffi.cdef[[
typedef struct in_addr {
    union {
        struct {
            UCHAR s_b1,s_b2,s_b3,s_b4;
            } S_un_b;
        struct {
            USHORT s_w1,s_w2;
        } S_un_w;
        ULONG S_addr;
    };
} IN_ADDR, *PIN_ADDR, *LPIN_ADDR;
]]