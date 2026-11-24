cmake_minimum_required(VERSION 3.24)
project(BalVOX LANGUAGES CXX)

if(NOT WIN32)
    message(FATAL_ERROR "BalVOX Wicked Engine build currently targets Windows x64.")
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(WICKED_EDITOR OFF CACHE BOOL "" FORCE)
set(WICKED_TESTS OFF CACHE BOOL "" FORCE)
set(WICKED_IMGUI_EXAMPLE OFF CACHE BOOL "" FORCE)
set(WICKED_WINDOWS_TEMPLATE OFF CACHE BOOL "" FORCE)
set(WICKED_ENABLE_SYMLINKS OFF CACHE BOOL "" FORCE)
set(WICKED_EMBED_SHADERS OFF CACHE BOOL "" FORCE)

include(FetchContent)
FetchContent_Declare(
    WickedEngine
    GIT_REPOSITORY https://github.com/turanszkij/WickedEngine.git
    GIT_TAG v0.72.139
    GIT_SHALLOW TRUE
)
FetchContent_MakeAvailable(WickedEngine)

add_executable(BalVOX WIN32 src/main.cpp)
target_link_libraries(BalVOX PRIVATE WickedEngine)
target_include_directories(BalVOX PRIVATE "${wickedengine_SOURCE_DIR}/WickedEngine")
target_compile_definitions(BalVOX PRIVATE UNICODE _UNICODE WIN32 _WINDOWS)

set_target_properties(BalVOX PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO "${CMAKE_BINARY_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL "${CMAKE_BINARY_DIR}/bin"
    VS_DEBUGGER_WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

add_dependencies(BalVOX Content)

add_custom_command(TARGET BalVOX POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${CMAKE_BINARY_DIR}/Content"
        "$<TARGET_FILE_DIR:BalVOX>/Content"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${wickedengine_SOURCE_DIR}/WickedEngine/dxcompiler.dll"
        "$<TARGET_FILE_DIR:BalVOX>/dxcompiler.dll"
)
