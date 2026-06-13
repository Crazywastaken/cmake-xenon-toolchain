#!/bin/bash
# link-wrapper.sh

XDK_LINK="$XEDK/bin/win32/link.exe"

ARGS=()
for arg in "$@"; do
    # 1. Ignore entirely empty arguments
    if [[ -z "$arg" ]]; then
        continue
    fi

    # 2. Drop GNU flags
    if [[ "$arg" == -Wl,* ]]; then
        continue

    # 3. Handle specific prefixed paths
    elif [[ "$arg" == -L* ]]; then
        PATH_PART="${arg#-L}"
        PATH_PART="${PATH_PART%\"}"
        PATH_PART="${PATH_PART#\"}"
        ARGS+=("/LIBPATH:$(winepath -w "$PATH_PART")")
    elif [[ "$arg" == /OUT:* ]]; then
        ARGS+=("/OUT:$(winepath -w "${arg#/OUT:}")")
    elif [[ "$arg" == /XEXCONFIG:* ]]; then
        ARGS+=("/XEXCONFIG:$(winepath -w "${arg#/XEXCONFIG:}")")

    # 4. Handle object files and libraries
    # NEW: Only use winepath if it's an absolute path (starts with /).
    # If it's just a naked filename (like xboxkrnl.lib), pass it straight through!
    elif [[ "$arg" == *.o || "$arg" == *.obj || "$arg" == *.lib || "$arg" == *.a ]]; then
        if [[ "$arg" == /* ]]; then
            ARGS+=("$(winepath -w "$arg")")
        else
            ARGS+=("$arg")
        fi

    # 5. Handle other absolute Linux paths ONLY if they actually exist on disk
    elif [[ "$arg" == /* && -e "$arg" ]]; then
        ARGS+=("$(winepath -w "$arg")")

    # 6. Everything else is a linker flag (/DLL, /NOLOGO)
    else
        ARGS+=("$arg")
    fi
done

wine "$XDK_LINK" "${ARGS[@]}"
