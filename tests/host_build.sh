#!/bin/sh
# Builds the Snes9x core + bridge for the Mac (AddressSanitizer) and links the
# core test: sh tests/host_build.sh  ->  build-host/core_test
set -e
cd "$(dirname "$0")/.."
T=third_party/snes9x; LC=$T/libretro/libretro-common; O=build-host
mkdir -p $O
SRCS="$T/c4emu.c $T/msu1.c $T/zipfile.c $T/srtc.c $T/obc1.c $T/bsflash.c $T/tile.c $T/bsx.c $T/spc7110.c $T/fxemu.c $T/sdd1.c $T/seta.c $T/sa1hw.c $T/dsp.c
 $T/apu/apu.cpp $T/apu/bapu/dsp/sdsp.cpp $T/apu/bapu/smp/smp.cpp $T/apu/bapu/smp/smp_state.cpp $T/cheats2.cpp $T/clip.cpp $T/controls.cpp $T/cpu.cpp
 $T/cpuexec.cpp $T/cpuops.cpp $T/crosshairs.cpp $T/dma.cpp $T/gfx.cpp $T/globals.cpp $T/loadzip.cpp $T/memmap.cpp $T/ppu.cpp $T/sa1.cpp $T/sa1cpu.cpp
 $T/snapshot.cpp $T/sha256.cpp $T/bml.cpp $T/fscompat.cpp
 $LC/compat/compat_posix_string.c $LC/compat/compat_strcasestr.c $LC/compat/compat_snprintf.c $LC/compat/compat_strl.c $LC/compat/fopen_utf8.c
 $LC/encodings/encoding_utf.c $LC/encodings/encoding_deflate.c $LC/file/file_path.c $LC/file/file_path_io.c $LC/streams/file_stream.c
 $LC/streams/file_stream_transforms.c $LC/string/stdstring.c $LC/time/rtime.c $LC/vfs/vfs_implementation.c $LC/vfs/vfs_hybrid.c $LC/file/retro_dirent.c
 native/bridge_snes9x.cpp source/cores.cpp tests/core_test.cpp"
FLAGS="-O1 -g -fsanitize=address -w -D__LIBRETRO__ -DALLOW_CPU_OVERCLOCK -I$T -I$T/apu -I$T/apu/bapu -I$T/libretro -I$LC/include"
for f in $SRCS; do
  o=$O/$(echo $f | tr / _).o
  if [ ! -f $o ] || [ $f -nt $o ]; then
    case $f in *.c) clang -std=gnu11 $FLAGS -c $f -o $o & ;; *) clang++ -std=gnu++14 $FLAGS -c $f -o $o & ;; esac
  fi
done
wait
clang++ -fsanitize=address $O/*.o -o $O/core_test
echo "built $O/core_test"
