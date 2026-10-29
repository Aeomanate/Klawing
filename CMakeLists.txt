# CMakeLists.txt
cmake_minimum_required(VERSION 3.28)
project(Klawing VERSION 0.0.0)

set(BUILD_SHARED_LIBS ON)

# Pull in dependency configuration and our wrapper function
include(cmake/deps.cmake)

add_executable(Klawing main.cpp)

target_compile_features(Klawing PRIVATE
        cxx_std_26
)

target_link_project_dependencies(Klawing)

if(MINGW)
    target_compile_options(Klawing PRIVATE
            -Wall -pedantic
            -Wfloat-equal -Wshadow
            -Wcast-align -Wconversion -Wsign-conversion
    )
endif()

if (WIN32 AND CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    target_link_libraries(${PROJECT_NAME} PRIVATE stdc++exp)
endif()

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Setup installation/distribution properties
set(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_SOURCE_DIR}/distribute)

# 1. Define your target properties
set_target_properties(Klawing PROPERTIES
        OUTPUT_NAME "Klawing-${PROJECT_VERSION}"
        RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/build/Klawing-${PROJECT_VERSION}/bin
)

# Find where your compiler lives to automatically grab its 'bin' directory
get_filename_component(MINGW_BIN_DIR "${CMAKE_CXX_COMPILER}" DIRECTORY)

# 2. Install the executable
install(TARGETS Klawing
        RUNTIME DESTINATION bin
)

# 3. Install the MinGW runtime DLLs at install time. install() has no DIRECTORIES or POST_EXCLUDE_REGEXES
#    options; those belong to file(GET_RUNTIME_DEPENDENCIES), which searches MINGW_BIN_DIR for libstdc++-6.dll etc.
#    The actual resolution logic lives in cmake/InstallRuntimeDeps.cmake to avoid embedding a quoted script.
install(CODE "set(KLAWING_EXECUTABLE \"$<TARGET_FILE:Klawing>\")")
install(CODE "set(KLAWING_MINGW_BIN_DIR \"${MINGW_BIN_DIR}\")")
install(SCRIPT cmake/InstallRuntimeDeps.cmake)
