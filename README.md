# SW2SNES

A Super Nintendo emulator for the Nintendo Switch 2, running as a homebrew app
from **hbmenu** under [kaiHEN](https://github.com/ouncebrew/kaihen). It uses the
**Snes9x** core with the [SW2NES](https://github.com/Rodpad/SW2NES) front end:
native C++ with OpenGL ES, built with devkitPro and the Switch 2 devkit
([ounce-devkit](https://github.com/ouncebrew/ounce-devkit)).

No game ROMs are included or provided.

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/8572f706-2455-44d2-bb2a-ae643969b65b" />

## Installing

1. Set up kaiHEN on your Switch 2 so that hbmenu runs.
2. Copy `sw2snes.nro` from the latest release to `/switch/sw2snes/sw2snes.nro`
   on the SD card.
3. Copy your games (`.sfc`, `.smc`, `.fig`, `.swc` or `.zip`) to `/roms/snes` on
   the SD card. SW2SNES creates this folder on its first launch. A different
   folder can be chosen in Settings > ROM folder.
4. Launch **SW2SNES** from hbmenu.

Settings, saves and play time are kept in `/switch/sw2snes/` on the SD card.

### Updating

Replace `/switch/sw2snes/sw2snes.nro` with the one from the newest release. Settings,
saves, save states and play time are kept in `/switch/sw2snes/` and are not touched
by an update. (Close SW2SNES on the console before uploading over FTP; a running
app's file cannot be replaced.)

## Features

- **Box art browsing, scraped on the console:** browse your games as a grid of box covers or as a
  list, with a details panel showing the box in 3D (front, back and sides; drag to turn it), the
  title, publisher, year, genre, region and description. Box art and details are downloaded on
  the console from [ScreenScraper](https://www.screenscraper.fr), with no account needed and no PC
  required (Settings > App > Download missing box art and descriptions; the app offers it the first
  time games have none). Four views (List, List & details, Grid, Grid & details) on the right stick
  press; with details downloaded, the list shows each game's proper title
- Snes9x (libretro), including its enhancement-chip support (SuperFX, SA-1, DSP-n, CX4, S-DD1, SPC7110 and others)
- Hi-res and interlaced modes (512 wide, 448/478 high)
- Low input latency: one frame in flight, run-ahead (1–2 frames), frame delay at 60 Hz
- 120 Hz / VRR on the Switch 2 screen
- Rewind (hold ZL) and fast-forward (hold or toggle ZR)
- GPU shaders: CRT-Royale (lite), CRT-Geom, CRT-Lottes, CRT-Easymode, CRT-Aperture,
  zfast CRT, LCD grid, Scale2x, sharp bilinear, bilinear
- NTSC signal simulation (composite, composite with dot crawl, S-Video)
- Curvature, rounded corners, vignette and brightness boost
- Aspect ratio, integer or fit scaling, overscan
- 4 save-state slots per game, battery saves, optional auto-load of the latest state
- Two players, with separate button mapping and turbo for each
- Game list with All / Favourites / Recent tabs, search, sorting (name, last played, date added),
  Last Played dates and time played; games are found in subfolders of the ROM folder too
- Touch on every screen (tap, hold to highlight, drag to scroll), with an on-screen Menu button
  during play; UI size Normal (larger, easier to tap) or Compact
- Themes: Dark, Light, Black, Blue, Purple, Red, Green, Orange, Retro and Retro Colour
- Button remapping screen per player (all games, or one game), including turbo and stick directions
- Single Joy-Cons held sideways work as a controller, with position-based button hints
- Game Genie and Pro Action Replay codes (on-screen editor)
- Zipped ROMs (`.zip` with a `.sfc`/`.smc` inside)
- Per-game or global settings; advanced options can be hidden

## Controls

| Switch 2 | SNES / app |
| --- | --- |
| D-pad / left stick | D-pad |
| A, B, X, Y | SNES A, B, X, Y (default) |
| L, R | SNES L, R (default) |
| + / − | Start / Select |
| L + R + stick press | In-game menu (press again to close); SL + SR + stick press on a single Joy-Con |
| ZL (hold) | Rewind |
| ZR | Fast-forward |

Buttons can be remapped per player in Settings > Sound & controls (or for one game from
the in-game Controls tab), including turbo.

In the game list:

| Switch 2 | Game list |
| --- | --- |
| A | Play the highlighted game |
| L / R | All / Favourites / Recent |
| ZL / ZR | Page up / down (hold to keep paging) |
| Left stick press | Next sort order (name, last played, date added) |
| Right stick press | Next view: List & details, List, Grid & details, Grid |
| − / + | Favourite / Search |
| Y / X | Refresh / Settings |
| B | Exit (press twice) |

The list and the grid wrap round: past the first or last game, the D-pad stops on the header row
(tabs, search, sort) or the footer buttons, then carries on round. On a single Joy-Con, SL switches
tabs and SR pages down. Everything can also be tapped; drag to scroll, flick to glide.

## Building

Requirements: [devkitPro pacman](https://devkitpro.org/wiki/devkitPro_pacman) with
`switch-dev`, `switch-freetype`, `switch-zlib`, `switch-curl` and `switch-mbedtls`, and the Switch 2 devkit
(`sh install.sh` from ounce-devkit).

```sh
export DEVKITPRO=/opt/devkitpro
make
```

This builds `sw2snes.nro`.
Box art downloads use [ScreenScraper](https://www.screenscraper.fr) and need a ScreenScraper
developer account, which is not in this repository: put `devid=...` and `devpassword=...` on two
lines in `~/.config/sw2/screenscraper.txt` and run `tools/make_ss_dev.sh`, which writes the
ignored `source/ss_dev.h`. Without it the app builds and runs but cannot download box art.
 `tests/host_build.sh` builds a host (Mac/Linux) test of
the core bridge under AddressSanitizer.

## Layout

| Path | Contents |
| --- | --- |
| `source/` | The app: menus, settings, game loop, video (OpenGL ES), audio, input, rewind |
| `romfs/shaders/` | Picture shaders (GLSL ES) and the NTSC encoder/decoder |
| `native/bridge_snes9x.cpp` | C interface to Snes9x (frames, audio, states, cheats) |
| `third_party/snes9x` | Snes9x (from libretro/snes9x, see `SOURCE.txt`) |
| `tests/` | Host tests for the core bridge |
| `licenses/` | Licences of the bundled components (also inside the app) |

## Licence

SW2SNES's own code (everything outside `third_party/`) is under the MIT licence
(see `LICENSE`). **Snes9x is not free software for commercial use**: its licence
allows free non-commercial use and distribution only, so SW2SNES as a whole may
only be used and distributed non-commercially. See `licenses/snes9x-LICENSE.txt`.

It also includes:

- libretro-common (MIT)
- Roboto (Apache 2.0) and Source Code Pro (SIL OFL 1.1) fonts
- libounce and libnx (ISC), libkaihen (ISC), OunceVK / Mesa (MIT), mimalloc (MIT),
  FreeType (FTL), HarfBuzz (MIT), libpng, zlib, minizip (zlib licence) and bzip2
- curl (curl licence), Mbed TLS (Apache 2.0), stb_image (MIT / public domain) and the
  Mozilla CA certificates (MPL 2.0), for downloading box art and game details

- Date formats from the Unicode CLDR (Unicode licence)

Their licence texts are in `licenses/`.
