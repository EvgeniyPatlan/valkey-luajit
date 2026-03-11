--[[
  ffi_api.lua – OOP Lua wrappers around the ValkeyModule FFI bindings.

  Provides:
    * VKM.ctx()                     – obtain the current ValkeyModuleCtx*
    * Helper functions              – thin wrappers for common operations
    * ffi.metatype-based OOP        – ValkeyModuleString, ValkeyModuleKey
    * VKM.C                         – raw access to all declared ValkeyModule
                                      API function pointers for advanced use
    * Constants                     – status codes, key modes, key types,
                                      reply types, list directions, hash flags

  Copyright (c) Valkey Contributors
  SPDX-License-Identifier: BSD-3-Clause
]]

local ffi = ffi  -- global set by C code before this file runs
local cdef_str = __ffi_cdef_str  -- global set by C code before this file runs
ffi.cdef(cdef_str)

-- ValkeyModule_* are global function pointer variables that live in our
-- module's .so (populated by ValkeyModule_Init). Modules loaded via dlopen
-- are typically not visible via RTLD_DEFAULT / ffi.C (on both macOS and
-- Linux). We use ffi.load() on our own .so path (passed from C via
-- __vkm_module_path, resolved with dladdr) to access them.
local C
if __vkm_module_path then
    C = ffi.load(__vkm_module_path)
else
    C = ffi.C  -- unlikely fallback if dladdr() failed
end

-- Scratch buffer reused by StringPtrLen / CallReplyStringPtr helpers.
local _len = ffi.new("size_t[1]")

-- ====================================================================
-- Constants
-- ====================================================================

local VKM = {}

-- Status codes
VKM.OK  = 0
VKM.ERR = 1

-- Key open modes
VKM.READ              = 0x0001  -- (1 << 0)
VKM.WRITE             = 0x0002  -- (1 << 1)
VKM.OPEN_KEY_NOTOUCH  = 0x00010000  -- (1 << 16)
VKM.OPEN_KEY_NONOTIFY = 0x00020000  -- (1 << 17)
VKM.OPEN_KEY_NOSTATS  = 0x00040000  -- (1 << 18)
VKM.OPEN_KEY_NOEXPIRE = 0x00080000  -- (1 << 19)
VKM.OPEN_KEY_NOEFFECTS = 0x00100000 -- (1 << 20)

-- Key types
VKM.KEYTYPE_EMPTY   = 0
VKM.KEYTYPE_STRING  = 1
VKM.KEYTYPE_LIST    = 2
VKM.KEYTYPE_HASH    = 3
VKM.KEYTYPE_SET     = 4
VKM.KEYTYPE_ZSET    = 5
VKM.KEYTYPE_MODULE  = 6
VKM.KEYTYPE_STREAM  = 7

-- Reply types
VKM.REPLY_UNKNOWN         = -1
VKM.REPLY_STRING          = 0
VKM.REPLY_ERROR           = 1
VKM.REPLY_INTEGER         = 2
VKM.REPLY_ARRAY           = 3
VKM.REPLY_NULL            = 4
VKM.REPLY_MAP             = 5
VKM.REPLY_SET             = 6
VKM.REPLY_BOOL            = 7
VKM.REPLY_DOUBLE          = 8
VKM.REPLY_BIG_NUMBER      = 9
VKM.REPLY_VERBATIM_STRING = 10
VKM.REPLY_ATTRIBUTE       = 11
VKM.REPLY_PROMISE         = 12
VKM.REPLY_SIMPLE_STRING   = 13
VKM.REPLY_ARRAY_NULL      = 14

-- Postponed length
VKM.POSTPONED_LEN = -1

-- List push/pop direction
VKM.LIST_HEAD = 0
VKM.LIST_TAIL = 1

-- Hash flags
VKM.HASH_NONE    = 0
VKM.HASH_NX      = 0x0001  -- (1 << 0)
VKM.HASH_XX      = 0x0002  -- (1 << 1)
VKM.HASH_CFIELDS = 0x0004  -- (1 << 2)
VKM.HASH_EXISTS  = 0x0008  -- (1 << 3)

-- Sorted set flags
VKM.ZADD_XX      = 0x0001  -- (1 << 0)
VKM.ZADD_NX      = 0x0002  -- (1 << 1)
VKM.ZADD_ADDED   = 0x0004  -- (1 << 2)
VKM.ZADD_UPDATED = 0x0008  -- (1 << 3)
VKM.ZADD_NOP     = 0x0010  -- (1 << 4)
VKM.ZADD_GT      = 0x0020  -- (1 << 5)
VKM.ZADD_LT      = 0x0040  -- (1 << 6)

-- Expire sentinel
VKM.NO_EXPIRE = -1

-- Log levels (string constants matching server expectations)
VKM.LOG_DEBUG   = "debug"
VKM.LOG_VERBOSE = "verbose"
VKM.LOG_NOTICE  = "notice"
VKM.LOG_WARNING = "warning"

-- ====================================================================
-- Context bridge
-- ====================================================================

--- Return the current ValkeyModuleCtx* for the running command.
--- Uses the __vkm_get_ctx Lua C function (registered by the module)
--- which returns the ctx as light userdata, then casts it to the
--- proper FFI type.
function VKM.ctx()
    local ud = __vkm_get_ctx()
    if ud == nil then return nil end
    return ffi.cast("ValkeyModuleCtx *", ud)
end

-- ====================================================================
-- Helper functions
-- ====================================================================

--- Send a string buffer reply.
--- If `str` is a Lua string it is sent via ReplyWithStringBuffer;
--- if it is a ValkeyModuleString* it is sent via ReplyWithString.
function VKM.reply_with_string(ctx, str)
    if type(str) == "string" then
        return C.ValkeyModule_ReplyWithStringBuffer(ctx, str, #str)
    else
        return C.ValkeyModule_ReplyWithString(ctx, str)
    end
end

--- Send an integer reply.
function VKM.reply_with_longlong(ctx, n)
    return C.ValkeyModule_ReplyWithLongLong(ctx, n)
end

--- Send an error reply.  `msg` must include the error prefix
--- (e.g. "ERR something went wrong").
function VKM.reply_with_error(ctx, msg)
    return C.ValkeyModule_ReplyWithError(ctx, msg)
end

--- Write a log message.
--- `level` is one of VKM.LOG_* or a plain string.
function VKM.log(ctx, level, msg)
    C.ValkeyModule_Log(ctx, level, "%s", msg)
end

--- Open a key.  Returns a ValkeyModuleKey* (with metatype methods).
--- `name` may be a Lua string (a temporary ValkeyModuleString is created
--- and freed automatically) or an existing ValkeyModuleString*.
function VKM.open_key(ctx, name, mode)
    if type(name) == "string" then
        local rms = C.ValkeyModule_CreateString(ctx, name, #name)
        local key = C.ValkeyModule_OpenKey(ctx, rms, mode)
        C.ValkeyModule_FreeString(ctx, rms)
        return key
    else
        return C.ValkeyModule_OpenKey(ctx, name, mode)
    end
end

--- Create a ValkeyModuleString* from a Lua string.
function VKM.create_string(ctx, str)
    return C.ValkeyModule_CreateString(ctx, str, #str)
end

-- ====================================================================
-- OOP metatypes
-- ====================================================================

-- Helper: convert a ValkeyModuleString* to a Lua string via StringPtrLen.
local function rms_to_lua_string(rms)
    local ptr = C.ValkeyModule_StringPtrLen(rms, _len)
    if ptr == nil then return nil end
    return ffi.string(ptr, _len[0])
end

-- ---- ValkeyModuleString ----

local VMString_methods = {}
local VMString_mt = { __index = VMString_methods }

--- Return the raw pointer and length (as two values).
function VMString_methods:PtrLen()
    local ptr = C.ValkeyModule_StringPtrLen(self, _len)
    return ptr, _len[0]
end

--- Attempt to parse the string as a long long.
--- Returns (value, VALKEYMODULE_OK) or (nil, VALKEYMODULE_ERR).
function VMString_methods:ToLongLong()
    local out = ffi.new("long long[1]")
    local rc = C.ValkeyModule_StringToLongLong(self, out)
    if rc == 0 then return tonumber(out[0]), rc end
    return nil, rc
end

--- Attempt to parse the string as a double.
--- Returns (value, VALKEYMODULE_OK) or (nil, VALKEYMODULE_ERR).
function VMString_methods:ToDouble()
    local out = ffi.new("double[1]")
    local rc = C.ValkeyModule_StringToDouble(self, out)
    if rc == 0 then return tonumber(out[0]), rc end
    return nil, rc
end

VMString_mt.__tostring = rms_to_lua_string

ffi.metatype("ValkeyModuleString", VMString_mt)

-- ---- ValkeyModuleKey ----

local VMKey_methods = {}
local VMKey_mt = { __index = VMKey_methods }

function VMKey_methods:Close()
    C.ValkeyModule_CloseKey(self)
end

function VMKey_methods:KeyType()
    return C.ValkeyModule_KeyType(self)
end

function VMKey_methods:ValueLength()
    return C.ValkeyModule_ValueLength(self)
end

--- Set the string value of the key.  `str` must be a
--- ValkeyModuleString*.
function VMKey_methods:StringSet(str)
    return C.ValkeyModule_StringSet(self, str)
end

--- Push an element onto a list key.
--- `where` is VKM.LIST_HEAD or VKM.LIST_TAIL.
function VMKey_methods:ListPush(where, ele)
    return C.ValkeyModule_ListPush(self, where, ele)
end

--- Pop an element from a list key.
--- `where` is VKM.LIST_HEAD or VKM.LIST_TAIL.
--- Returns a ValkeyModuleString* (caller must free) or nil.
function VMKey_methods:ListPop(where)
    return C.ValkeyModule_ListPop(self, where)
end

ffi.metatype("ValkeyModuleKey", VMKey_mt)

-- Expose the loaded C namespace so scripts can call any declared
-- ValkeyModule API function directly (e.g. VKM.C.ValkeyModule_ZsetAdd).
-- This is the non-variadic path that LuaJIT can JIT-compile.
VKM.C = C

return VKM
