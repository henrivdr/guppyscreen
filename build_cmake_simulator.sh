
# https://wiki.libsdl.org/SDL3/README/cmake
# To build and install (static) SDL3
# sudo apt install libwayland-dev libxkbcommon-dev wayland-protocols libegl-dev 
# cd deps/SDL
# cmake -S . -B build -DSDL_STATIC=ON -DSDL_SHARED=OFF -DSDL_EXAMPLES=OFF -DSDL_TESTS=OFF -DCMAKE_BUILD_TYPE=Release
# cmake --build build --config Release
# sudo cmake --install build --prefix /usr/local
# pkg-config --libs sdl3
# pkg-config --cflags sdl3

unset CROSS_COMPILE
#export GUPPY_THEME=

BUILD_DIR=build_simulator

# Clean
if [ -d "${BUILD_DIR}" ]; then
    # Clean Deps
    cmake --build ${BUILD_DIR}/libhv --target clean 
    cmake --build ${BUILD_DIR}/deps/SDL/ --target clean 
    cmake --build ${BUILD_DIR}/spdlog/ --target clean 
    cmake --build ${BUILD_DIR}/lvgl/ --target clean 
    cmake --build ${BUILD_DIR}/lv_drivers/ --target clean     
    # cmake --build ${BUILD_DIR} --target clean-deps
    
    # Clean build
    # rm -rf ${BUILD_DIR}
fi

# Configure
cmake -S . -B ${BUILD_DIR} -DGUPPY_SMALL_SCREEN=1
# Build
cmake --build ${BUILD_DIR}


