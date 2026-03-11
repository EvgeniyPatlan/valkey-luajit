--[[
  ffi_cdef.lua – C declarations for ValkeyModule FFI bindings.

  Returns a string suitable for ffi.cdef() that declares the opaque
  ValkeyModule types and the most commonly used ValkeyModule API
  function pointers as extern globals (the way the module SDK exposes
  them).

  Copyright (c) Valkey Contributors
  SPDX-License-Identifier: BSD-3-Clause
]]

local cdef = [[
/* ------------------------------------------------------------------ */
/* Opaque struct forward declarations                                 */
/* ------------------------------------------------------------------ */
typedef struct ValkeyModuleCtx                ValkeyModuleCtx;
typedef struct ValkeyModuleKey                ValkeyModuleKey;
typedef struct ValkeyModuleString             ValkeyModuleString;
typedef struct ValkeyModuleCallReply          ValkeyModuleCallReply;
typedef struct ValkeyModuleCommand            ValkeyModuleCommand;
typedef struct ValkeyModuleBlockedClient      ValkeyModuleBlockedClient;
typedef struct ValkeyModuleDict               ValkeyModuleDict;
typedef struct ValkeyModuleDictIter           ValkeyModuleDictIter;
typedef struct ValkeyModuleType               ValkeyModuleType;
typedef struct ValkeyModuleIO                 ValkeyModuleIO;
typedef struct ValkeyModuleDigest             ValkeyModuleDigest;
typedef struct ValkeyModuleScanCursor         ValkeyModuleScanCursor;
typedef struct ValkeyModuleServerInfoData     ValkeyModuleServerInfoData;
typedef struct ValkeyModuleUser               ValkeyModuleUser;
typedef struct ValkeyModuleCommandFilterCtx   ValkeyModuleCommandFilterCtx;
typedef struct ValkeyModuleCommandFilter      ValkeyModuleCommandFilter;
typedef struct ValkeyModuleKeyOptCtx          ValkeyModuleKeyOptCtx;
typedef struct ValkeyModuleInfoCtx            ValkeyModuleInfoCtx;
typedef struct ValkeyModuleDefragCtx          ValkeyModuleDefragCtx;
typedef struct ValkeyModuleRdbStream          ValkeyModuleRdbStream;

/* ------------------------------------------------------------------ */
/* Concrete types                                                     */
/* ------------------------------------------------------------------ */
typedef struct ValkeyModuleStreamID {
    uint64_t ms;
    uint64_t seq;
} ValkeyModuleStreamID;

typedef uint64_t ValkeyModuleTimerID;

/* mstime_t / ustime_t – match server definition (long long). */
typedef long long mstime_t;
typedef long long ustime_t;

/* ------------------------------------------------------------------ */
/* ValkeyModule API – extern global function pointers                 */
/*                                                                    */
/* In the Valkey module SDK every API entry point is a global         */
/* variable of function-pointer type (populated by ValkeyModule_Init) */
/* so we must declare them with 'extern' storage.                     */
/* ------------------------------------------------------------------ */

/* -- Memory -------------------------------------------------------- */
extern void  *(*ValkeyModule_Alloc)(size_t bytes);
extern void   (*ValkeyModule_Free)(void *ptr);
extern void  *(*ValkeyModule_Realloc)(void *ptr, size_t bytes);
extern void  *(*ValkeyModule_Calloc)(size_t nmemb, size_t size);
extern char  *(*ValkeyModule_Strdup)(const char *str);

/* -- String creation / inspection ---------------------------------- */
extern ValkeyModuleString *(*ValkeyModule_CreateString)(
    ValkeyModuleCtx *ctx, const char *ptr, size_t len);
extern ValkeyModuleString *(*ValkeyModule_CreateStringFromLongLong)(
    ValkeyModuleCtx *ctx, long long ll);
extern ValkeyModuleString *(*ValkeyModule_CreateStringFromDouble)(
    ValkeyModuleCtx *ctx, double d);
extern ValkeyModuleString *(*ValkeyModule_CreateStringPrintf)(
    ValkeyModuleCtx *ctx, const char *fmt, ...);
extern void (*ValkeyModule_FreeString)(
    ValkeyModuleCtx *ctx, ValkeyModuleString *str);
extern const char *(*ValkeyModule_StringPtrLen)(
    const ValkeyModuleString *str, size_t *len);
extern int (*ValkeyModule_StringToLongLong)(
    const ValkeyModuleString *str, long long *ll);
extern int (*ValkeyModule_StringToDouble)(
    const ValkeyModuleString *str, double *d);
extern int (*ValkeyModule_StringAppendBuffer)(
    ValkeyModuleCtx *ctx, ValkeyModuleString *str,
    const char *buf, size_t len);
extern void (*ValkeyModule_RetainString)(
    ValkeyModuleCtx *ctx, ValkeyModuleString *str);

/* -- Reply helpers ------------------------------------------------- */
extern int  (*ValkeyModule_ReplyWithLongLong)(ValkeyModuleCtx *ctx, long long ll);
extern int  (*ValkeyModule_ReplyWithError)(ValkeyModuleCtx *ctx, const char *err);
extern int  (*ValkeyModule_ReplyWithSimpleString)(ValkeyModuleCtx *ctx, const char *msg);
extern int  (*ValkeyModule_ReplyWithStringBuffer)(
    ValkeyModuleCtx *ctx, const char *buf, size_t len);
extern int  (*ValkeyModule_ReplyWithString)(
    ValkeyModuleCtx *ctx, ValkeyModuleString *str);
extern int  (*ValkeyModule_ReplyWithNull)(ValkeyModuleCtx *ctx);
extern int  (*ValkeyModule_ReplyWithArray)(ValkeyModuleCtx *ctx, long len);
extern void (*ValkeyModule_ReplySetArrayLength)(ValkeyModuleCtx *ctx, long len);
extern int  (*ValkeyModule_ReplyWithDouble)(ValkeyModuleCtx *ctx, double d);
extern int  (*ValkeyModule_ReplyWithBool)(ValkeyModuleCtx *ctx, int b);
extern int  (*ValkeyModule_ReplyWithMap)(ValkeyModuleCtx *ctx, long len);
extern void (*ValkeyModule_ReplySetMapLength)(ValkeyModuleCtx *ctx, long len);
extern int  (*ValkeyModule_ReplyWithSet)(ValkeyModuleCtx *ctx, long len);
extern void (*ValkeyModule_ReplySetSetLength)(ValkeyModuleCtx *ctx, long len);
extern int  (*ValkeyModule_ReplyWithCallReply)(
    ValkeyModuleCtx *ctx, ValkeyModuleCallReply *reply);
extern int  (*ValkeyModule_ReplyWithVerbatimStringType)(
    ValkeyModuleCtx *ctx, const char *buf, size_t len, const char *ext);
extern int  (*ValkeyModule_ReplyWithBigNumber)(
    ValkeyModuleCtx *ctx, const char *bignum, size_t len);
extern int  (*ValkeyModule_ReplyWithErrorFormat)(
    ValkeyModuleCtx *ctx, const char *fmt, ...);

/* -- Key access ---------------------------------------------------- */
extern ValkeyModuleKey *(*ValkeyModule_OpenKey)(
    ValkeyModuleCtx *ctx, ValkeyModuleString *keyname, int mode);
extern void   (*ValkeyModule_CloseKey)(ValkeyModuleKey *kp);
extern int    (*ValkeyModule_KeyType)(ValkeyModuleKey *kp);
extern size_t (*ValkeyModule_ValueLength)(ValkeyModuleKey *kp);
extern int    (*ValkeyModule_DeleteKey)(ValkeyModuleKey *key);
extern int    (*ValkeyModule_UnlinkKey)(ValkeyModuleKey *key);
extern int    (*ValkeyModule_StringSet)(ValkeyModuleKey *key, ValkeyModuleString *str);
extern char  *(*ValkeyModule_StringDMA)(ValkeyModuleKey *key, size_t *len, int mode);
extern int    (*ValkeyModule_StringTruncate)(ValkeyModuleKey *key, size_t newlen);
extern mstime_t (*ValkeyModule_GetExpire)(ValkeyModuleKey *key);
extern int    (*ValkeyModule_SetExpire)(ValkeyModuleKey *key, mstime_t expire);

/* -- List ---------------------------------------------------------- */
extern int (*ValkeyModule_ListPush)(
    ValkeyModuleKey *kp, int where, ValkeyModuleString *ele);
extern ValkeyModuleString *(*ValkeyModule_ListPop)(
    ValkeyModuleKey *key, int where);
extern ValkeyModuleString *(*ValkeyModule_ListGet)(
    ValkeyModuleKey *key, long index);
extern int (*ValkeyModule_ListSet)(
    ValkeyModuleKey *key, long index, ValkeyModuleString *value);
extern int (*ValkeyModule_ListInsert)(
    ValkeyModuleKey *key, long index, ValkeyModuleString *value);
extern int (*ValkeyModule_ListDelete)(ValkeyModuleKey *key, long index);

/* -- Hash ---------------------------------------------------------- */
/* NOTE: HashSet/HashGet are variadic (sentinel-terminated) so LuaJIT */
/* cannot JIT-compile calls to them — they always use interpreter FFI.*/
/* HashSetStringRef/HashHasStringRef are non-variadic but they are    */
/* specialized APIs for zero-copy string reference sharing (designed  */
/* for valkey-search). They require the key to already exist as a     */
/* hash (no auto-create) and store a pointer reference, not a copy.   */
/* For general hash operations, prefer server.call('HSET', ...) which */
/* uses the native C path (faster than variadic FFI via VKM.call).    */
extern int (*ValkeyModule_HashSet)(ValkeyModuleKey *key, int flags, ...);
extern int (*ValkeyModule_HashGet)(ValkeyModuleKey *key, int flags, ...);

/* -- Sorted set ---------------------------------------------------- */
extern int (*ValkeyModule_ZsetAdd)(
    ValkeyModuleKey *key, double score,
    ValkeyModuleString *ele, int *flagsptr);
extern int (*ValkeyModule_ZsetIncrby)(
    ValkeyModuleKey *key, double score,
    ValkeyModuleString *ele, int *flagsptr, double *newscore);
extern int (*ValkeyModule_ZsetScore)(
    ValkeyModuleKey *key, ValkeyModuleString *ele, double *score);
extern int (*ValkeyModule_ZsetRem)(
    ValkeyModuleKey *key, ValkeyModuleString *ele, int *deleted);

/* -- Sorted set range iteration ------------------------------------ */
extern int (*ValkeyModule_ZsetFirstInScoreRange)(
    ValkeyModuleKey *key, double min, double max, int minex, int maxex);
extern int (*ValkeyModule_ZsetLastInScoreRange)(
    ValkeyModuleKey *key, double min, double max, int minex, int maxex);
extern ValkeyModuleString *(*ValkeyModule_ZsetRangeCurrentElement)(
    ValkeyModuleKey *key, double *score);
extern int  (*ValkeyModule_ZsetRangeNext)(ValkeyModuleKey *key);
extern int  (*ValkeyModule_ZsetRangePrev)(ValkeyModuleKey *key);
extern int  (*ValkeyModule_ZsetRangeEndReached)(ValkeyModuleKey *key);
extern void (*ValkeyModule_ZsetRangeStop)(ValkeyModuleKey *key);

/* -- Call / CallReply ---------------------------------------------- */
/* NOTE: ValkeyModule_Call is variadic — LuaJIT cannot JIT-compile   */
/* variadic FFI calls.  Prefer server.call() for command dispatch    */
/* (native C path, ~20% faster).  These declarations are retained    */
/* for advanced users who need direct CallReply access via VKM.C.    */
extern ValkeyModuleCallReply *(*ValkeyModule_Call)(
    ValkeyModuleCtx *ctx, const char *cmdname,
    const char *fmt, ...);
extern void (*ValkeyModule_FreeCallReply)(ValkeyModuleCallReply *reply);
extern int  (*ValkeyModule_CallReplyType)(ValkeyModuleCallReply *reply);
extern size_t (*ValkeyModule_CallReplyLength)(ValkeyModuleCallReply *reply);
extern long long (*ValkeyModule_CallReplyInteger)(ValkeyModuleCallReply *reply);
extern double (*ValkeyModule_CallReplyDouble)(ValkeyModuleCallReply *reply);
extern int (*ValkeyModule_CallReplyBool)(ValkeyModuleCallReply *reply);
extern const char *(*ValkeyModule_CallReplyStringPtr)(
    ValkeyModuleCallReply *reply, size_t *len);
extern ValkeyModuleCallReply *(*ValkeyModule_CallReplyArrayElement)(
    ValkeyModuleCallReply *reply, size_t idx);

/* -- Context ------------------------------------------------------- */
extern int (*ValkeyModule_GetSelectedDb)(ValkeyModuleCtx *ctx);
extern int (*ValkeyModule_SelectDb)(ValkeyModuleCtx *ctx, int newid);
extern unsigned long long (*ValkeyModule_GetClientId)(ValkeyModuleCtx *ctx);
extern void (*ValkeyModule_AutoMemory)(ValkeyModuleCtx *ctx);
extern void (*ValkeyModule_Log)(ValkeyModuleCtx *ctx,
    const char *level, const char *fmt, ...);

/* -- Misc ---------------------------------------------------------- */
extern int (*ValkeyModule_GetContextFlags)(ValkeyModuleCtx *ctx);
extern mstime_t (*ValkeyModule_Milliseconds)(void);
extern uint64_t (*ValkeyModule_MonotonicMicroseconds)(void);

]]

return cdef
