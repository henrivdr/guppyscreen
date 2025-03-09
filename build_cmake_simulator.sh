
# https://wiki.libsdl.org/SDL3/README/cmake
# To build and install (static) SDL3
# sudo apt install libwayland-dev libxkbcommon-dev wayland-protocols libegl-dev 

unset CROSS_COMPILE
#export GUPPY_THEME=

BUILD_DIR=build_simulator

# Clean
if [ -d "${BUILD_DIR}" ]; then
    cp build_simulator/bin/guppyconfig.json .
    # Clean dependancies
    cmake --build ${BUILD_DIR}/libhv --target clean 
    cmake --build ${BUILD_DIR}/deps/SDL/ --target clean 
    cmake --build ${BUILD_DIR}/spdlog/ --target clean 
    cmake --build ${BUILD_DIR}/lvgl/ --target clean 
    cmake --build ${BUILD_DIR}/lv_drivers/ --target clean     
    make -C wpa_supplicant/wpa_supplicant clean
    # cmake --build ${BUILD_DIR} --target clean-deps
    
    # Clean build
    rm -rf ${BUILD_DIR}
fi

# Configure
cmake -S . -B ${BUILD_DIR} -DGUPPY_SMALL_SCREEN=1 
# -DGUPPYSCREEN_VERSION=0.0.26-beta
# Build
cmake --build ${BUILD_DIR} --parallel $(nproc) --config Release

cp guppyconfig.json build_simulator/bin/guppyconfig.json
