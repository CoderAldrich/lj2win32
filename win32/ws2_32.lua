-- ws2_32.dll	

local ffi = require("ffi");
local bit = require "bit"
local lshift = bit.lshift
local rshift = bit.rshift
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot
local bswap = bit.bswap


--local basetsd = require("basetsd")
local WTypes = require("win32.wtypes");
local WinBase = require("win32.winbase");


ffi.cdef[[
typedef uint8_t     u_char;
typedef uint16_t    u_short;
typedef uint32_t    u_int;
typedef unsigned long   u_long;
typedef uint64_t    u_int64;

typedef UINT_PTR        SOCKET;
]]

-- SOCKET poses an interesting case.  INVALID_SOCKET
-- is defined as (SOCKET)~0 in the windows headers.
-- SOCKET_ERROR == -1
-- On a twos complement machine, these should be the same,
-- so which one to use for LuaJIT?
-- words on the definition of INVALID_SOCKET
-- http://stackoverflow.com/questions/10817252/why-is-invalid-socket-defined-as-0-in-winsock2-h-c

ffi.cdef[[
//SOCKET INVALID_SOCKET  = (SOCKET)(~0);
//SOCKET INVALID_SOCKET  = (SOCKET)-1;
]]

INVALID_SOCKET          = ffi.new("SOCKET", -1);
--INVALID_SOCKET          = ffi.new("SOCKET", bnot(0));
SOCKET_ERROR            = -1;

ffi.cdef[[
typedef uint16_t    ADDRESS_FAMILY;

typedef unsigned int GROUP;

]]

ffi.cdef[[
static const int INADDR_ANY             = 0x00000000;
static const int INADDR_LOOPBACK        = 0x7f000001;
static const int INADDR_BROADCAST       = 0xffffffff;
static const int INADDR_NONE            = 0xffffffff;

static const int INET_ADDRSTRLEN         = 16;
static const int INET6_ADDRSTRLEN        = 46;
]]

ffi.cdef[[
// Socket Types
static const int SOCK_STREAM     = 1;    // stream socket
static const int SOCK_DGRAM      = 2;    // datagram socket
static const int SOCK_RAW        = 3;    // raw-protocol interface
static const int SOCK_RDM        = 4;    // reliably-delivered message
static const int SOCK_SEQPACKET  = 5;    // sequenced packet stream
]]

ffi.cdef[[
// Address families
static const int AF_UNSPEC       = 0;          // unspecified 
static const int AF_UNIX         = 1;            // local to host (pipes, portals) 
static const int AF_INET         = 2;            // internetwork: UDP, TCP, etc. 
static const int AF_IMPLINK      = 3;         // arpanet imp addresses 
static const int AF_PUP          = 4;            // pup protocols: e.g. BSP 
static const int AF_CHAOS        = 5;           // mit CHAOS protocols 
static const int AF_IPX          = 6;             // IPX and SPX 
static const int AF_NS           = 6;              // XEROX NS protocols 
static const int AF_ISO          = 7;             // ISO protocols 
static const int AF_OSI          = AF_ISO;        // OSI is ISO 
static const int AF_ECMA         = 8;            // european computer manufacturers 
static const int AF_DATAKIT      = 9;         // datakit protocols 
static const int AF_CCITT        = 10;          // CCITT protocols, X.25 etc 
static const int AF_SNA          = 11;           // IBM SNA 
static const int AF_DECnet       = 12;         // DECnet 
static const int AF_DLI          = 13;            // Direct data link interface 
static const int AF_LAT          = 14;            // LAT 
static const int AF_HYLINK       = 15;         // NSC Hyperchannel 
static const int AF_APPLETALK    = 16;      // AppleTalk 
static const int AF_NETBIOS      = 17;        // NetBios-style addresses 
static const int AF_VOICEVIEW    = 18;     // VoiceView 
static const int AF_FIREFOX      = 19;        // FireFox 
static const int AF_UNKNOWN1     = 20;       // Somebody is using this! 
static const int AF_BAN          = 21;            // Banyan 
static const int AF_INET6        = 23;              // Internetwork Version 6
static const int AF_IRDA         = 26;              // IrDA
static const int AF_NETDES       = 28;       // Network Designers OSI & gateway


static const int AF_TCNPROCESS   = 29;
static const int AF_TCNMESSAGE   = 30;
static const int AF_ICLFXBM      = 31;

static const int AF_BTH  = 32;              // Bluetooth RFCOMM/L2CAP protocols
static const int AF_LINK = 33;
static const int AF_MAX  = 34;
]]

ffi.cdef[[
//
// Protocols
//
static const int IPPROTO_IP          = 0;        // dummy for IP
static const int IPPROTO_ICMP        = 1;        // control message protocol
static const int IPPROTO_IGMP        = 2;        // group management protocol
static const int IPPROTO_GGP         = 3;        // gateway^2 (deprecated)
static const int IPPROTO_TCP         = 6;        // tcp
static const int IPPROTO_PUP         = 12;       // pup
static const int IPPROTO_UDP         = 17;       // user datagram protocol
static const int IPPROTO_IDP         = 22;       // xns idp
static const int IPPROTO_RDP         = 27;
static const int IPPROTO_IPV6        = 41;       // IPv6 header
static const int IPPROTO_ROUTING     = 43;       // IPv6 Routing header
static const int IPPROTO_FRAGMENT    = 44;       // IPv6 fragmentation header
static const int IPPROTO_ESP         = 50;       // encapsulating security payload
static const int IPPROTO_AH          = 51;       // authentication header
static const int IPPROTO_ICMPV6      = 58;       // ICMPv6
static const int IPPROTO_NONE        = 59;       // IPv6 no next header
static const int IPPROTO_DSTOPTS     = 60;       // IPv6 Destination options
static const int IPPROTO_ND          = 77;       // UNOFFICIAL net disk proto
static const int IPPROTO_ICLFXBM     = 78;
static const int IPPROTO_PIM         = 103;
static const int IPPROTO_PGM         = 113;
static const int IPPROTO_RM          = IPPROTO_PGM;
static const int IPPROTO_L2TP        = 115;
static const int IPPROTO_SCTP        = 132;


static const int IPPROTO_RAW          =   255;             // raw IP packet
static const int IPPROTO_MAX          =   256;

//
//  These are reserved for internal use by Windows.
//
static const int IPPROTO_RESERVED_RAW = 257;
static const int IPPROTO_RESERVED_IPSEC = 258;
static const int IPPROTO_RESERVED_IPSECOFFLOAD = 259;
static const int IPPROTO_RESERVED_MAX = 260;
]]

ffi.cdef[[
//
// Options for use with [gs]etsockopt at the IP level.
//

static const int IP_OPTIONS         = 1;           // set/get IP per-packet options
static const int IP_MULTICAST_IF    = 2;           // set/get IP multicast interface
static const int IP_MULTICAST_TTL   = 3;           // set/get IP multicast timetolive
static const int IP_MULTICAST_LOOP  = 4;           // set/get IP multicast loopback
static const int IP_ADD_MEMBERSHIP  = 5;           // add  an IP group membership
static const int IP_DROP_MEMBERSHIP = 6;           // drop an IP group membership
static const int IP_TTL             = 7;           // set/get IP Time To Live
static const int IP_TOS             = 8;           // set/get IP Type Of Service
static const int IP_DONTFRAGMENT    = 9;           // set/get IP Don't Fragment flag
]]

ffi.cdef[[
// Error Codes
static const int WSA_IO_INCOMPLETE   = 996;
static const int WSA_IO_PENDING  = 997;
static const int WSAEFAULT       = 10014;
static const int WSAEINVAL       = 10022;
static const int WSAEWOULDBLOCK  = 10035;
static const int WSAEINPROGRES   = 10036;
static const int WSAEALREADY     = 10037;
static const int WSAENOTSOCK     = 10038;
static const int WSAEAFNOSUPPORT = 10047;
static const int WSAECONNABORTED = 10053;
static const int WSAECONNRESET   = 10054;
static const int WSAENOBUFS      = 10055;
static const int WSAEISCONN      = 10056;
static const int WSAENOTCONN     = 10057;
static const int WSAESHUTDOWN    = 10058;
static const int WSAETOOMANYREFS = 10059;
static const int WSAETIMEDOUT    = 10060;
static const int WSAECONNREFUSED = 10061;

static const int WSASYSNOTREADY     = 10091;
static const int WSAVERNOTSUPPORTED = 10092;
static const int WSANOTINITIALISED  = 10093;


static const int WSAHOST_NOT_FOUND = 11001;
]]

local families = {
    [tonumber(ffi.C.AF_INET)] = "AF_INET",
    [tonumber(ffi.C.AF_INET6)] = "AF_INET6",
    [tonumber(ffi.C.AF_BTH)] = "AF_BTH",
}

local socktypes = {
    [ffi.C.SOCK_STREAM] = "SOCK_STREAM",
    [ffi.C.SOCK_DGRAM] = "SOCK_DGRAM",
}


local protocols = {
    [tonumber(ffi.C.IPPROTO_IP)]    = "IPPROTO_IP",
    [tonumber(ffi.C.IPPROTO_ICMP)]  = "IPPROTO_ICMP",
    [tonumber(ffi.C.IPPROTO_IGMP)]  = "IPPROTO_IGMP",
    [tonumber(ffi.C.IPPROTO_GGP)]   = "IPPROTO_GGP",
    [tonumber(ffi.C.IPPROTO_TCP)]   = "IPPROTO_TCP",
    [tonumber(ffi.C.IPPROTO_PUP)]   = "IPPROTO_PUP",
    [tonumber(ffi.C.IPPROTO_UDP)]   = "IPPROTO_UDP",
    [tonumber(ffi.C.IPPROTO_IDP)]   = "IPPROTO_IDP",
    [tonumber(ffi.C.IPPROTO_RDP)]   = "IPPROTO_RDP",
    [tonumber(ffi.C.IPPROTO_IPV6)]  = "IPPROTO_IPV6",
    [tonumber(ffi.C.IPPROTO_ROUTING)]   = "IPPROTO_ROUTING",
    [tonumber(ffi.C.IPPROTO_FRAGMENT)]  = "IPPROTO_FRAGMENT",
    [tonumber(ffi.C.IPPROTO_ESP)]       = "IPPROTO_ESP",
    [tonumber(ffi.C.IPPROTO_AH)]        = "IPPROTO_AH",
    [tonumber(ffi.C.IPPROTO_ICMPV6)]    = "IPPROTO_ICMPV6",
    [tonumber(ffi.C.IPPROTO_NONE)]      = "IPPROTO_NONE",
    [tonumber(ffi.C.IPPROTO_DSTOPTS)]   = "IPPROTO_DSTOPTS",
    [tonumber(ffi.C.IPPROTO_ND)]        = "IPPROTO_ND",
    [tonumber(ffi.C.IPPROTO_ICLFXBM)]   = "IPPROTO_ICLFXBM",
    [tonumber(ffi.C.IPPROTO_PIM)]       = "IPPROTO_PIM",
    [tonumber(ffi.C.IPPROTO_PGM)]       = "IPPROTO_PGM",
    [tonumber(ffi.C.IPPROTO_L2TP)]      = "IPPROTO_L2TP",
    [tonumber(ffi.C.IPPROTO_SCTP)]      = "IPPROTO_SCTP",
}


--[[
/*
 * Commands for ioctlsocket(),  taken from the BSD file fcntl.h.
 *
 *
 * Ioctl's have the command encoded in the lower word,
 * and the size of any in or out parameters in the upper
 * word.  The high 2 bits of the upper word are used
 * to encode the in/out status of the parameter; for now
 * we restrict parameters to at most 128 bytes.
 */
--]]
local IOCPARM_MASK    = 0x7f            -- parameters must be < 128 bytes
local IOC_VOID        = 0x20000000      -- no parameters
local IOC_OUT         = 0x40000000      -- copy out parameters
local IOC_IN          = 0x80000000      -- copy in parameters
local IOC_INOUT       = bor(IOC_IN,IOC_OUT)

-- 0x20000000 distinguishes new and
-- old ioctl's
local function _IO(x,y)
    return bor(IOC_VOID, lshift(x,8), y)
end

local function _IOR(x,y,t)
    return bor(IOC_OUT, lshift(band(ffi.sizeof(t),IOCPARM_MASK), 16), lshift(x,8), y)
end

local function _IOW(x,y,t)
    return bor(IOC_IN, lshift(band(ffi.sizeof(t),IOCPARM_MASK),16), lshift(x,8), y)
end

FIONREAD    = _IOR(string.byte'f', 127, "uint32_t") -- get # bytes to read
FIONBIO     = _IOW(string.byte'f', 126, "uint32_t") -- set/clear non-blocking i/o
FIOASYNC    = _IOW(string.byte'f', 125, "uint32_t") -- set/clear async i/o




--[[
    WinSock 2 extension -- manifest constants for WSAIoctl()
    From ws2def.h
--]]
local IOC_UNIX        = 0x00000000;
local IOC_WS2         = 0x08000000;
local IOC_PROTOCOL    = 0x10000000;
local IOC_VENDOR      = 0x18000000;

local function _WSAIO(x,y)                   
    return bor(IOC_VOID, x, y)
end

local function _WSAIOR(x,y)                  
    return bor(IOC_OUT, x,y)
end

local function _WSAIOW(x,y)
    return bor(IOC_IN,x,y)
end

local function _WSAIORW(x,y) 
    return  bor(IOC_INOUT,x,y)
end


SIO_ASSOCIATE_HANDLE         =  _WSAIOW(IOC_WS2,1);
SIO_ENABLE_CIRCULAR_QUEUEING  = _WSAIO(IOC_WS2,2);
SIO_FIND_ROUTE                = _WSAIOR(IOC_WS2,3);
SIO_FLUSH                     = _WSAIO(IOC_WS2,4);
SIO_GET_BROADCAST_ADDRESS     = _WSAIOR(IOC_WS2,5);
SIO_GET_EXTENSION_FUNCTION_POINTER = _WSAIORW(IOC_WS2,6);
SIO_GET_QOS                   = _WSAIORW(IOC_WS2,7);
SIO_GET_GROUP_QOS             = _WSAIORW(IOC_WS2,8);
SIO_MULTIPOINT_LOOPBACK       = _WSAIOW(IOC_WS2,9);
SIO_MULTICAST_SCOPE           = _WSAIOW(IOC_WS2,10);
SIO_SET_QOS                   = _WSAIOW(IOC_WS2,11);
SIO_SET_GROUP_QOS             = _WSAIOW(IOC_WS2,12);
SIO_TRANSLATE_HANDLE          = _WSAIORW(IOC_WS2,13);
SIO_ROUTING_INTERFACE_QUERY   = _WSAIORW(IOC_WS2,20);
SIO_ROUTING_INTERFACE_CHANGE  = _WSAIOW(IOC_WS2,21);
SIO_ADDRESS_LIST_QUERY        = _WSAIOR(IOC_WS2,22);
SIO_ADDRESS_LIST_CHANGE       = _WSAIO(IOC_WS2,23);
SIO_QUERY_TARGET_PNP_HANDLE   = _WSAIOR(IOC_WS2,24);


--
-- New WSAIoctl Options
--
SIO_RCVALL           = _WSAIOW(IOC_VENDOR,1);
local SIO_RCVALL_MCAST     = _WSAIOW(IOC_VENDOR,2);
local SIO_RCVALL_IGMPMCAST = _WSAIOW(IOC_VENDOR,3);
SIO_KEEPALIVE_VALS   = _WSAIOW(IOC_VENDOR,4);
local SIO_ABSORB_RTRALERT  = _WSAIOW(IOC_VENDOR,5);
local SIO_UCAST_IF         = _WSAIOW(IOC_VENDOR,6);
local SIO_LIMIT_BROADCASTS = _WSAIOW(IOC_VENDOR,7);
local SIO_INDEX_BIND       = _WSAIOW(IOC_VENDOR,8);
local SIO_INDEX_MCASTIF    = _WSAIOW(IOC_VENDOR,9);
local SIO_INDEX_ADD_MCAST  = _WSAIOW(IOC_VENDOR,10);
local SIO_INDEX_DEL_MCAST  = _WSAIOW(IOC_VENDOR,11);
--      SIO_UDP_CONNRESET    = _WSAIOW(IOC_VENDOR,12);
local SIO_RCVALL_MCAST_IF  = _WSAIOW(IOC_VENDOR,13);
local SIO_RCVALL_IF        = _WSAIOW(IOC_VENDOR,14);


--
-- TCP/IP specific Ioctl codes.
--
SIO_GET_INTERFACE_LIST     = _IOR(string.byte't', 127, "uint32_t");
SIO_GET_INTERFACE_LIST_EX  = _IOR(string.byte't', 126, "uint32_t");
SIO_SET_MULTICAST_FILTER   = _IOW(string.byte't', 125, "uint32_t");
SIO_GET_MULTICAST_FILTER   = _IOW(string.byte't', bor(124, IOC_IN), "uint32_t");
SIOCSIPMSFILTER            = SIO_SET_MULTICAST_FILTER;
SIOCGIPMSFILTER            = SIO_GET_MULTICAST_FILTER;





-- Possible flags for the  iiFlags - bitmask.

IFF_UP              =0x00000001 -- Interface is up.
IFF_BROADCAST       =0x00000002 -- Broadcast is  supported.
IFF_LOOPBACK        =0x00000004 -- This is loopback interface.
IFF_POINTTOPOINT    =0x00000008 -- This is point-to-point interface.
IFF_MULTICAST       =0x00000010 -- Multicast is supported.


--
-- WinSock 2 extension -- manifest constants for WSASocket()
--
WSA_FLAG_OVERLAPPED             = 0x01;
WSA_FLAG_MULTIPOINT_C_ROOT      = 0x02;
WSA_FLAG_MULTIPOINT_C_LEAF      = 0x04;
WSA_FLAG_MULTIPOINT_D_ROOT      = 0x08;
WSA_FLAG_MULTIPOINT_D_LEAF      = 0x10;
WSA_FLAG_ACCESS_SYSTEM_SECURITY = 0x40;



--
--  Flags used in "hints" argument to getaddrinfo()
--      - AI_ADDRCONFIG is supported starting with Vista
--      - default is AI_ADDRCONFIG ON whether the flag is set or not
--        because the performance penalty in not having ADDRCONFIG in
--        the multi-protocol stack environment is severe;
--        this defaulting may be disabled by specifying the AI_ALL flag,
--        in that case AI_ADDRCONFIG must be EXPLICITLY specified to
--        enable ADDRCONFIG behavior
--


AI_PASSIVE                  =0x00000001  -- Socket address will be used in bind() call
AI_CANONNAME                =0x00000002  -- Return canonical name in first ai_canonname
AI_NUMERICHOST              =0x00000004  -- Nodename must be a numeric address string
AI_NUMERICSERV              =0x00000008  -- Servicename must be a numeric port number

AI_ALL                      =0x00000100  -- Query both IP6 and IP4 with AI_V4MAPPED
AI_ADDRCONFIG               =0x00000400  -- Resolution only if global address configured
AI_V4MAPPED                 =0x00000800  -- On v6 failure, query v4 and convert to V4MAPPED format

AI_NON_AUTHORITATIVE        =0x00004000  -- LUP_NON_AUTHORITATIVE
AI_SECURE                   =0x00008000  -- LUP_SECURE
AI_RETURN_PREFERRED_NAMES   =0x00010000  -- LUP_RETURN_PREFERRED_NAMES

AI_FQDN                     =0x00020000  -- Return the FQDN in ai_canonname
AI_FILESERVER               =0x00040000  -- Resolving fileserver name resolution


-- Flags for shutdown()
SD_RECEIVE  = 0
SD_SEND     = 1
SD_BOTH     = 2

-- for get/setsockopt, the levels can be:
-- IPPROTO_XXX - IP, IPV6, RM, TCP, UDP
-- NSPROTO_IPX
-- SOL_APPLETALK
-- SOL_IRLMP
SOL_SOCKET     = 0xffff          -- options for socket level

-- Option flags per-socket.
SO_DEBUG        = 0x0001          -- turn on debugging info recording
SO_ACCEPTCONN   = 0x0002          -- socket has had listen()
SO_REUSEADDR    = 0x0004          -- allow local address reuse
SO_KEEPALIVE    = 0x0008          -- keep connections alive
SO_DONTROUTE    = 0x0010          -- just use interface addresses
SO_BROADCAST    = 0x0020          -- permit sending of broadcast msgs
SO_USELOOPBACK  = 0x0040          -- bypass hardware when possible
SO_LINGER       = 0x0080          -- linger on close if data present
SO_OOBINLINE    = 0x0100          -- leave received OOB data in line


SO_DONTLINGER       = bnot(SO_LINGER)
SO_EXCLUSIVEADDRUSE = bnot(SO_REUSEADDR) -- disallow local address reuse


-- Additional options.

SO_SNDBUF     =  0x1001          -- send buffer size
SO_RCVBUF     =  0x1002          -- receive buffer size
SO_SNDLOWAT   =  0x1003          -- send low-water mark
SO_RCVLOWAT   =  0x1004          -- receive low-water mark
SO_SNDTIMEO   =  0x1005          -- send timeout
SO_RCVTIMEO   =  0x1006          -- receive timeout
SO_ERROR      =  0x1007          -- get error status and clear
SO_TYPE       =  0x1008          -- get socket type
SO_CONNECT_TIME = 0x700C;       -- Connection Time

--
-- TCP options.
--

TCP_NODELAY     = 0x0001
TCP_KEEPALIVE   = 0x0003
TCP_BSDURGENT   = 0x7000








ffi.cdef[[
typedef struct __WSABUF {
	u_long len;
	char * buf;
} WSABUF,  *LPWSABUF;
]]
WSABUF = ffi.typeof("WSABUF");
WSABUF_mt = {
    __new = function(ct, buf, len)
        return ffi.new(ct, len, ffi.cast("char *", buf));
    end,

    __index = {

    },
}
--
-- MSTcpIP.h
--
ffi.cdef[[
/* Argument structure for SIO_KEEPALIVE_VALS */

struct tcp_keepalive {
    ULONG onoff;
    ULONG keepalivetime;
    ULONG keepaliveinterval;
};
]]
tcp_keepalive = ffi.typeof("struct tcp_keepalive");


ffi.cdef[[
typedef OVERLAPPED	WSAOVERLAPPED;
typedef struct _OVERLAPPED *    LPWSAOVERLAPPED;

typedef void (* LPWSAOVERLAPPED_COMPLETION_ROUTINE)(
    DWORD dwError,
    DWORD cbTransferred,
    LPWSAOVERLAPPED lpOverlapped,
    DWORD dwFlags
    );
]]

ffi.cdef[[

static const int    WSADESCRIPTION_LEN =     256;
static const int    WSASYS_STATUS_LEN  =     128;
]]

if _WIN64 then
ffi.cdef[[
typedef struct WSAData {
    WORD                wVersion;
    WORD                wHighVersion;
    unsigned short      iMaxSockets;
    unsigned short      iMaxUdpDg;
    char *              lpVendorInfo;
    char                szDescription[WSADESCRIPTION_LEN+1];
    char                szSystemStatus[WSASYS_STATUS_LEN+1];
} WSADATA, *LPWSADATA;
]]
else
ffi.cdef[[
typedef struct WSAData {
        WORD                wVersion;
        WORD                wHighVersion;
        char                szDescription[WSADESCRIPTION_LEN+1];
        char                szSystemStatus[WSASYS_STATUS_LEN+1];
        unsigned short      iMaxSockets;
        unsigned short      iMaxUdpDg;
        char *				lpVendorInfo;
} WSADATA, * LPWSADATA;
]]
end

require("win32.inaddr")

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
            uint8_t s_b1,s_b2,s_b3,s_b4;
            } S_un_b;
        struct {
            uint16_t s_w1,s_w2;
        } S_un_w;
        uint32_t S_addr;
    };
} IN_ADDR, *PIN_ADDR, *LPIN_ADDR;
]]



ffi.cdef[[
typedef struct sockaddr {
    ADDRESS_FAMILY  sa_family;
    uint8_t     sa_data[14];
} SOCKADDR, *PSOCKADDR, *LPSOCKADDR;


typedef struct sockaddr_in {
    int16_t     sin_family;
    uint16_t    sin_port;
    IN_ADDR     sin_addr;
    uint8_t     sin_zero[8];
} SOCKADDR_IN, *PSOCKADDR_IN;
]]

ffi.cdef[[
//
// IPv6 Internet address (RFC 2553)
// This is an 'on-wire' format structure.
//
typedef struct in6_addr {
    union {
        uint8_t       Byte[16];
        uint16_t      Word[8];
    } u;
} IN6_ADDR;
typedef struct in6_addr *PIN6_ADDR;
typedef struct in6_addr *LPIN6_ADDR;

typedef struct sockaddr_in6 {
        int16_t             sin6_family;
        uint16_t                sin6_port;
        uint32_t                sin6_flowinfo;
        struct  in6_addr    sin6_addr;
        uint32_t            sin6_scope_id;
} sockaddr_in6;

typedef struct sockaddr_in6 SOCKADDR_IN6;
typedef struct sockaddr_in6 *PSOCKADDR_IN6;
typedef struct sockaddr_in6 *LPSOCKADDR_IN6;
]]

ffi.cdef[[
//
// Old IPv6 socket address structure (retained for sockaddr_gen definition).
//

struct sockaddr_in6_old {
    int16_t sin6_family;          // AF_INET6.
    uint16_t sin6_port;           // Transport level port number.
    ULONG sin6_flowinfo;        // IPv6 flow information.
    IN6_ADDR sin6_addr;         // IPv6 address.
};

typedef union sockaddr_gen {
    struct sockaddr Address;
    struct sockaddr_in AddressIn;
    struct sockaddr_in6_old AddressIn6;
} sockaddr_gen;

]]


ffi.cdef[[
//
// Portable socket structure (RFC 2553).
//

//
// Desired design of maximum size and alignment.
// These are implementation specific.
//
static const int _SS_MAXSIZE = 128;                 // Maximum size
static const int _SS_ALIGNSIZE =(sizeof(__int64)); // Desired alignment

//
// Definitions used for sockaddr_storage structure paddings design.
//

static const int _SS_PAD1SIZE = (_SS_ALIGNSIZE - sizeof(USHORT));
static const int _SS_PAD2SIZE = (_SS_MAXSIZE - (sizeof(USHORT) + _SS_PAD1SIZE + _SS_ALIGNSIZE));

typedef struct sockaddr_storage {
    ADDRESS_FAMILY ss_family;      // address family

    CHAR __ss_pad1[_SS_PAD1SIZE];  // 6 byte pad, this is to make
                                   //   implementation specific pad up to
                                   //   alignment field that follows explicit
                                   //   in the data structure
    __int64 __ss_align;            // Field to force desired structure
    CHAR __ss_pad2[_SS_PAD2SIZE];  // 112 byte pad to achieve desired size;
                                   //   _SS_MAXSIZE value minus size of
                                   //   ss_family, __ss_pad1, and
                                   //   __ss_align fields is 112
} SOCKADDR_STORAGE_LH, *PSOCKADDR_STORAGE_LH, *LPSOCKADDR_STORAGE_LH;

typedef struct sockaddr_storage_xp {
    short ss_family;               // Address family.

    CHAR __ss_pad1[_SS_PAD1SIZE];  // 6 byte pad, this is to make
                                   //   implementation specific pad up to
                                   //   alignment field that follows explicit
                                   //   in the data structure
    __int64 __ss_align;            // Field to force desired structure
    CHAR __ss_pad2[_SS_PAD2SIZE];  // 112 byte pad to achieve desired size;
                                   //   _SS_MAXSIZE value minus size of
                                   //   ss_family, __ss_pad1, and
                                   //   __ss_align fields is 112
} SOCKADDR_STORAGE_XP, *PSOCKADDR_STORAGE_XP, *LPSOCKADDR_STORAGE_XP;
]]

ffi.cdef[[
typedef SOCKADDR_STORAGE_LH SOCKADDR_STORAGE;
typedef SOCKADDR_STORAGE *PSOCKADDR_STORAGE, *LPSOCKADDR_STORAGE;
]]




ffi.cdef[[
typedef struct addrinfo {
    int ai_flags;
    int ai_family;
    int ai_socktype;
    int ai_protocol;
    size_t ai_addrlen;
    char* ai_canonname;
    struct sockaddr * ai_addr;
    struct addrinfo* ai_next;
} ADDRINFOA,  *PADDRINFOA;
]]


addrinfo = ffi.typeof("struct addrinfo");
addrinfo_mt = {
    __gc = function(self)
        --print("GC: addrinfo")
        -- BUGBUG
        -- The following freeaddrinfo seems to crash
        -- probably because we're freeing ourself
        --Lib.freeaddrinfo(ffi.cast("struct addrinfo *",self));
    end,

    __tostring = function(self)
        local family = families[self.ai_family]
        local socktype = socktypes[self.ai_socktype]
        local protocol = protocols[self.ai_protocol]

        --local family = self.ai_family
        local socktype = self.ai_socktype
        local protocol = self.ai_protocol


        local str = string.format("Socket Type: %s, Protocol: %s, %s", socktype, protocol, tostring(self.ai_addr));

        return str
    end,

    __index = {
        addresses = function(self)
            local addr = self;

            local closure = function()
                if addr == self then
                    addr = addr.ai_next;
                    return self;
                end
                
                if addr == nil then
                    return nil;
                end

                local current = addr;
                addr = addr.ai_next;
                return current; 
            end

            return closure
        end,


    },
}
ffi.metatype(addrinfo, addrinfo_mt)


ffi.cdef[[
typedef struct hostent {
    char * h_name;
    char ** h_aliases;
    short h_addrtype;
    short h_length;
    char ** h_addr_list;
} HOSTENT,  *PHOSTENT,  *LPHOSTENT;
]]



ffi.cdef[[
static const int MAX_PROTOCOL_CHAIN = 7;
static const int WSAPROTOCOL_LEN  = 255;
static const int BASE_PROTOCOL      = 1;
static const int LAYERED_PROTOCOL   = 0;



typedef struct _WSAPROTOCOLCHAIN {
    int ChainLen;
    DWORD ChainEntries[MAX_PROTOCOL_CHAIN];
} WSAPROTOCOLCHAIN,  *LPWSAPROTOCOLCHAIN;


typedef struct _WSAPROTOCOL_INFOA {
    DWORD dwServiceFlags1;
    DWORD dwServiceFlags2;
    DWORD dwServiceFlags3;
    DWORD dwServiceFlags4;
    DWORD dwProviderFlags;
    GUID ProviderId;
    DWORD dwCatalogEntryId;
    WSAPROTOCOLCHAIN ProtocolChain;
    int iVersion;
    int iAddressFamily;
    int iMaxSockAddr;
    int iMinSockAddr;
    int iSocketType;
    int iProtocol;
    int iProtocolMaxOffset;
    int iNetworkByteOrder;
    int iSecurityScheme;
    DWORD dwMessageSize;
    DWORD dwProviderReserved;
    CHAR   szProtocol[WSAPROTOCOL_LEN+1];
} WSAPROTOCOL_INFOA,  *LPWSAPROTOCOL_INFOA;

typedef struct _WSAPROTOCOL_INFOW {
    DWORD dwServiceFlags1;
    DWORD dwServiceFlags2;
    DWORD dwServiceFlags3;
    DWORD dwServiceFlags4;
    DWORD dwProviderFlags;
    GUID ProviderId;
    DWORD dwCatalogEntryId;
    WSAPROTOCOLCHAIN ProtocolChain;
    int iVersion;
    int iAddressFamily;
    int iMaxSockAddr;
    int iMinSockAddr;
    int iSocketType;
    int iProtocol;
    int iProtocolMaxOffset;
    int iNetworkByteOrder;
    int iSecurityScheme;
    DWORD dwMessageSize;
    DWORD dwProviderReserved;
    WCHAR  szProtocol[WSAPROTOCOL_LEN+1];
} WSAPROTOCOL_INFOW, * LPWSAPROTOCOL_INFOW;

]]

ffi.cdef[[
static const int    FD_SETSIZE = 64;

typedef struct fd_set {
    u_int fd_count;               /* how many are SET? */
    SOCKET  fd_array[FD_SETSIZE];   /* an array of SOCKETs */
} fd_set;

struct timeval {
    long    tv_sec;         /* seconds */
    long    tv_usec;        /* and microseconds */
};

/*
 * Structure used for manipulating linger option.
 */
struct  linger {
    u_short l_onoff;                /* option on/off */
    u_short l_linger;               /* linger time */
};
]]




-- Berkeley Sockets interface
ffi.cdef[[
SOCKET accept(SOCKET s,struct sockaddr* addr,int* addrlen);

int bind(SOCKET s, const struct sockaddr* name, int namelen);

int closesocket(SOCKET s);

int connect(SOCKET s, const struct sockaddr * name, int namelen);

void freeaddrinfo(PADDRINFOA pAddrInfo);

int getaddrinfo(const char* nodename,const char* servname,const struct addrinfo* hints,PADDRINFOA * res);

struct hostent* gethostbyaddr(const char* addr,int len,int type);

struct hostent* gethostbyname(const char* name);

int gethostname(char* name, int namelen);

int getsockname(SOCKET s, struct sockaddr* name, int* namelen);

int getsockopt(SOCKET s, int level, int optname, char* optval,int* optlen);

u_long  htonl(u_long hostlong);

u_short htons(u_short hostshort);

unsigned long inet_addr(const char* cp);

char* inet_ntoa(struct   in_addr in);

int inet_pton(int Family, const char * szAddrString, const void * pAddrBuf);

const char * inet_ntop(int Family, const void *pAddr, intptr_t strptr, size_t len);

int ioctlsocket(SOCKET s, long cmd, u_long* argp);

int listen(SOCKET s, int backlog);

u_short ntohs(u_short netshort);

u_long  ntohl(u_long netlong);

int recv(SOCKET s, char* buf, int len, int flags);

int recvfrom(SOCKET s, char* buf, int len, int flags, struct sockaddr* from, int* fromlen);

int select(int nfds, fd_set* readfds, fd_set* writefds, fd_set* exceptfds, const struct timeval* timeout);

int send(SOCKET s, const char* buf, int len, int flags);

int sendto(SOCKET s, const char* buf, int len, int flags, const struct sockaddr* to, int tolen);

int setsockopt(SOCKET s, int level, int optname, const char* optval, int optlen);

int shutdown(SOCKET s, int how);

SOCKET socket(int af, int type, int protocol);

]]

ffi.cdef[[
typedef struct addrinfoexA
{
    int                 ai_flags;       // AI_PASSIVE, AI_CANONNAME, AI_NUMERICHOST
    int                 ai_family;      // PF_xxx
    int                 ai_socktype;    // SOCK_xxx
    int                 ai_protocol;    // 0 or IPPROTO_xxx for IPv4 and IPv6
    size_t              ai_addrlen;     // Length of ai_addr
    char               *ai_canonname;   // Canonical name for nodename
    struct sockaddr    *ai_addr;        // Binary address
    void               *ai_blob;
    size_t              ai_bloblen;
    LPGUID              ai_provider;
    struct addrinfoexA *ai_next;        // Next structure in linked list
} ADDRINFOEXA, *PADDRINFOEXA, *LPADDRINFOEXA;
]]

ffi.cdef[[
typedef void ( * LPLOOKUPSERVICE_COMPLETION_ROUTINE)(
    DWORD    dwError,
    DWORD    dwBytes,
    LPWSAOVERLAPPED lpOverlapped);

INT
GetAddrInfoExA(
    PCSTR           pName,
    PCSTR           pServiceName,
    DWORD           dwNameSpace,
    LPGUID          lpNspId,
    const ADDRINFOEXA *hints,
    PADDRINFOEXA *  ppResult,
    struct timeval *timeout,
    LPOVERLAPPED    lpOverlapped,
    LPLOOKUPSERVICE_COMPLETION_ROUTINE  lpCompletionRoutine,
    LPHANDLE        lpNameHandle);

]]

-- Windows Specific Networking API
ffi.cdef[[
typedef DWORD       WSAEVENT, *LPWSAEVENT;
typedef HANDLE      WSAEVENT;
typedef LPHANDLE    LPWSAEVENT;
]]

ffi.cdef[[
typedef struct pollfd {
    SOCKET      fd;
    int16_t     events;
    int16_t     revents;
} WSAPOLLFD, *PWSAPOLLFD, *LPWSAPOLLFD;

]]

-- Event flag definitions for WSAPoll().

POLLRDNORM  = 0x0100;
POLLRDBAND  = 0x0200;
POLLIN      = bor(POLLRDNORM, POLLRDBAND);
POLLPRI     = 0x0400;

POLLWRNORM  = 0x0010;
POLLOUT     = POLLWRNORM;
POLLWRBAND  = 0x0020;

POLLERR     = 0x0001;
POLLHUP     = 0x0002;
POLLNVAL    = 0x0004;

WSAPOLLFD = ffi.typeof("WSAPOLLFD")


ffi.cdef[[
/*
 * WSAMSG -- for WSASendMsg
 */
typedef struct _WSAMSG {
    LPSOCKADDR       name;
    INT              namelen;
    LPWSABUF         lpBuffers;
    ULONG            dwBufferCount;
    WSABUF           Control;
    ULONG            dwFlags;
} WSAMSG, *PWSAMSG, * LPWSAMSG;
]]

ffi.cdef[[
//
// Structure to keep interface specific information
//

typedef struct _INTERFACE_INFO {
    ULONG iiFlags;              // Interface flags.
    sockaddr_gen iiAddress;     // Interface address.
    sockaddr_gen iiBroadcastAddress; // Broadcast address.
    sockaddr_gen iiNetmask;     // Network mask.
} INTERFACE_INFO, *LPINTERFACE_INFO;
]]


ffi.cdef[[
int __WSAFDIsSet(SOCKET fd, fd_set *);

INT WSAAddressToStringA(LPSOCKADDR lpsaAddress,
    DWORD dwAddressLength,
    LPWSAPROTOCOL_INFOA lpProtocolInfo,
    LPSTR lpszAddressString,
    LPDWORD lpdwAddressStringLength);

int WSAGetLastError();

int WSAIoctl(
    SOCKET s,
    DWORD dwIoControlCode,
    LPVOID lpvInBuffer,
    DWORD cbInBuffer,
    LPVOID lpvOutBuffer,
    DWORD cbOutBuffer,
    LPDWORD lpcbBytesReturned,
    LPWSAOVERLAPPED lpOverlapped,
    LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine
);

int WSAEnumProtocolsA(
    LPINT lpiProtocols,
    LPWSAPROTOCOL_INFOA lpProtocolBuffer,
    LPDWORD lpdwBufferLength);

BOOL
WSAGetOverlappedResult(
    SOCKET s,
    LPWSAOVERLAPPED lpOverlapped,
    LPDWORD lpcbTransfer,
    BOOL fWait,
    LPDWORD lpdwFlags);

int WSAPoll(
    LPWSAPOLLFD fdArray, 
    ULONG fds, 
    INT timeout);

/*
// Commented, because we won't want the 
// callback function to be in here.
int WSARecv(
    SOCKET s,
    LPWSABUF lpBuffers,
    DWORD dwBufferCount,
    LPDWORD lpNumberOfBytesRecvd,
    LPDWORD lpFlags,
    LPWSAOVERLAPPED lpOverlapped,
    LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine);
*/

int WSARecv(
    SOCKET s,
    LPWSABUF lpBuffers,
    DWORD dwBufferCount,
    LPDWORD lpNumberOfBytesRecvd,
    LPDWORD lpFlags,
    LPWSAOVERLAPPED lpOverlapped,
    void* lpCompletionRoutine);

int
WSARecvFrom(
    SOCKET s,
    LPWSABUF lpBuffers,
    DWORD dwBufferCount,
    LPDWORD lpNumberOfBytesRecvd,
    LPDWORD lpFlags,
    struct sockaddr * lpFrom,
    LPINT lpFromlen,
    LPWSAOVERLAPPED lpOverlapped,
    LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine);


int WSASend(SOCKET s, 
	LPWSABUF lpBuffers, 
	DWORD dwBufferCount,
    LPDWORD lpNumberOfBytesSent, 
    DWORD dwFlags,
    LPWSAOVERLAPPED lpOverlapped,
	LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine);

int WSASendDisconnect(SOCKET s, LPWSABUF lpOutboundDisconnectData);

int WSASendMsg(SOCKET Handle, 
    LPWSAMSG lpMsg, 
    DWORD dwFlags,
    LPDWORD lpNumberOfBytesSent, 
    LPWSAOVERLAPPED lpOverlapped,
    LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine);

int WSASendTo(SOCKET s,
    LPWSABUF lpBuffers,
    DWORD dwBufferCount,
    LPDWORD lpNumberOfBytesSent,
    DWORD dwFlags,
    const struct sockaddr * lpTo,
    int iTolen,
    LPWSAOVERLAPPED lpOverlapped,
    LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine);

BOOL WSASetEvent(WSAEVENT hEvent);

SOCKET WSASocketA(
    int af, 
    int type, 
    int protocol, 
    LPWSAPROTOCOL_INFOA lpProtocolInfo,
    GROUP g, 
    DWORD dwFlags);

int WSAStartup(WORD wVersionRequested, LPWSADATA lpWSAData);

]]

--[[
    Definition of some structures
--]]

IN_ADDR = ffi.typeof("struct in_addr");
IN_ADDR_mt = {
    __tostring = function(self)
        local res = Lib.inet_ntoa(self)
        if res then
            return ffi.string(res)
        end

        return nil
    end,

    __index = {
        Assign = function(self, rhs)
            self.S_addr = rhs.S_addr
            return self
        end,

        Clone = function(self)
            local obj = IN_ADDR(self.S_addr)
            return obj
        end,

    },
}
ffi.metatype(IN_ADDR, IN_ADDR_mt)




sockaddr_in = ffi.typeof("struct sockaddr_in")
sockaddr_in_mt = {

    __new = function(ct, port, family)
        port = tonumber(port) or 80
        family = family or AF_INET;
        
        local obj = ffi.new(ct)
        obj.sin_family = family;
        obj.sin_addr.S_addr = Lib.htonl(INADDR_ANY);
        obj.sin_port = Lib.htons(port);
        
        return obj
    end,
  
    __tostring = function(self)
        return string.format("Family: %s  Port: %d Address: %s",
            families[self.sin_family], Lib.ntohs(self.sin_port), tostring(self.sin_addr));
    end,

    __index = {
        SetPort = function(self, port)
            local portnum = tonumber(port);
            if not portnum then 
                return nil, "not a number"
            end
            
            self.sin_port = Lib.htons(tonumber(port));
        end,
    },
}
ffi.metatype(sockaddr_in, sockaddr_in_mt);



sockaddr_in6 = ffi.typeof("struct sockaddr_in6")
sockaddr_in6_mt = {

    __tostring = function(self)
        return string.format("Family: %s  Port: %d Address: %s",
            families[self.sin6_family], self.sin6_port, tostring(self.sin6_addr));
    end,

    __index = {
        SetPort = function(self, port)
            local portnum = tonumber(port);
            self.sin6_port = Lib.htons(portnum);
        end,
    },
}
ffi.metatype(sockaddr_in6, sockaddr_in6_mt);


sockaddr = ffi.typeof("struct sockaddr")
sockaddr_mt = {
    __index = {
    }
}
ffi.metatype(sockaddr, sockaddr_mt);




local Lib = ffi.load("ws2_32");


return {
    Lib = Lib, 
    
    families = families,
    socktypes = socktypes,
    protocols = protocols,

    SIO_RCVALL = SIO_RCVALL,
    
    __WSAFDIsSet = Lib.__WSAFDIsSet,

    accept = Lib.accept,
    bind = Lib.bind,
    closesocket = Lib.closesocket,
    connect = Lib.connect,

    freeaddrinfo = Lib.freeaddrinfo,

--[[
FreeAddrInfoEx = Lib.
FreeAddrInfoExW = Lib.
FreeAddrInfoW = Lib.
--]]

    getaddrinfo = Lib.getaddrinfo,

--[[
GetAddrInfoExA = Lib.
GetAddrInfoExCancel = Lib.
GetAddrInfoExOverlappedResult = Lib.
GetAddrInfoExW = Lib.
GetAddrInfoW = Lib.
--]]

    gethostbyaddr = Lib.gethostbyaddr,
    gethostbyname = Lib.gethostbyname,


    gethostname = Lib.gethostname,

--[[
GetHostNameW = Lib.
getnameinfo = Lib.
GetNameInfoW = Lib.
getpeername = Lib.
getprotobyname = Lib.
getprotobynumber = Lib.
getservbyname = Lib.
getservbyport = Lib.
--]]

    getsockname = Lib.getsockname,
    getsockopt = Lib.getsockopt,
    htonl = Lib.htonl,
    htons = Lib.htons,
    inet_addr = Lib.inet_addr,
    inet_ntoa = Lib.inet_ntoa,
    inet_ntop = Lib.inet_ntop,
    inet_pton = Lib.inet_pton,

--[[
InetNtopW = Lib.
InetPtonW = Lib.
--]]

    ioctlsocket = Lib.ioctlsocket,
    listen = Lib.listen,
    ntohl = Lib.ntohl,
    ntohs = Lib.ntohs,
    recv = Lib.recv,
    recvfrom = Lib.recvfrom,
    ["select"] = Lib.select,
    send = Lib.send,
    sendto = Lib.sendto,

--[[
SetAddrInfoExA = Lib.SetAddrInfoExA
SetAddrInfoExW = Lib.SetAddrInfoExW
--]]

    setsockopt = Lib.setsockopt,
    shutdown = Lib.shutdown,
    socket = Lib.socket,

--[[
WahCloseApcHelper = Lib.
WahCloseHandleHelper = Lib.
WahCloseNotificationHandleHelper = Lib.
WahCloseSocketHandle = Lib.
WahCloseThread = Lib.
WahCompleteRequest = Lib.
WahCreateHandleContextTable = Lib.
WahCreateNotificationHandle = Lib.
WahCreateSocketHandle = Lib.
WahDestroyHandleContextTable = Lib.
WahDisableNonIFSHandleSupport = Lib.
WahEnableNonIFSHandleSupport = Lib.
WahEnumerateHandleContexts = Lib.
WahInsertHandleContext = Lib.
WahNotifyAllProcesses = Lib.
WahOpenApcHelper = Lib.
WahOpenCurrentThread = Lib.
WahOpenHandleHelper = Lib.
WahOpenNotificationHandleHelper = Lib.
WahQueueUserApc = Lib.
WahReferenceContextByHandle = Lib.
WahRemoveHandleContext = Lib.
WahWaitForNotification = Lib.
WahWriteLSPEvent = Lib.
WEP = Lib.
WPUCompleteOverlappedRequest = Lib.
WPUGetProviderPathEx = Lib.
WSAAccept = Lib.
--]]

    WSAAddressToStringA = Lib.WSAAddressToStringA,

--[[
WSAAddressToStringW = Lib.
WSAAdvertiseProvider = Lib.
WSAAsyncGetHostByAddr = Lib.
WSAAsyncGetHostByName = Lib.
WSAAsyncGetProtoByName = Lib.
WSAAsyncGetProtoByNumber = Lib.
WSAAsyncGetServByName = Lib.
WSAAsyncGetServByPort = Lib.
WSAAsyncSelect = Lib.
WSACancelAsyncRequest = Lib.
WSACancelBlockingCall = Lib.
WSACleanup = Lib.
WSACloseEvent = Lib.
WSAConnect = Lib.
WSAConnectByList = Lib.
WSAConnectByNameA = Lib.
WSAConnectByNameW = Lib.
WSACreateEvent = Lib.
WSADuplicateSocketA = Lib.
WSADuplicateSocketW = Lib.
WSAEnumNameSpaceProvidersA = Lib.
WSAEnumNameSpaceProvidersExA = Lib.
WSAEnumNameSpaceProvidersExW = Lib.
WSAEnumNameSpaceProvidersW = Lib.
WSAEnumNetworkEvents = Lib.
--]]

    WSAEnumProtocolsA = Lib.WSAEnumProtocolsA,

--[[
WSAEnumProtocolsW = Lib.
WSAEventSelect = Lib.
--]]


    WSAGetLastError = Lib.WSAGetLastError,
    WSAGetOverlappedResult = Lib.WSAGetOverlappedResult,

--[[
WSAGetQOSByName = Lib.
WSAGetServiceClassInfoA = Lib.
WSAGetServiceClassInfoW = Lib.
WSAGetServiceClassNameByClassIdA = Lib.
WSAGetServiceClassNameByClassIdW = Lib.
WSAHtonl = Lib.
WSAHtons = Lib.
WSAInstallServiceClassA = Lib.
WSAInstallServiceClassW = Lib.
--]]

    WSAIoctl = Lib.WSAIoctl,

--[[
WSAIsBlocking = Lib.WSAIsBlocking,
WSAJoinLeaf = Lib.WSAJoinLeaf,
WSALookupServiceBeginA = Lib.WSALookupServiceBeginA,
WSALookupServiceBeginW = Lib.WSALookupServiceBeginW,
WSALookupServiceEnd = Lib.WSALookupServiceEnd,
WSALookupServiceNextA = Lib.WSALookupServiceNextA,
WSALookupServiceNextW = Lib.WSALookupServiceNextW,
WSANSPIoctl = Lib.WSANSPIoctl,
WSANtohl = Lib.WSANtohl,
WSANtohs = Lib.WSANtohs,
--]]

    WSAPoll = Lib.WSAPoll,

--[[
WSAProviderCompleteAsyncCall = Lib.WSAProviderCompleteAsyncCall,
WSAProviderConfigChange = Lib.WSAProviderConfigChange,
WSApSetPostRoutine = Lib.WSApSetPostRoutine,
--]]

    WSARecv = Lib.WSARecv,
    WSARecvFrom = Lib.WSARecvFrom,

--[[
WSARecvDisconnect = Lib.WSARecvDisconnect,
WSARemoveServiceClass = Lib.WSARemoveServiceClass,
WSAResetEvent = Lib.WSAResetEvent,
--]]

    WSASend = Lib.WSASend,

--[[
WSASendDisconnect = Lib.
WSASendMsg = Lib.
--]]

    WSASendTo = Lib.WSASendTo,

-- deprecated: WSASetBlockingHook = Lib.

    WSASetEvent = Lib.WSASetEvent,

--[[
    WSASetLastError = Lib.WSASetLastError,
    WSASetServiceA = Lib.WSASetServiceA,
    WSASetServiceW = Lib.WSASetServiceW,
--]]

    WSASocketA = Lib.WSASocketA,

--[[
    WSASocketW = Lib.WSASocketW,
--]]

    WSAStartup = Lib.WSAStartup,

--[[
WSAStringToAddressA = Lib.
WSAStringToAddressW = Lib.
WSAUnadvertiseProvider = Lib.
WSAUnhookBlockingHook = Lib.
WSAWaitForMultipleEvents = Lib.
--]]

--[[
WSCDeinstallProvider
WSCDeinstallProviderEx
WSCEnableNSProvider
WSCEnumProtocols
WSCEnumProtocolsEx
WSCGetApplicationCategory
WSCGetApplicationCategoryEx
WSCGetProviderInfo
WSCGetProviderPath
WSCInstallNameSpace
WSCInstallNameSpaceEx
WSCInstallNameSpaceEx2
WSCInstallProvider
WSCInstallProviderAndChains
WSCInstallProviderEx
WSCSetApplicationCategory
WSCSetApplicationCategoryEx
WSCSetProviderInfo
WSCUnInstallNameSpace
WSCUnInstallNameSpaceEx2
WSCUpdateProvider
WSCUpdateProviderEx
WSCWriteNameSpaceOrder
WSCWriteProviderOrder
WSCWriteProviderOrderEx
--]]
}
