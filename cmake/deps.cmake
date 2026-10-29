if(CMAKE_CXX_COMPILER_ID MATCHES "GNU" AND WIN32)
    add_compile_options("-Wa,-mbig-obj")
endif()

set(CMAKE_COMPILE_WARNING_AS_ERROR OFF)
add_compile_options("-w")

# cmake/Dependencies.cmake

# Suppress "The OLD behavior for policy CMP0141 will be removed from a future version of CMake"
set(CMAKE_POLICY_WARNING_CMP0141 OFF CACHE INTERNAL "")

include(FetchContent)
set(DEPS_LIST)
list(APPEND DEPS_LIST SFML          3.1.0           https://github.com/SFML/SFML.git)
list(APPEND DEPS_LIST GTest         v1.18.0         https://github.com/google/googletest.git)
list(APPEND DEPS_LIST reflect-cpp   v0.26.2         https://github.com/munich-data-engineering/reflect-cpp)
list(APPEND DEPS_LIST Protobuf      v36.2           https://github.com/protocolbuffers/protobuf.git)
list(APPEND DEPS_LIST spdlog        v1.17.0         https://github.com/gabime/spdlog.git)
list(APPEND DEPS_LIST CLI11         v2.7.2          https://github.com/CLIUtils/CLI11.git)
list(APPEND DEPS_LIST BOOST_Asio    boost-1.92.0    https://github.com/boostorg/asio.git)

function(fetch_dep name tag url)
    MESSAGE(STATUS "Fetching ${name} ${tag} from ${url}")
    FetchContent_Declare(
            ${name}
            GIT_REPOSITORY ${url}
            GIT_TAG        ${tag}
            SYSTEM
            EXCLUDE_FROM_ALL
    )

    FetchContent_MakeAvailable(${name})
endfunction()

list(LENGTH DEPS_LIST deps_length)
math(EXPR deps_last "${deps_length} - 1")

foreach(i RANGE 0 ${deps_last} 3)
    math(EXPR i2 "${i} + 1")
    math(EXPR i3 "${i} + 2")

    list(GET DEPS_LIST ${i} dep)
    list(GET DEPS_LIST ${i2} tag)
    list(GET DEPS_LIST ${i3} url)

    fetch_dep("${dep}" "${tag}" "${url}")
endforeach()

# Standalone Boost.Asio interface target
add_library(boost_asio_standalone INTERFACE)
target_include_directories(boost_asio_standalone SYSTEM INTERFACE
        ${boost_asio_SOURCE_DIR}/include
)
target_compile_definitions(boost_asio_standalone INTERFACE
        BOOST_ASIO_STANDALONE
)

# =====================================================================
# ENCAPSULATION WRAPPER
# =====================================================================
function(target_link_project_dependencies target_name)
    # 1. Centralized Library Linking List
    target_link_libraries(${target_name}
            PRIVATE SFML::System
            PRIVATE SFML::Window
            PRIVATE SFML::Graphics
            PRIVATE SFML::Network
            PRIVATE SFML::Audio
            PRIVATE reflectcpp
            PRIVATE protobuf::libprotobuf
            PRIVATE spdlog::spdlog
            PRIVATE CLI11::CLI11
            PRIVATE GTest::gtest
            PRIVATE boost_asio_standalone
    )

    # 2. Encapsulated Post-Build Copying for Shared Libs (DLLs)
    add_custom_command(TARGET ${target_name} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<TARGET_RUNTIME_DLLS:${target_name}>
            $<TARGET_FILE_DIR:${target_name}>
            COMMAND_EXPAND_LISTS
    )
endfunction()
