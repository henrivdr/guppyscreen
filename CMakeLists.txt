cmake_minimum_required(VERSION 3.10)
project(guppyscreen C CXX)

# Define cross-compilation tools if specified
set(CROSS_COMPILE $ENV{CROSS_COMPILE})
if(CROSS_COMPILE)
    set(CMAKE_C_COMPILER   "${CMAKE_SOURCE_DIR}/../mips-gcc720-glibc229/bin/${CROSS_COMPILE}gcc")
    set(CMAKE_CXX_COMPILER "${CMAKE_SOURCE_DIR}/../mips-gcc720-glibc229/bin/${CROSS_COMPILE}g++")
    set(CMAKE_ASM_COMPILER "${CMAKE_SOURCE_DIR}/../mips-gcc720-glibc229/bin/${CROSS_COMPILE}as")
    set(CMAKE_AR           "${CMAKE_SOURCE_DIR}/../mips-gcc720-glibc229/bin/${CROSS_COMPILE}ar")
    set(CMAKE_LINKER       "${CMAKE_SOURCE_DIR}/../mips-gcc720-glibc229/bin/${CROSS_COMPILE}ld")
    set(CMAKE_NM           "${CMAKE_SOURCE_DIR}/../mips-gcc720-glibc229/bin/${CROSS_COMPILE}nm")
    set(CMAKE_STRIP        "${CMAKE_SOURCE_DIR}/../mips-gcc720-glibc229/bin/${CROSS_COMPILE}strip")
endif()

# Compiler and linker flags
set(WARNINGS "-Wall -Wextra -Wno-unused-function -Wno-error=strict-prototypes -Wpointer-arith \
    -fno-strict-aliasing -Wno-error=cpp -Wuninitialized -Wmaybe-uninitialized -Wno-unused-parameter \
    -Wno-missing-field-initializers -Wtype-limits -Wsizeof-pointer-memaccess -Wno-format-nonliteral \
    -Wno-cast-qual -Wunreachable-code -Wno-switch-default -Wreturn-type -Wmultichar -Wformat-security \
    -Wno-error=pedantic -Wno-sign-compare -Wdouble-promotion -Wclobbered -Wempty-body -Wtype-limits \
    -Wshift-negative-value -Wno-unused-value -Wno-unused-parameter -Wno-missing-field-initializers \
    -Wuninitialized -Wmaybe-uninitialized -Wpointer-arith")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3 -g0 -MD -MP ${WARNINGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -g0 -MD -MP ${WARNINGS} -std=c++17")
set(CMAKE_EXE_LINKER_FLAGS " -lm -latomic -lpthread -lstdc++exp ")

# Include directories
include_directories(
    ${CMAKE_SOURCE_DIR}    
    ${CMAKE_SOURCE_DIR}/lv_touch_calibration    
    wpa_supplicant/src/common
)

# Define preprocessor macros
add_definitions(-D_GNU_SOURCE -DSPDLOG_COMPILED_LIB)
set(ASSET_DIR material)
if(GUPPY_SMALL_SCREEN)
    set(ASSET_DIR material_46)    
    add_definitions(-DGUPPY_SMALL_SCREEN)
endif()
if(GUPPY_ROTATE)
    add_definitions(-DGUPPY_ROTATE)
endif()

if(GUPPYSCREEN_VERSION)
    add_definitions(-DGUPPYSCREEN_VERSION="${GUPPYSCREEN_VERSION}")
endif()

if(EVDEV_CALIBRATE)
    add_definitions(-DEVDEV_CALIBRATE)
endif()

if(NOT DEFINED CROSS_COMPILE)
    add_definitions(-DLV_BUILD_TEST=0 -DSIMULATOR)    
endif()

# Collect source files
file(GLOB MAINSRC "${CMAKE_SOURCE_DIR}/src/*.cpp")
list(FILTER MAINSRC EXCLUDE REGEX ".*kd_graphic_mode\\.cpp")

file(GLOB CSRCS 
    "${CMAKE_SOURCE_DIR}/assets/*.c"
    "${CMAKE_SOURCE_DIR}/lv_touch_calibration/*.c"
)

if(GUPPY_THEME STREQUAL "zbolt")    
    file(GLOB THEME_SRC "${CMAKE_SOURCE_DIR}/assets/zbolt/*.c")
    add_definitions(-DZBOLT)
else()    
    file(GLOB THEME_SRC "${CMAKE_SOURCE_DIR}/assets/${ASSET_DIR}/*.c")
endif()

list(APPEND CSRCS ${THEME_SRC})

set( CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin )
set( CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib )

# Create executable
set(BIN_NAME "guppyscreen")
add_executable(${BIN_NAME} ${MAINSRC} ${CSRCS})

if(DEFINED CROSS_COMPILE)
    # kd_graphic_mode target
    add_executable(kd_graphic_mode ${CMAKE_SOURCE_DIR}/src/kd_graphic_mode.cpp)
    target_link_libraries(kd_graphic_mode ${EXTRA_LIBS})
endif()

# lv_drivers
# ----------
set(USE_WAYLAND 1)
add_subdirectory(lv_drivers)
target_link_libraries(guppyscreen lv_drivers)

# SDL3
# ----
# https://wiki.libsdl.org/SDL3/README/cmake
if(NOT DEFINED CROSS_COMPILE)    
    set(SDL_EXAMPLES OFF)
    set(SDL_TESTS OFF)
    set(SDL_TEST_LIBRARY OFF)
    set(SDL_SHARED OFF)    
    set(SDL_STATIC ON)
    set(SDL_ALSA OFF)
    set(SDL_DBUS OFF)
    set(SDL_IBUS OFF)
    set(SDL_DISKAUDIO OFF)
    set(SDL_DUMMYCAMERA OFF)
    set(SDL_DUMMYVIDEO OFF)
    set(SDL_HIDAPI OFF)
    set(SDL_OPENGL OFF)
    set(SDL_PULSEAUDIO OFF)
    set(SDL_VIRTUAL_JOYSTICK OFF)
    set(SDL_WAYLAND  ON)    
    set(SDL_X11 ON)  # HvdR Why does it (sometimes) segfault if it is ON?
    add_subdirectory(deps/SDL EXCLUDE_FROM_ALL)
    target_link_libraries(guppyscreen SDL3::SDL3 )
endif()

# spdlog
# ------
add_subdirectory(spdlog)
target_link_libraries(guppyscreen spdlog)

# lvgl
# ----
set(LV_CONF_BUILD_DISABLE_THORVG_INTERNAL ON CACHE STRING "" FORCE)
set(LV_CONF_BUILD_DISABLE_EXAMPLES ON CACHE STRING "" FORCE)
set(LV_CONF_BUILD_DISABLE_DEMOS ON CACHE STRING "" FORCE)
set(LV_CONF_INCLUDE_SIMPLE ON CACHE STRING "" FORCE)
add_subdirectory(lvgl EXCLUDE_FROM_ALL)
# target_compile_definitions(lvgl PRIVATE LV_CONF_INCLUDE_SIMPLE)
# target_compile_definitions(lvgl PRIVATE LV_CONF_PATH=${CMAKE_SOURCE_DIR}/lv_conf.h)
# Fetch LVGL from GitHub
# include(FetchContent)
# FetchContent_Declare(
#     lvgl
#     URL https://github.com/lvgl/lvgl.git
#     GIT_TAG v9.2.2
#     # GIT_SHALLOW TRUE
#     GIT_PROGRESS TRUE
#     )
# FetchContent_MakeAvailable(lvgl)
target_link_libraries(guppyscreen lvgl::lvgl)

target_link_libraries(guppyscreen stdc++fs)

# libhv
# -----
# cmake option:
set(BUILD_SHARED OFF CACHE STRING "" FORCE)
set(BUILD_STATIC ON CACHE STRING "" FORCE)
set(WITH_EVPP ON CACHE STRING "" FORCE)
set(WITH_HTTP ON CACHE STRING "" FORCE)
set(WITH_HTTP_SERVER OFF CACHE STRING "" FORCE)
set(WITH_HTTP_CLIENT ON CACHE STRING "" FORCE)
set(BUILD_EXAMPLES OFF CACHE STRING "" FORCE)
add_subdirectory(libhv EXCLUDE_FROM_ALL)
target_link_libraries(guppyscreen hv_static)

# wpa_supplicant
# --------------
add_custom_target(build_wpaclient COMMAND make -C ../wpa_supplicant/wpa_supplicant -j$(nproc) libwpa_client.a )
add_library(wpaclient STATIC IMPORTED)
add_dependencies(wpaclient build_wpaclient)
add_dependencies(guppyscreen wpaclient)

# Link libraries
target_link_libraries(${BIN_NAME} ${EXTRA_LIBS}
    -L../wpa_supplicant/wpa_supplicant/ -l:libwpa_client.a
    )

# Installation rules
install(TARGETS ${BIN_NAME} DESTINATION bin)

# Clean-up targets
add_custom_target(spdlogclean COMMAND rm -rf ../spdlog/build)
add_custom_target(libhvclean COMMAND make -C ../libhv clean)
add_custom_target(wpaclean COMMAND make -C ../wpa_supplicant/wpa_supplicant clean )                    

add_custom_target(clean-deps   
    DEPENDS libhvclean    
    DEPENDS spdlogclean
    DEPENDS wpaclean    
)

# Build dependencies
add_custom_target(build-all
    COMMAND ${CMAKE_MAKE_PROGRAM} wpaclean
    COMMAND ${CMAKE_MAKE_PROGRAM} wpaclient
    COMMAND ${CMAKE_MAKE_PROGRAM} libhvclean
    COMMAND ${CMAKE_MAKE_PROGRAM} libhv.a
    COMMAND ${CMAKE_MAKE_PROGRAM} spdlogclean
    COMMAND ${CMAKE_MAKE_PROGRAM} libspdlog.a
    COMMAND ${CMAKE_MAKE_PROGRAM} clean
    COMMAND ${CMAKE_MAKE_PROGRAM} -j$(nproc)
)
