
register_flag_optional(CMAKE_CXX_COMPILER
        "Any CXX compiler that is supported by CMake detection. If it is Clang based, it must be a HIP compiler
         (e.g hipcc). Otherwise CMake's HIP language is used (requires CMake >= 3.21)"
        "c++")

register_flag_optional(CMAKE_HIP_COMPILER
        "Path to the HIP compiler (e.g amdclang++) for CMake's HIP language.
         Set the GPU architectures with CMAKE_HIP_ARCHITECTURES (e.g `gfx90a`)"
        "")

register_flag_optional(MEM "Device memory mode:
        DEFAULT   - allocate host and device memory pointers.
        MANAGED   - use HIP Managed Memory.
        PAGEFAULT - shared memory, only host pointers allocated."
        "DEFAULT")

macro(setup)
    register_definitions(${MEM})

    if (NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        if (CMAKE_VERSION VERSION_LESS "3.21.0")
            message(FATAL_ERROR "Using the HIP language requires CMake >= 3.21")
        endif ()
        set(CMAKE_HIP_STANDARD ${CMAKE_CXX_STANDARD})
        enable_language(HIP)
        set_source_files_properties(${IMPL_SOURCES} PROPERTIES LANGUAGE HIP)

        # CMake defaults to -O2 for HIP at Release, let's wipe that and use the global RELEASE_FLAG
        # appended later
        wipe_gcc_style_optimisation_flags(CMAKE_HIP_FLAGS_${BUILD_TYPE})
    endif ()
    # otherwise the C++ compiler is a HIP compiler, and hipcc does everything correctly, what a surprise!
endmacro()
