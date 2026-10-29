# Resolves and installs the MinGW runtime DLLs required by the Klawing executable.
# Expects KLAWING_EXECUTABLE and KLAWING_MINGW_BIN_DIR to be set (see CMakeLists.txt).

file(GET_RUNTIME_DEPENDENCIES
        EXECUTABLES "${KLAWING_EXECUTABLE}"
        DIRECTORIES "${KLAWING_MINGW_BIN_DIR}"
        POST_EXCLUDE_REGEXES
            "^[Aa][Pp][Ii]-[Mm][Ss]-"
            "^[Ee][Xx][Tt]-[Mm][Ss]-"
        RESOLVED_DEPENDENCIES_VAR klawing_resolved_deps
        UNRESOLVED_DEPENDENCIES_VAR klawing_unresolved_deps
)

file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE SHARED_LIBRARY FILES ${klawing_resolved_deps})
