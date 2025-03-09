
# CROSS_COMPILE=mips-linux-gnu-
#GUPPY_THEME=
export PATH=`realpath ../mips-gcc720-glibc229/bin`:$PATH
export CROSS_COMPILE=mips-linux-gnu-
make clean
make build

# why does this go into a loop?
# make clean
# cmake -S . -B build_printer
# cmake --build build_printer
