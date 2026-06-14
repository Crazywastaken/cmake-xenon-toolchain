#!/bin/bash
# cl-wrapper.sh

XDK_CL="$XEDK/bin/win32/cl.exe"

# NEW: Define the Windows-style paths to the XDK include directories.
# These match where the XDK headers live inside your Wine environment.
XDK_INC_1="$XEDK\\include\\xbox"
# If your XDK has a standard CRT include folder, add it here separated by a semicolon:
# XDK_INC_2="Z:\\hdd\\Program Files (x86)\\Microslop Xbox 360 SDK\\include\\crt"

# Export the INCLUDE variable so cl.exe automatically finds stdlib.h, string.h, etc.
export INCLUDE="${XDK_INC_1}"

ARGS=()
for arg in "$@"; do
    # 1. Ignore entirely empty arguments safely
    if [[ -z "$arg" ]]; then
        continue
    fi

    # NEW: Drop incompatible GNU warning flags completely
    if [[ "$arg" == "-Wall" || "$arg" == "-Wextra" || "$arg" == "-Wpedantic" ]]; then
        continue
    fi

    # 2. Handle specific prefixed paths
    if [[ "$arg" == /Fo* ]]; then
        ARGS+=("/Fo$(winepath -w "${arg#/Fo}")")
    elif [[ "$arg" == /I* ]]; then
        ARGS+=("/I$(winepath -w "${arg#/I}")")

    # 3. Handle actual source and object files (absolute or relative)
    elif [[ "$arg" == *.c || "$arg" == *.cpp || "$arg" == *.o || "$arg" == *.obj ]]; then
        ARGS+=("$(winepath -w "$arg")")

    # 4. Handle other absolute Linux paths ONLY if they actually exist on disk
    elif [[ "$arg" == /* && -e "$arg" ]]; then
        ARGS+=("$(winepath -w "$arg")")

    # 5. Everything else is an MSVC compiler flag (like /TP, /W3) or definition (-D_XBOX)
    else
        ARGS+=("$arg")
    fi
done

wine "$XDK_CL" "${ARGS[@]}"
