cmake_minimum_required(VERSION 3.28)
project(Klawing)

if(CMAKE_CXX_COMPILER_ID MATCHES "GNU" AND WIN32)
    # Forces the MinGW assembler to support more than 32k sections
    add_compile_options("-Wa,-mbig-obj")
endif()

include(FetchContent)
set(CMAKE_FOLDER_TARGETS_SYSTEM ON)

set(DEPS_LIST)
list(APPEND DEPS_LIST SFML 3.1.0 https://github.com/SFML/SFML.git)
list(APPEND DEPS_LIST GTest v1.18.0 https://github.com/google/googletest.git)
list(APPEND DEPS_LIST reflect-cpp v0.26.2 https://github.com/munich-data-engineering/reflect-cpp)
list(APPEND DEPS_LIST Protobuf v36.2 https://github.com/protocolbuffers/protobuf.git)
list(APPEND DEPS_LIST spdlog v1.17.0 https://github.com/gabime/spdlog.git)
list(APPEND DEPS_LIST CLI11 v2.7.2 https://github.com/CLIUtils/CLI11.git)
list(APPEND DEPS_LIST BOOST_Asio boost-1.92.0 https://github.com/boostorg/asio.git)

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

add_executable(Klawing main.cpp)
set_target_properties(Klawing PROPERTIES CXX_SCAN_FOR_MODULES OFF)

target_compile_features(Klawing PRIVATE
        cxx_std_26
)

# Standalone Boost.Asio interface target
add_library(boost_asio_standalone INTERFACE)
target_include_directories(boost_asio_standalone SYSTEM INTERFACE
        ${boost_asio_SOURCE_DIR}/include
)
target_compile_definitions(boost_asio_standalone INTERFACE
        BOOST_ASIO_STANDALONE
)

if(MINGW)
    target_compile_options(Klawing PRIVATE
            -Wall -pedantic
            -Wfloat-equal -Wshadow
            -Wcast-align -Wconversion -Wsign-conversion
    )
endif()

target_link_libraries(Klawing
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

install(TARGETS Klawing DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/installed/build)
