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
    add_executable("${target_name}" EXCLUDE_FROM_ALL "${source_file}"
            "LeetCode/2. 两数相加.cpp"
            "LeetCode/3. 无重复字符的最长子串.cpp")
endforeach()
