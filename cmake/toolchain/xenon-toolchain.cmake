set(XENON_TOOLCHAIN 1)

# Get the XDK installation root
if(EXISTS "$ENV{XEDK}" AND IS_DIRECTORY "$ENV{XEDK}")
    string(REGEX REPLACE "\\\\" "/" XENON_XDK_ROOT $ENV{XEDK})
    string(REGEX REPLACE "//" "/" XENON_XDK_ROOT ${XENON_XDK_ROOT})
endif()

if(NOT XENON_XDK_ROOT)
    message(FATAL_ERROR "Invalid Xbox 360 XDK root. Please install the Xbox 360 XDK and try again.")
endif()

# Get tools path
set(XENON_XDK_COMPILER_DIR "${XENON_XDK_ROOT}/bin/win32")
if(NOT XENON_XDK_COMPILER_DIR)
    message(FATAL_ERROR "Unable to find Xbox 360 XDK compiler tools.")
endif()

set(CMAKE_SYSTEM_NAME Xenon)
set(CMAKE_CROSSCOMPILING ON)
set(XENON true)

# set(CMAKE_SYSROOT "${XENON_XDK_COMPILER_DIR}")

# Force MSVC compiler identification behavior on Linux
set(CMAKE_C_COMPILER_ID "MSVC")
set(CMAKE_CXX_COMPILER_ID "MSVC")
set(CMAKE_C_SIMULATE_ID "MSVC")
set(CMAKE_CXX_SIMULATE_ID "MSVC")
set(CMAKE_COMPILER_IS_GNUCXX 0)
set(CMAKE_COMPILER_IS_GNUC 0)

# Force MSVC style object file extensions (.obj instead of .o)
set(CMAKE_C_OUTPUT_EXTENSION ".obj")
set(CMAKE_CXX_OUTPUT_EXTENSION ".obj")

# Configure dependency tracking to use MSVC style includes rather than GNU -MF flags
set(CMAKE_DEPFILE_FLAGS_C "/showIncludes")
set(CMAKE_DEPFILE_FLAGS_CXX "/showIncludes")

# 1. Strip out Linux-specific PIC (Position Independent Code) flags
set(CMAKE_SHARED_LIBRARY_C_FLAGS "")
set(CMAKE_SHARED_LIBRARY_CXX_FLAGS "")
set(CMAKE_SHARED_LIBRARY_CREATE_C_FLAGS "")
set(CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS "")
set(CMAKE_POSITION_INDEPENDENT_CODE OFF)

# 2. Force MSVC Object file extension again (overriding platform defaults)
set(CMAKE_C_OUTPUT_EXTENSION ".obj")
set(CMAKE_CXX_OUTPUT_EXTENSION ".obj")

# 3. Explicitly overwrite the compilation command templates to use MSVC syntax (/Fo)
set(CMAKE_C_COMPILE_OBJECT   "<CMAKE_C_COMPILER> <DEFINES> <INCLUDES> <FLAGS> /Fo<OBJECT> -c <SOURCE>")
set(CMAKE_CXX_COMPILE_OBJECT "<CMAKE_CXX_COMPILER> <DEFINES> <INCLUDES> <FLAGS> /Fo<OBJECT> -c <SOURCE>")

# 4. Explicitly overwrite the linker templates to use MSVC syntax (/OUT:)
set(CMAKE_C_LINK_EXECUTABLE   "<CMAKE_LINKER> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> /OUT:<TARGET> <LINK_LIBRARIES>" CACHE STRING "" FORCE)
set(CMAKE_CXX_LINK_EXECUTABLE "<CMAKE_LINKER> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> /OUT:<TARGET> <LINK_LIBRARIES>" CACHE STRING "" FORCE)

# 5. Explicitly overwrite the shared library/DLL linker templates
set(CMAKE_C_CREATE_SHARED_LIBRARY   "<CMAKE_LINKER> /DLL <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> /OUT:<TARGET> <LINK_LIBRARIES>" CACHE STRING "" FORCE)
set(CMAKE_CXX_CREATE_SHARED_LIBRARY "<CMAKE_LINKER> /DLL <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> /OUT:<TARGET> <LINK_LIBRARIES>" CACHE STRING "" FORCE)
# Force object extension globally
set(CMAKE_C_OUTPUT_EXTENSION ".obj" CACHE STRING "Result extension" FORCE)
set(CMAKE_CXX_OUTPUT_EXTENSION ".obj" CACHE STRING "Result extension" FORCE)

# Completely nullify the flags CMake uses to inject position-independent code (-fPIC)
set(CMAKE_C_COMPILE_OPTIONS_PIC "" CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILE_OPTIONS_PIC "" CACHE STRING "" FORCE)
set(CMAKE_SHARED_LIBRARY_C_FLAGS "" CACHE STRING "" FORCE)
set(CMAKE_SHARED_LIBRARY_CXX_FLAGS "" CACHE STRING "" FORCE)

# Use the Xbox 360 XDK compilers
if(CMAKE_HOST_WIN32)
set(CMAKE_C_COMPILER "${XENON_XDK_COMPILER_DIR}/cl.exe")
set(CMAKE_CXX_COMPILER "${XENON_XDK_COMPILER_DIR}/cl.exe")
set(CMAKE_ASM_COMPILER "${XENON_XDK_COMPILER_DIR}/ml.exe")
set(CMAKE_LINKER "${XENON_XDK_COMPILER_DIR}/link.exe")
else()
set(CMAKE_C_COMPILER "${CMAKE_CURRENT_LIST_DIR}/../scripts/cl-wrapper.sh")
set(CMAKE_CXX_COMPILER "${CMAKE_CURRENT_LIST_DIR}/../scripts/cl-wrapper.sh")
set(CMAKE_ASM_COMPILER "${XENON_XDK_COMPILER_DIR}/ml.exe")
set(CMAKE_LINKER "${CMAKE_CURRENT_LIST_DIR}/../scripts/link-wrapper.sh")
endif()

# Skip compiler detection info
set(CMAKE_C_COMPILER_FORCED true)
set(CMAKE_CXX_COMPILER_FORCED true)
set(CMAKE_ASM_COMPILER_FORCED true)

# Make the Xbox 360 XDK our only focus
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)