cmake_minimum_required(VERSION 3.8)

################################
## Compiler flags
################################

if(PLATFORM_WIN)
	set(CMAKE_CXX_FLAGS "/MP /W3 /GR- /Gy /std:c++17 /wd4577 /wd4653 /wd4530")
	set(CMAKE_CXX_FLAGS_DEBUG "/Zi /Zo /Od /MDd")
	set(CMAKE_CXX_FLAGS_RELEASE "/Ox /GS- /MD /DNDEBUG /D_RELEASE")

	set(CMAKE_C_FLAGS_DEBUG "/Zi /Zo /Gm /Od /MDd")
	set(CMAKE_C_FLAGS_RELEASE "/Ox /GS- /MD /DNDEBUG /D_RELEASE")

	set(MSVC_LINKER_FLAGS "/NOLOGO /DYNAMICBASE")

	set(CMAKE_MODULE_LINKER_FLAGS "${MSVC_LINKER_FLAGS}")
	set(CMAKE_SHARED_LINKER_FLAGS "${MSVC_LINKER_FLAGS}")
	set(CMAKE_EXE_LINKER_FLAGS "${MSVC_LINKER_FLAGS}")

	set(CMAKE_MODULE_LINKER_FLAGS_DEBUG "/DEBUG /INCREMENTAL")
	set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "/DEBUG")
	set(CMAKE_EXE_LINKER_FLAGS_DEBUG "/DEBUG")

	set(CMAKE_MODULE_LINKER_FLAGS_RELEASE "/OPT:REF /INCREMENTAL")
	set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "/OPT:REF")
	set(CMAKE_EXE_LINKER_FLAGS_RELEASE "/OPT:REF")
endif()

if(PLATFORM_XENON)
	set(CXX_COMMON_FLAGS
		/TP				# Enable C++
    	/W3             # Set warning level to 3
    	/wd4996         # Ignore deprecation warnings
		/GF             # Enable read-only string pooling
		/GS-			# Enable buffer security checks
		/Gm-             # Enable minimal rebuild
		/fp:fast		# Fast floating point (less predictable)
		/Os				# Favour small code
		/Gy             # Enable function level linking
		/Zc:wchar_t-    # Set wchar_t as an interal type
	)

	string(REPLACE ";" " " CXX_COMMON_FLAGS "${CXX_COMMON_FLAGS}")

	set(CMAKE_CXX_FLAGS "${CXX_COMMON_FLAGS}")
	set(CMAKE_CXX_FLAGS_DEBUG "/MTd")
	set(CMAKE_CXX_FLAGS_RELEASE "/MT /Ox")

	# MSVC Common linker flags
	set(MSVC_LINKER_FLAGS "/NOLOGO /INCREMENTAL:NO /manifest:no")

	set(CMAKE_MODULE_LINKER_FLAGS "${MSVC_LINKER_FLAGS}")
	set(CMAKE_SHARED_LINKER_FLAGS "${MSVC_LINKER_FLAGS} /dll /ALIGN:128,4096")
	set(CMAKE_EXE_LINKER_FLAGS "${MSVC_LINKER_FLAGS}")

	set(CMAKE_MODULE_LINKER_FLAGS_DEBUG "/DEBUG")
	set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "/DEBUG /INCREMENTAL:NO")
	set(CMAKE_EXE_LINKER_FLAGS_DEBUG "/DEBUG")

	set(CMAKE_MODULE_LINKER_FLAGS_RELEASE "/LTCG")
	set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "/LTCG /INCREMENTAL:NO /OPT:ICF")
	set(CMAKE_EXE_LINKER_FLAGS_RELEASE "/LTCG")

	set(XBOX360_DEFINITIONS
		-D_XBOX
		-DXBOX
		-D_MBCS
	)

	string(REPLACE ";" " " XBOX360_DEFINITIONS "${XBOX360_DEFINITIONS}")

	add_definitions(${XBOX360_DEFINITIONS})

	# Clear default libraries
	set(CMAKE_CXX_STANDARD_LIBRARIES "")

	if(CMAKE_BUILD_TYPE MATCHES "Release")
		# Set common libraries
		set(XBOX360_LIBRARIES
			"libcMT.lib"
			"vcomp.lib"
			"xboxkrnl.lib"
			"xapilib.lib"
			"xnet.lib"
			"xaudio2.lib"
			"xact3.lib"
			"d3d9.lib"
			"d3d9i.lib"
			"xgraphics.lib"
			"d3dx9.lib"
			"xavatar2.lib"
			"xhttp.lib"
			"xauth.lib"
			"xonline.lib"
			"xuihtml.lib"
			"xuirender.lib"
			"xuirun.lib"
			"xime.lib"

			# === PASS 1: Base tracking engines ===
			"st.lib"           # <-- The missing Skeletal Tracking lib
			"xmcore.lib"
			"nuifitnessapi.lib"

			# === PASS 2: NUI APIs & JSON ===
			"xjson.lib"
			"nuihandles.lib"
			"nuiapi.lib"

			# === PASS 3: Resolve circular references ===
			"st.lib"
			"xmcore.lib"
			"nuifitnessapi.lib"
		)
	else()
		# Set common libraries
		set(XBOX360_LIBRARIES
			"libcMTD.lib"       # <-- Critical: Debug runtime library
			"vcompd.lib"        # <-- Debug OpenMP
			"xboxkrnl.lib"      # Kernel remains the same
			"xapilibd.lib"      # <-- Debug APIs
			"xnetd.lib"
			"xaudio2.lib"
			"xact3.lib"
			"d3d9d.lib"
			"d3d9i.lib"
			"xgraphicsd.lib"
			"d3dx9d.lib"
			"xavatar2d.lib"
			"xhttpd.lib"
			"xauthd.lib"
			"xonlined.lib"
			"xuihtmld.lib"
			"xuirenderd.lib"
			"xuirund.lib"
			"ximed.lib"

			# Base tracking engines (Debug variants)
			"std.lib"
			"xmcored.lib"
			"nuifitnessapid.lib"

			# NUI APIs & JSON (Debug variants)
			"xjsond.lib"
			"nuihandlesd.lib"
			"nuiapid.lib"

			# Circular references (Debug variants)
			"std.lib"
			"xmcored.lib"
			"nuifitnessapid.lib"
		)
		add_link_options("/NODEFAULTLIB:LIBCMT" "/NODEFAULTLIB:XAPILIB")
	endif()

	string(REPLACE ";" " " XBOX360_LIBRARIES "${XBOX360_LIBRARIES}")

	set(CMAKE_CXX_STANDARD_LIBRARIES ${XBOX360_LIBRARIES})

	set(XBOX360_INCLUDE_DIRS
		"${XENON_XDK_ROOT}/include/xbox"
	)

	include_directories(${XBOX360_INCLUDE_DIRS})

	set(XBOX360_LIBRARY_DIRS
		"${XENON_XDK_ROOT}/lib/xbox"
	)

	string(REPLACE ";" "\" /LIBPATH:\"" XBOX360_LIBRARY_DIRS_FIXED "${XBOX360_LIBRARY_DIRS}")
	set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /LIBPATH:\"${XBOX360_LIBRARY_DIRS_FIXED}\"")
endif()