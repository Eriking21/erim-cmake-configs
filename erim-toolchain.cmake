if(DEFINED ENV{EMSDK} AND (CMAKE_C_COMPILER_ID STREQUAL "Emscripten" OR CMAKE_CXX_COMPILER_ID STREQUAL "Emscripten"))
    set(ERIM_EMSDK_UPSTREAM "$ENV{EMSDK}/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake")
    message(VERBOSE "including EMSDK toolchain")
    if(EXISTS "${ERIM_EMSDK_UPSTREAM}")
        include("${ERIM_EMSDK_UPSTREAM}")
    else()
        message(WARNING "EMSDK file not found: ${ERIM_EMSDK_UPSTREAM}")
    endif()
endif()

set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE BOOL "Export compile commands" FORCE)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_C_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_VERBOSE_MAKEFILE ON)
set(CXX_SCAN_FOR_MODULES ON)
set(CMAKE_CXX_SCAN_FOR_MODULES ON)
set(CMAKE_EXPERIMENTAL_CXX_MODULES ON)
set(CMAKE_EXPERIMENTAL_CXX_MODULE_DYNDEP 1)
set(CMAKE_EXPERIMENTAL_CXX_MODULE_CMAKE_API "2182bf5c-ef0d-489a-91da-49dbc3090d2a") # Required

function(__erim_filter_all_interfaces all_targets)
    list(REMOVE_ITEM all_targets PUBLIC PRIVATE INTERFACE)
    set(all_interfaces)
    foreach(target IN LISTS all_targets)
        get_target_property(target_type ${target} TYPE)
        if(${target_type} STREQUAL "STATIC_LIBRARY")
            get_target_property(target_srcs ${target} SOURCES)
            if(${target_srcs} STREQUAL "target_srcs-NOTFOUND")
                list(APPEND all_interfaces ${target})
            endif()
        endif()
    endforeach()
    set(all_interfaces "${all_interfaces}" PARENT_SCOPE)
endfunction()

function(__erim_create_target target_name ...)
    set(target_type ${ARGV1})
    set(target_libs ${ARGV})
    list(REMOVE_AT target_libs 0)
    list(REMOVE_AT target_libs 0)
    string(TOLOWER "${target_type}" type)
    # message("oi: ${target_libs}")
    __erim_filter_all_interfaces("${target_libs}")

    set(target_sources ${ALL_SOURCES})
    set(target_public_modules ${ALL_MODULES})
    set(target_private_modules ${ALL_MODULES})

    # Filter sources and modules by target name
    list(FILTER target_public_modules INCLUDE REGEX "${target_name}/[^/]+$")
    list(FILTER target_private_modules INCLUDE REGEX "${target_name}/[^/]+/.+$")
    list(FILTER target_sources INCLUDE REGEX "${target_name}/.*$")

    # Create target
    if(type MATCHES "^static(-)?(lib)?$")
        add_library(${target_name} STATIC)
        set_target_properties(${target_name} PROPERTIES
            CXX_VISIBILITY_PRESET default
            C_VISIBILITY_PRESET default
            VISIBILITY_INLINES_HIDDEN ON
        )
        target_sources(${target_name}
            PRIVATE ${target_sources}
            PUBLIC FILE_SET CXX_MODULES FILES ${target_public_modules}
            ${target_private_modules}
        )
        target_precompile_headers(${target_name} PRIVATE "${PROJECT_SOURCE_DIR}/expose.hxx")
        if(NOT target_libs STREQUAL "")
            target_link_libraries(${target_name} PRIVATE ${target_libs})
        endif()
        return()
    elseif(type MATCHES "^exe(c(utable)?)?$")
        add_executable(${target_name})
    elseif(type MATCHES "^shared(-)?(lib)?$")
        add_library(${target_name} SHARED)
    else()
        message(FATAL_ERROR "Unknown target type: '${target_name} ${target_type}'")
        return()
    endif()
    target_precompile_headers(${target_name} PRIVATE "${PROJECT_SOURCE_DIR}/expose.hxx")
    set_target_properties(${target_name} PROPERTIES
        CXX_VISIBILITY_PRESET hidden
        C_VISIBILITY_PRESET hidden
        VISIBILITY_INLINES_HIDDEN OFF
    )
    # Attach sources and modules
    set(private_target_name "")
    set(public_target_name "")

    set(public_target_name "")
    if(NOT target_public_modules STREQUAL "")
        set(public_target_name "${target_name}-public")
        add_library(${public_target_name} STATIC)
        set_target_properties("${public_target_name}" PROPERTIES
            CXX_VISIBILITY_PRESET default
            C_VISIBILITY_PRESET default
            VISIBILITY_INLINES_HIDDEN ON
        )
        target_sources(${public_target_name}
            PUBLIC FILE_SET CXX_MODULES FILES ${target_public_modules})
        list(APPEND target_libs "PUBLIC;${public_target_name}")
    endif()

    if(NOT target_private_modules STREQUAL "")
        set(private_target_name "${target_name}-private")
        add_library(${private_target_name} STATIC)
        set_target_properties("${private_target_name}" PROPERTIES
            CXX_VISIBILITY_PRESET default
            C_VISIBILITY_PRESET default
            VISIBILITY_INLINES_HIDDEN ON
        )
        target_sources(${private_target_name}
            PUBLIC FILE_SET CXX_MODULES FILES ${target_private_modules})

        if(NOT target_public_modules STREQUAL "")
            target_link_libraries(${private_target_name} PRIVATE ${public_target_name})
        endif()
        if(NOT all_interfaces STREQUAL "")
            target_link_libraries(${private_target_name} PRIVATE ${all_interfaces})
        endif()
        list(APPEND target_libs "PRIVATE;${private_target_name}")
    endif()

    target_sources(${target_name}
        PRIVATE ${target_sources}
    )
    if(NOT target_libs STREQUAL "")
        target_link_libraries(${target_name} PRIVATE ${target_libs})
    endif()
    set("${target_name}_libs" "${target_libs}" PARENT_SCOPE)
endfunction()

function(__erim_prebuild_modules)
    get_property(all_targets DIRECTORY ${PROJECT_SOURCE_DIR} PROPERTY BUILDSYSTEM_TARGETS)
    set(all_interfaces)
    foreach(target IN LISTS all_targets)
        get_target_property(target_type ${target} TYPE)
        get_target_property(target_srcs ${target} SOURCES)
        if(${target_type} STREQUAL "STATIC_LIBRARY")
            if(${target_srcs} STREQUAL "target_srcs-NOTFOUND")
                list(APPEND all_interfaces "--target ${target}")
            endif()
        endif()
    endforeach()
    if(all_interfaces)
        message("out: ${all_interfaces}")
        execute_process(
            COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --parallel
            ${all_interfaces}
        )
    endif()
endfunction()

function(ERIM_SET_SYSTEM_INCLUDES)
    string(REGEX REPLACE "/usr/bin/" "" COMPILER ${CMAKE_C_COMPILER})
    execute_process(
        COMMAND pacman -Ql ${COMPILER}
        COMMAND grep stddef.h
        OUTPUT_VARIABLE VAR
    )
    string(REGEX REPLACE "${COMPILER} " "" VAR "${VAR}")
    string(REGEX REPLACE "/stddef.h\n" "" VAR "${VAR}")
    include_directories(
        SYSTEM /usr/include
        SYSTEM /usr/local/include
        SYSTEM ${VAR}
    )
    set(COMPILER_INCLUDES ${VAR} PARENT_SCOPE)
    message("erim included: ${VAR}")
endfunction()


function(ERIM_SET_BUILD_TARGETS)
    file(GLOB src_files LIST_DIRECTORIES true "src/*")

    foreach(folder ${src_files})
        if(IS_DIRECTORY ${folder})
            get_filename_component(folder_name ${folder} NAME)
            string(REPLACE " " "_" folder_name ${folder_name})
            file(GLOB_RECURSE src_files "${folder}/*.cpp" "${folder}/*.cc" "${folder}/*.c++" "${folder}/*.cxx")
            foreach(src ${src_files})
                if(src MATCHES "^${folder}/main.c*")
                    message(STATUS "erim added the executable : ${folder_name}")
                    add_executable("${folder_name}" ${src_files})
                elseif(src MATCHES "^${folder}/shared.c*")
                    message(STATUS "erim added shared library : ${folder_name}")
                    add_library("${folder_name}" SHARED ${src_files})
                elseif(src MATCHES "^${folder}/lib.c*")
                    message(STATUS "erim added shared library : ${folder_name}")
                    add_library("${folder_name}" STATIC ${src_files})
                endif()
            endforeach()
        endif()
    endforeach()
endfunction()
