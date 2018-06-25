# Copyright (c) 2012, Google Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     * Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
# copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the
# distribution.
#     * Neither the name of Google Inc. nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# ndk-build module definition for the Google Breakpad client library
#
# To use this file, do the following:
#
#   1/ Include this file from your own Android.mk, either directly
#      or with through the NDK's import-module function.
#
#   2/ Use the client static library in your project with:
#
#      LOCAL_STATIC_LIBRARIES += breakpad_client
#
#   3/ In your source code, include "src/client/linux/exception_handler.h"
#      and use the Linux instructions to use it.
#
# This module works with either the STLport or GNU libstdc++, but you need
# to select one in your Application.mk
#

# The top Google Breakpad directory.
# We assume this Android.mk to be under 'android/google_breakpad'

LOCAL_PATH := $(call my-dir)

# Defube the client library module, as a simple static library that
# exports the right include path / linker flags to its users.

include $(CLEAR_VARS)

LOCAL_MODULE := breakpad_processor

LOCAL_CPP_EXTENSION := .cc

# Breakpad uses inline ARM assembly that requires the library
# to be built in ARM mode. Otherwise, the build will fail with
# cryptic assembler messages like:
#   Compile++ thumb  : google_breakpad_client <= crash_generation_client.cc
#   /tmp/cc8aMSoD.s: Assembler messages:
#   /tmp/cc8aMSoD.s:132: Error: invalid immediate: 288 is out of range
#   /tmp/cc8aMSoD.s:244: Error: invalid immediate: 296 is out of range
LOCAL_ARM_MODE := arm

# List of client source files, directly taken from Makefile.am
LOCAL_SRC_FILES 	+=\
	$(MY_APP_JNI_ROOT)/src/processor/basic_code_modules.cc \
	$(MY_APP_JNI_ROOT)/src/processor/basic_source_line_resolver.cc\
	$(MY_APP_JNI_ROOT)/src/processor/call_stack.cc\
	$(MY_APP_JNI_ROOT)/src/processor/cfi_frame_info.cc\
	$(MY_APP_JNI_ROOT)/src/processor/dump_context.cc\
	$(MY_APP_JNI_ROOT)/src/processor/dump_object.cc\
	$(MY_APP_JNI_ROOT)/src/processor/exploitability.cc\
	$(MY_APP_JNI_ROOT)/src/processor/exploitability_linux.cc\
	$(MY_APP_JNI_ROOT)/src/processor/logging.cc\
	$(MY_APP_JNI_ROOT)/src/processor/minidump.cc\
	$(MY_APP_JNI_ROOT)/src/processor/minidump_processor.cc\
	$(MY_APP_JNI_ROOT)/src/processor/pathname_stripper.cc\
	$(MY_APP_JNI_ROOT)/src/processor/process_state.cc\
	$(MY_APP_JNI_ROOT)/src/processor/proc_maps_linux.cc\
	$(MY_APP_JNI_ROOT)/src/processor/simple_symbol_supplier.cc\
	$(MY_APP_JNI_ROOT)/src/processor/source_line_resolver_base.cc\
	$(MY_APP_JNI_ROOT)/src/processor/stack_frame_cpu.cc\
	$(MY_APP_JNI_ROOT)/src/processor/stack_frame_symbolizer.cc\
	$(MY_APP_JNI_ROOT)/src/processor/stackwalker.cc\
	$(MY_APP_JNI_ROOT)/src/processor/stackwalk_common.cc\
	$(MY_APP_JNI_ROOT)/src/processor/stackwalker_amd64.cc\
	$(MY_APP_JNI_ROOT)/src/processor/stackwalker_arm.cc\
	$(MY_APP_JNI_ROOT)/src/processor/stackwalker_arm64.cc\
	$(MY_APP_JNI_ROOT)/src/processor/stackwalker_address_list.cc\
	$(MY_APP_JNI_ROOT)/src/processor/stackwalker_mips.cc\
	$(MY_APP_JNI_ROOT)/src/processor/stackwalker_ppc.cc\
	$(MY_APP_JNI_ROOT)/src/processor/stackwalker_ppc64.cc\
	$(MY_APP_JNI_ROOT)/src/processor/stackwalker_sparc.cc\
	$(MY_APP_JNI_ROOT)/src/processor/stackwalker_x86.cc\
	$(MY_APP_JNI_ROOT)/src/processor/tokenize.cc

LOCAL_C_INCLUDES        := $(MY_APP_JNI_ROOT)/src/common/android/include \
                           $(MY_APP_JNI_ROOT)/src \
                           $(MY_APP_JNI_ROOT)

#LOCAL_EXPORT_C_INCLUDES := $(LOCAL_C_INCLUDES)
#LOCAL_EXPORT_LDLIBS     := -llog
LOCAL_LDLIBS             := -llog -latomic

LOCAL_SHARED_LIBRARIES :=
LOCAL_STATIC_LIBRARIES :=

ifeq ($(IS_ENABLE_STATIC_LIB),false)
##单独编译动态库
LOCAL_SRC_FILES += minidump_stackwalk.cc
LOCAL_SRC_FILES += breakpad_processor_jni.cc 
include $(BUILD_SHARED_LIBRARY)
else
include $(BUILD_STATIC_LIBRARY)
#minidump_stackwalk exe file
include $(CLEAR_VARS)
LOCAL_MODULE := minidump_stackwalk
LOCAL_CPP_EXTENSION := .cc
LOCAL_SRC_FILES := minidump_stackwalk_exe.cc 
LOCAL_C_INCLUDES        := $(MY_APP_JNI_ROOT)/src/common/android/include \
                           $(MY_APP_JNI_ROOT)/src \
                           $(MY_APP_JNI_ROOT)
LOCAL_LDLIBS             := -llog -latomic

LOCAL_SHARED_LIBRARIES := 
LOCAL_STATIC_LIBRARIES := breakpad_processor
include $(BUILD_EXECUTABLE)
endif

# Done.
