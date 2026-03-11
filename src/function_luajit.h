/*
 * Copyright (c) Valkey Contributors
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 *
 * FUNCTION subsystem support for the LuaJIT engine module.
 *
 * In the per-user architecture, compile_code uses a scratch lua_State to
 * run the library top-level code (which calls server.register_function),
 * then stores the library source code and function metadata.
 */

#ifndef _FUNCTION_LUAJIT_H_
#define _FUNCTION_LUAJIT_H_

#include "valkeymodule.h"
#include "engine_structs.h"

ValkeyModuleScriptingEngineCompiledFunction **luajitFunctionLibraryCreate(
    lua_State *lua,
    const char *code,
    size_t code_len,
    size_t timeout,
    size_t *out_num_compiled_functions,
    ValkeyModuleString **err);

void luajitInitFunctionScratchState(luajitEngineCtx *ctx, lua_State *lua);

#endif
