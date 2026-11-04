cmake_minimum_required(VERSION 3.31)
project(Cprojects)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

file(GLOB CPP_SOURCES CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")
file(GLOB_RECURSE PROBLEM_SOURCES CONFIGURE_DEPENDS
        "${CMAKE_CURRENT_SOURCE_DIR}/LeetCode/*.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/Codeforces/*.cpp")
list(APPEND CPP_SOURCES ${PROBLEM_SOURCES})

foreach(source_file ${CPP_SOURCES})
    file(RELATIVE_PATH relative_path "${CMAKE_CURRENT_SOURCE_DIR}" "${source_file}")
    string(REGEX REPLACE "\\.[^.]*$" "" target_name "${relative_path}")
    # Keep Chinese titles in filenames, but use portable target names, e.g. LeetCode_1.
    string(REGEX REPLACE "[^A-Za-z0-9_]+" "_" target_name "${target_name}")
    string(REGEX REPLACE "^_+|_+$" "" target_name "${target_name}")
    if(target_name STREQUAL "" OR TARGET "${target_name}")
        string(SHA256 source_hash "${relative_path}")
        string(SUBSTRING "${source_hash}" 0 12 source_hash)
        set(target_name "problem_${source_hash}")
    endif()

    # Build one selected problem; do not compile the entire collection by default.
    # NOTE: sources are auto-collected by file(GLOB) above -- never append file names here.
    # If CLion offers "Add to CMake target" when creating a file, decline it:
    # anything added below is inserted inside this foreach() and therefore lands in EVERY target.
    add_executable("${target_name}" EXCLUDE_FROM_ALL "${source_file}")

    # Guard against tooling (e.g. CLion's "Add to CMake target") appending sources inside this loop.
    get_target_property(_actual_sources "${target_name}" SOURCES)
    if(NOT _actual_sources STREQUAL source_file)
        message(WARNING
                "Target '${target_name}' got unexpected extra sources: ${_actual_sources}\n"
                "Remove those file names from add_executable() inside the foreach() loop in CMakeLists.txt "
                "-- new .cpp files are picked up automatically by file(GLOB).")
    endif()
endforeach()
