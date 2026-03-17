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
typedef struct ValkeyModuleKeyOptCtx          ValkeyModuleKeyOptCtx;
typedef struct ValkeyModuleInfoCtx            ValkeyModuleInfoCtx;

typedef struct ValkeyModuleClientInfo {
    uint64_t version;
    uint64_t flags;
    uint64_t id;
    char addr[46];
    uint16_t port;
    uint16_t db;
} ValkeyModuleClientInfo;

typedef struct ValkeyModuleStreamID {
    uint64_t ms;
    uint64_t seq;
} ValkeyModuleStreamID;

typedef long long mstime_t;
typedef long long ustime_t;

typedef struct ValkeyModuleClusterInfo ValkeyModuleClusterInfo;

extern void  *(*ValkeyModule_Alloc)(size_t bytes);
extern void   (*ValkeyModule_Free)(void *ptr);
extern void  *(*ValkeyModule_Realloc)(void *ptr, size_t bytes);
extern void  *(*ValkeyModule_Calloc)(size_t nmemb, size_t size);
extern char  *(*ValkeyModule_Strdup)(const char *str);

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
extern ValkeyModuleString *(*ValkeyModule_CreateStringFromULongLong)(
    ValkeyModuleCtx *ctx, unsigned long long ull);
extern ValkeyModuleString *(*ValkeyModule_CreateStringFromLongDouble)(
    ValkeyModuleCtx *ctx, long double ld, int humanfriendly);
extern ValkeyModuleString *(*ValkeyModule_CreateStringFromString)(
    ValkeyModuleCtx *ctx, const ValkeyModuleString *str);
extern ValkeyModuleString *(*ValkeyModule_CreateStringFromStreamID)(
    ValkeyModuleCtx *ctx, const ValkeyModuleStreamID *id);
extern ValkeyModuleString *(*ValkeyModule_HoldString)(
    ValkeyModuleCtx *ctx, ValkeyModuleString *str);
extern void (*ValkeyModule_TrimStringAllocation)(ValkeyModuleString *str);
extern int (*ValkeyModule_StringCompare)(
    const ValkeyModuleString *a, const ValkeyModuleString *b);
extern int (*ValkeyModule_StringToULongLong)(
    const ValkeyModuleString *str, unsigned long long *ull);
extern int (*ValkeyModule_StringToLongDouble)(
    const ValkeyModuleString *str, long double *d);
extern int (*ValkeyModule_StringToStreamID)(
    const ValkeyModuleString *str, ValkeyModuleStreamID *id);

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
extern int  (*ValkeyModule_ReplyWithCString)(ValkeyModuleCtx *ctx, const char *buf);
extern int  (*ValkeyModule_ReplyWithEmptyString)(ValkeyModuleCtx *ctx);
extern int  (*ValkeyModule_ReplyWithEmptyArray)(ValkeyModuleCtx *ctx);
extern int  (*ValkeyModule_ReplyWithNullArray)(ValkeyModuleCtx *ctx);
extern int  (*ValkeyModule_ReplyWithVerbatimString)(ValkeyModuleCtx *ctx, const char *buf, size_t len);
extern int  (*ValkeyModule_ReplyWithLongDouble)(ValkeyModuleCtx *ctx, long double d);
extern int  (*ValkeyModule_ReplyWithAttribute)(ValkeyModuleCtx *ctx, long len);
extern void (*ValkeyModule_ReplySetAttributeLength)(ValkeyModuleCtx *ctx, long len);
extern void (*ValkeyModule_ReplySetPushLength)(ValkeyModuleCtx *ctx, long len);
extern int (*ValkeyModule_ReplyWithCustomErrorFormat)(ValkeyModuleCtx *ctx, int update_error_stats, const char *fmt, ...);

extern int (*ValkeyModule_PublishMessage)(
    ValkeyModuleCtx *ctx,
    ValkeyModuleString *channel,
    ValkeyModuleString *message);
extern int (*ValkeyModule_PublishMessageShard)(
    ValkeyModuleCtx *ctx,
    ValkeyModuleString *channel,
    ValkeyModuleString *message);

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
extern mstime_t (*ValkeyModule_GetAbsExpire)(ValkeyModuleKey *key);
extern int    (*ValkeyModule_SetAbsExpire)(ValkeyModuleKey *key, mstime_t expire);
extern int (*ValkeyModule_KeyExists)(
    ValkeyModuleCtx *ctx, ValkeyModuleString *keyname);
extern int (*ValkeyModule_GetOpenKeyModesAll)(void);
extern int (*ValkeyModule_SignalModifiedKey)(
    ValkeyModuleCtx *ctx, ValkeyModuleString *keyname);

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

extern int (*ValkeyModule_HashSet)(ValkeyModuleKey *key, int flags, ...);
extern int (*ValkeyModule_HashGet)(ValkeyModuleKey *key, int flags, ...);
extern int (*ValkeyModule_HashSetStringRef)(
    ValkeyModuleKey *key, ValkeyModuleString *field,
    const char *buf, size_t len);
extern int (*ValkeyModule_HashHasStringRef)(
    ValkeyModuleKey *key, ValkeyModuleString *field);

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

extern int (*ValkeyModule_ZsetFirstInScoreRange)(
    ValkeyModuleKey *key, double min, double max, int minex, int maxex);
extern int (*ValkeyModule_ZsetLastInScoreRange)(
    ValkeyModuleKey *key, double min, double max, int minex, int maxex);
extern int (*ValkeyModule_ZsetFirstInLexRange)(
    ValkeyModuleKey *key,
    ValkeyModuleString *min,
    ValkeyModuleString *max);
extern int (*ValkeyModule_ZsetLastInLexRange)(
    ValkeyModuleKey *key,
    ValkeyModuleString *min,
    ValkeyModuleString *max);
extern ValkeyModuleString *(*ValkeyModule_ZsetRangeCurrentElement)(
    ValkeyModuleKey *key, double *score);
extern int  (*ValkeyModule_ZsetRangeNext)(ValkeyModuleKey *key);
extern int  (*ValkeyModule_ZsetRangePrev)(ValkeyModuleKey *key);
extern int  (*ValkeyModule_ZsetRangeEndReached)(ValkeyModuleKey *key);
extern void (*ValkeyModule_ZsetRangeStop)(ValkeyModuleKey *key);

extern int (*ValkeyModule_StreamAdd)(
    ValkeyModuleKey *key,
    int flags,
    ValkeyModuleStreamID *id,
    ValkeyModuleString **argv,
    int64_t numfields);
extern int (*ValkeyModule_StreamDelete)(
    ValkeyModuleKey *key,
    ValkeyModuleStreamID *id);
extern int (*ValkeyModule_StreamIteratorStart)(
    ValkeyModuleKey *key,
    int flags,
    ValkeyModuleStreamID *startid,
    ValkeyModuleStreamID *endid);
extern int (*ValkeyModule_StreamIteratorStop)(
    ValkeyModuleKey *key);
extern int (*ValkeyModule_StreamIteratorNextID)(
    ValkeyModuleKey *key,
    ValkeyModuleStreamID *id,
    long *numfields);
extern int (*ValkeyModule_StreamIteratorNextField)(
    ValkeyModuleKey *key,
    ValkeyModuleString **field_ptr,
    ValkeyModuleString **value_ptr);
extern int (*ValkeyModule_StreamIteratorDelete)(
    ValkeyModuleKey *key);
extern long long (*ValkeyModule_StreamTrimByLength)(
    ValkeyModuleKey *key,
    int flags,
    long long length);
extern long long (*ValkeyModule_StreamTrimByID)(
    ValkeyModuleKey *key,
    int flags,
    ValkeyModuleStreamID *id);

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

/* -- Call / CallReply - EXTENDED ---------------------------------- */
/* Get protocol representation of reply (RESP serialization) */
extern const char *(*ValkeyModule_CallReplyProto)(
    ValkeyModuleCallReply *reply, size_t *len);

/* Get big number string from VALKEYMODULE_REPLY_BIG_NUMBER replies */
extern const char *(*ValkeyModule_CallReplyBigNumber)(
    ValkeyModuleCallReply *reply, size_t *len);

/* Get verbatim string with format from VALKEYMODULE_REPLY_VERBATIM_STRING replies */
extern const char *(*ValkeyModule_CallReplyVerbatim)(
    ValkeyModuleCallReply *reply, size_t *len, const char **format);

/* Get element from VALKEYMODULE_REPLY_SET replies (sets don't have keys) */
extern ValkeyModuleCallReply *(*ValkeyModule_CallReplySetElement)(
    ValkeyModuleCallReply *reply, size_t idx);

/* Get key-value pair from VALKEYMODULE_REPLY_MAP replies */
extern int (*ValkeyModule_CallReplyMapElement)(
    ValkeyModuleCallReply *reply, size_t idx,
    ValkeyModuleCallReply **key, ValkeyModuleCallReply **val);

/* Get key-value pair from VALKEYMODULE_REPLY_ATTRIBUTE replies */
extern int (*ValkeyModule_CallReplyAttributeElement)(
    ValkeyModuleCallReply *reply, size_t idx,
    ValkeyModuleCallReply **key, ValkeyModuleCallReply **val);

/* Get attribute block associated with a reply (RESP3) */
extern ValkeyModuleCallReply *(*ValkeyModule_CallReplyAttribute)(
    ValkeyModuleCallReply *reply);

/* Abort a pending VALKEYMODULE_REPLY_PROMISE reply */
extern int (*ValkeyModule_CallReplyPromiseAbort)(
    ValkeyModuleCallReply *reply, void **private_data);

/* Convert a CallReply to a ValkeyModuleString */
extern ValkeyModuleString *(*ValkeyModule_CreateStringFromCallReply)(
    ValkeyModuleCtx *ctx, ValkeyModuleCallReply *reply);

/* -- User & ACL Management ---------------------------------------- */

/* ACL Log Entry Reason enum */
typedef enum {
    VALKEYMODULE_ACL_LOG_AUTH = 0,      /* Authentication failure */
    VALKEYMODULE_ACL_LOG_CMD = 1,       /* Command authorization failure */
    VALKEYMODULE_ACL_LOG_KEY = 2,       /* Key authorization failure */
    VALKEYMODULE_ACL_LOG_CHANNEL = 3,   /* Channel authorization failure */
    VALKEYMODULE_ACL_LOG_DB = 4         /* Database authorization failure */
} ValkeyModuleACLLogEntryReason;

/* Module user management */
extern ValkeyModuleUser *(*ValkeyModule_CreateModuleUser)(const char *name);
extern void (*ValkeyModule_FreeModuleUser)(ValkeyModuleUser *user);
extern void (*ValkeyModule_SetContextUser)(ValkeyModuleCtx *ctx, const ValkeyModuleUser *user);
extern ValkeyModuleString *(*ValkeyModule_GetModuleUserACLString)(ValkeyModuleUser *user);
extern ValkeyModuleString *(*ValkeyModule_GetCurrentUserName)(ValkeyModuleCtx *ctx);
extern ValkeyModuleUser *(*ValkeyModule_GetModuleUserFromUserName)(ValkeyModuleString *name);

/* ACL permission checking */
extern int (*ValkeyModule_ACLCheckCommandPermissions)(ValkeyModuleUser *user, ValkeyModuleString **argv, int argc);
extern int (*ValkeyModule_ACLCheckKeyPermissions)(ValkeyModuleUser *user, ValkeyModuleString *key, int flags);
extern int (*ValkeyModule_ACLCheckChannelPermissions)(ValkeyModuleUser *user, ValkeyModuleString *ch, int literal);
extern int (*ValkeyModule_ACLCheckPermissions)(ValkeyModuleUser *user, ValkeyModuleString **argv, int argc, int dbid, ValkeyModuleACLLogEntryReason *denial_reason);
extern int (*ValkeyModule_ACLCheckKeyPrefixPermissions)(ValkeyModuleUser *user, const char *key, size_t len, unsigned int flags);

/* ACL logging */
extern void (*ValkeyModule_ACLAddLogEntry)(ValkeyModuleCtx *ctx, ValkeyModuleUser *user, ValkeyModuleString *object, ValkeyModuleACLLogEntryReason reason);
extern void (*ValkeyModule_ACLAddLogEntryByUserName)(ValkeyModuleCtx *ctx, ValkeyModuleString *user, ValkeyModuleString *object, ValkeyModuleACLLogEntryReason reason);

/* Client deauthentication */
extern int (*ValkeyModule_DeauthenticateAndCloseClient)(ValkeyModuleCtx *ctx, uint64_t client_id);

/* -- Context ------------------------------------------------------- */
extern int (*ValkeyModule_GetSelectedDb)(ValkeyModuleCtx *ctx);
extern int (*ValkeyModule_SelectDb)(ValkeyModuleCtx *ctx, int newid);
extern unsigned long long (*ValkeyModule_GetClientId)(ValkeyModuleCtx *ctx);
extern void (*ValkeyModule_AutoMemory)(ValkeyModuleCtx *ctx);
extern void (*ValkeyModule_Log)(ValkeyModuleCtx *ctx,
    const char *level, const char *fmt, ...);

/* -- Client Management --------------------------------------------- */
extern int (*ValkeyModule_MustObeyClient)(ValkeyModuleCtx *ctx);
extern int (*ValkeyModule_GetClientInfoById)(ValkeyModuleClientInfo *ci, uint64_t id);
extern ValkeyModuleString *(*ValkeyModule_GetClientNameById)(ValkeyModuleCtx *ctx, uint64_t id);
extern int (*ValkeyModule_SetClientNameById)(uint64_t id, ValkeyModuleString *name);
extern ValkeyModuleString *(*ValkeyModule_GetClientUserNameById)(ValkeyModuleCtx *ctx, uint64_t id);
extern ValkeyModuleString *(*ValkeyModule_GetClientCertificate)(ValkeyModuleCtx *ctx, uint64_t id);
extern int (*ValkeyModule_RedactClientCommandArgument)(ValkeyModuleCtx *ctx, int pos);

/* -- Database ------------------------------------------------------ */
extern unsigned long long (*ValkeyModule_DbSize)(ValkeyModuleCtx *ctx);
extern ValkeyModuleString *(*ValkeyModule_RandomKey)(ValkeyModuleCtx *ctx);
extern void (*ValkeyModule_ResetDataset)(int restart_aof, int async);

/* -- Misc ---------------------------------------------------------- */
extern int (*ValkeyModule_GetContextFlags)(ValkeyModuleCtx *ctx);
extern mstime_t (*ValkeyModule_Milliseconds)(void);
extern uint64_t (*ValkeyModule_MonotonicMicroseconds)(void);

/* -- Server Info & Version ------------------------------------------- */
extern ValkeyModuleServerInfoData *(*ValkeyModule_GetServerInfo)(
    ValkeyModuleCtx *ctx, const char *section);
extern void (*ValkeyModule_FreeServerInfo)(
    ValkeyModuleCtx *ctx, ValkeyModuleServerInfoData *data);
extern ValkeyModuleString *(*ValkeyModule_ServerInfoGetField)(
    ValkeyModuleCtx *ctx, ValkeyModuleServerInfoData *data, const char *field);
extern const char *(*ValkeyModule_ServerInfoGetFieldC)(
    ValkeyModuleServerInfoData *data, const char *field);
extern long long (*ValkeyModule_ServerInfoGetFieldSigned)(
    ValkeyModuleServerInfoData *data, const char *field, int *out_err);
extern unsigned long long (*ValkeyModule_ServerInfoGetFieldUnsigned)(
    ValkeyModuleServerInfoData *data, const char *field, int *out_err);
extern double (*ValkeyModule_ServerInfoGetFieldDouble)(
    ValkeyModuleServerInfoData *data, const char *field, int *out_err);
extern int (*ValkeyModule_GetContextFlagsAll)(void);
extern int (*ValkeyModule_GetServerVersion)(void);
extern int (*ValkeyModule_GetTypeMethodVersion)(void);

/* -- Cluster Operations ---------------------------------------------- */
extern const char *(*ValkeyModule_GetMyClusterID)(void);
extern size_t (*ValkeyModule_GetClusterSize)(void);
extern int (*ValkeyModule_SendClusterMessage)(
    ValkeyModuleCtx *ctx,
    const char *target_id,
    uint8_t type,
    const char *msg,
    uint32_t len);
extern int (*ValkeyModule_GetClusterNodeInfo)(
    ValkeyModuleCtx *ctx,
    const char *id,
    char *ip,
    char *primary_id,
    int *port,
    int *flags);
extern int (*ValkeyModule_GetClusterNodeInfoForClient)(
    ValkeyModuleCtx *ctx,
    uint64_t client_id,
    const char *node_id,
    char *ip,
    char *primary_id,
    int *port,
    int *flags);
extern char **(*ValkeyModule_GetClusterNodesList)(ValkeyModuleCtx *ctx, size_t *numnodes);
extern void (*ValkeyModule_FreeClusterNodesList)(char **ids);
extern void (*ValkeyModule_SetClusterFlags)(ValkeyModuleCtx *ctx, uint64_t flags);
extern unsigned int (*ValkeyModule_ClusterKeySlotC)(const char *key, size_t keylen);
extern unsigned int (*ValkeyModule_ClusterKeySlot)(ValkeyModuleString *key);
extern const char *(*ValkeyModule_ClusterCanonicalKeyNameInSlot)(unsigned int slot);

/* -- Random & Utility ------------------------------------------------- */
extern void (*ValkeyModule_GetRandomBytes)(unsigned char *dst, size_t len);
extern void (*ValkeyModule_GetRandomHexChars)(char *dst, size_t len);
extern int (*ValkeyModule_AvoidReplicaTraffic)(void);
extern void (*ValkeyModule_Yield)(ValkeyModuleCtx *ctx, int flags, const char *busy_reply);
extern void (*ValkeyModule_LatencyAddSample)(const char *event, mstime_t latency);

/* -- Memory Usage Metrics ---------------------------------------------- */
extern float (*ValkeyModule_GetUsedMemoryRatio)(void);
extern size_t (*ValkeyModule_MallocSize)(void *ptr);
extern size_t (*ValkeyModule_MallocUsableSize)(void *ptr);
extern size_t (*ValkeyModule_MallocSizeString)(ValkeyModuleString *str);
extern size_t (*ValkeyModule_MallocSizeDict)(ValkeyModuleDict *dict);

/* -- Time Functions (Additional) -------------------------------------- */
extern ustime_t (*ValkeyModule_Microseconds)(void);
extern ustime_t (*ValkeyModule_CachedMicroseconds)(void);

/* -- Memory & Utility (Additional) ------------------------------------- */
extern void *(*ValkeyModule_TryAlloc)(size_t bytes);
extern void *(*ValkeyModule_TryCalloc)(size_t nmemb, size_t size);
extern void *(*ValkeyModule_TryRealloc)(void *ptr, size_t bytes);
extern void *(*ValkeyModule_PoolAlloc)(ValkeyModuleCtx *ctx, size_t bytes);
extern void *(*ValkeyModule_GetSharedAPI)(ValkeyModuleCtx *ctx, const char *apiname);

/* -- Key/Channel Positioning ------------------------------------------ */
extern int (*ValkeyModule_IsKeysPositionRequest)(ValkeyModuleCtx *ctx);
extern void (*ValkeyModule_KeyAtPos)(ValkeyModuleCtx *ctx, int pos);
extern void (*ValkeyModule_KeyAtPosWithFlags)(ValkeyModuleCtx *ctx, int pos, int flags);
extern int (*ValkeyModule_IsChannelsPositionRequest)(ValkeyModuleCtx *ctx);
extern void (*ValkeyModule_ChannelAtPosWithFlags)(ValkeyModuleCtx *ctx, int pos, int flags);

/* -- Notifications ---------------------------------------------------- */
extern void (*ValkeyModule_NotifyKeyspaceEvent)(ValkeyModuleCtx *ctx, int type, const char *event, ValkeyModuleString *key);
extern int (*ValkeyModule_SubscribeToKeyspaceEvents)(ValkeyModuleCtx *ctx, int types);
extern int (*ValkeyModule_GetNotifyKeyspaceEvents)(void);
extern int (*ValkeyModule_GetKeyspaceNotificationFlagsAll)(void);
extern int (*ValkeyModule_IsSubEventSupported)(uint64_t event, uint64_t subevent);

/* -- Thread Safe Context ---------------------------------------------- */
extern ValkeyModuleCtx *(*ValkeyModule_GetThreadSafeContext)(ValkeyModuleCtx *ctx);
extern ValkeyModuleCtx *(*ValkeyModule_GetDetachedThreadSafeContext)(ValkeyModuleCtx *ctx);
extern void (*ValkeyModule_FreeThreadSafeContext)(ValkeyModuleCtx *ctx);
extern void (*ValkeyModule_ThreadSafeContextLock)(ValkeyModuleCtx *ctx);
extern int (*ValkeyModule_ThreadSafeContextTryLock)(ValkeyModuleCtx *ctx);
extern void (*ValkeyModule_ThreadSafeContextUnlock)(ValkeyModuleCtx *ctx);

/* -- KeyOpt Helpers --------------------------------------------------- */
extern int (*ValkeyModule_GetDbIdFromOptCtx)(ValkeyModuleKeyOptCtx *ctx);
extern int (*ValkeyModule_GetToDbIdFromOptCtx)(ValkeyModuleKeyOptCtx *ctx);
extern const ValkeyModuleString *(*ValkeyModule_GetKeyNameFromOptCtx)(ValkeyModuleKeyOptCtx *ctx);
extern const ValkeyModuleString *(*ValkeyModule_GetToKeyNameFromOptCtx)(ValkeyModuleKeyOptCtx *ctx);

/* -- Module Key Helpers ----------------------------------------------- */
extern const ValkeyModuleString *(*ValkeyModule_GetKeyNameFromModuleKey)(ValkeyModuleKey *key);
extern int (*ValkeyModule_GetDbIdFromModuleKey)(ValkeyModuleKey *key);

/* -- Dictionary ------------------------------------------------------- */
extern ValkeyModuleDict *(*ValkeyModule_CreateDict)(ValkeyModuleCtx *ctx);
extern void (*ValkeyModule_FreeDict)(ValkeyModuleCtx *ctx, ValkeyModuleDict *d);
extern uint64_t (*ValkeyModule_DictSize)(ValkeyModuleDict *d);
extern int (*ValkeyModule_DictSetC)(ValkeyModuleDict *d, void *key, size_t keylen, void *ptr);
extern int (*ValkeyModule_DictReplaceC)(ValkeyModuleDict *d, void *key, size_t keylen, void *ptr);
extern int (*ValkeyModule_DictSet)(ValkeyModuleDict *d, ValkeyModuleString *key, void *ptr);
extern int (*ValkeyModule_DictReplace)(ValkeyModuleDict *d, ValkeyModuleString *key, void *ptr);
extern void *(*ValkeyModule_DictGetC)(ValkeyModuleDict *d, void *key, size_t keylen, int *nokey);
extern void *(*ValkeyModule_DictGet)(ValkeyModuleDict *d, ValkeyModuleString *key, int *nokey);
extern int (*ValkeyModule_DictDelC)(ValkeyModuleDict *d, void *key, size_t keylen, void *oldval);
extern int (*ValkeyModule_DictDel)(ValkeyModuleDict *d, ValkeyModuleString *key, void *oldval);
extern ValkeyModuleDictIter *(*ValkeyModule_DictIteratorStartC)(ValkeyModuleDict *d, const char *op, void *key, size_t keylen);
extern ValkeyModuleDictIter *(*ValkeyModule_DictIteratorStart)(ValkeyModuleDict *d, const char *op, ValkeyModuleString *key);
extern void (*ValkeyModule_DictIteratorStop)(ValkeyModuleDictIter *di);
extern void *(*ValkeyModule_DictNextC)(ValkeyModuleDictIter *di, size_t *keylen, void **dataptr);
extern void *(*ValkeyModule_DictPrevC)(ValkeyModuleDictIter *di, size_t *keylen, void **dataptr);
extern ValkeyModuleString *(*ValkeyModule_DictNext)(ValkeyModuleCtx *ctx, ValkeyModuleDictIter *di, void **dataptr);
extern ValkeyModuleString *(*ValkeyModule_DictPrev)(ValkeyModuleCtx *ctx, ValkeyModuleDictIter *di, void **dataptr);
extern int (*ValkeyModule_DictCompareC)(ValkeyModuleDict *d, void *key1, size_t keylen1, void *key2, size_t keylen2);
extern int (*ValkeyModule_DictCompare)(ValkeyModuleDict *d, ValkeyModuleString *key1, ValkeyModuleString *key2);
extern void (*ValkeyModule_DictIteratorReseekC)(ValkeyModuleDictIter *di, void *key, size_t keylen);
extern void (*ValkeyModule_DictIteratorReseek)(ValkeyModuleDictIter *di, ValkeyModuleString *key);

/* -- LRU/LFU --------------------------------------------------------- */
extern unsigned long long (*ValkeyModule_GetLRU)(ValkeyModuleKey *key);
extern void (*ValkeyModule_SetLRU)(ValkeyModuleKey *key, mstime_t lru_idle_time_ms);
extern unsigned long long (*ValkeyModule_GetLFU)(ValkeyModuleKey *key);
extern void (*ValkeyModule_SetLFU)(ValkeyModuleKey *key, long long lfu_freq);

/* -- ACL User Helpers ------------------------------------------------- */
extern int (*ValkeyModule_SetModuleUserACL)(ValkeyModuleUser *user, const char *acl);
extern int (*ValkeyModule_SetModuleUserACLString)(ValkeyModuleCtx *ctx, ValkeyModuleUser *user, const char *acl, ValkeyModuleString **error);
extern int (*ValkeyModule_AddACLCategory)(ValkeyModuleCtx *ctx, const char *name);

/* -- Assert ---------------------------------------------------------- */
extern void (*ValkeyModule__Assert)(const char *estr, const char *file, int line);

]]

return cdef
