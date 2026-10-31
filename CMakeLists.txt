cmake_minimum_required(VERSION 3.31)
project(Cprojects)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

file(GLOB CPP_SOURCES CONFIGURE_DEPENDS "*.cpp")

foreach(source_file ${CPP_SOURCES})
    get_filename_component(target_name "${source_file}" NAME_WE)
    add_executable("${target_name}" "${source_file}")
endforeach()
