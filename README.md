## Saturn's Rings
### Game 2 for CDM 176: Game Platforms Winter 2023 @ UC Davis

This project is based on the Advanced Microplatform Template by @matthughson, [located on the Pico-8 BBS here](https://www.lexaloffle.com/bbs/?tid=28793), as well as Jeren Raquel's PICO-8 Python/Shell stitcher, [located here](https://github.com/JerenRaquel/pico8-stitcher).

## About

### To compile
- Clone repo
- Ensure Python 3 is installed on your device
- Run the `build.sh` file
- If all goes well, all code will be placed in saturns_rings.p8

### Structure and Quirks
The stitcher currently discards comments, which may or may not be good for our needs right now. There are currently seven primary classes and one main file:
- `main.lua`, which houses all PICO-8 specific functions
- `player.lua`, which houses all player initialization and control code
- `camera.lua`, which houses all camera initialization and control code
- `collision.lua`, which provides player/platform collision code
- `printer.lua`, which provides more specific/useful print functions for debugging or stylistic purposes
- `stars.lua`, which provides the code for the parallax star background
- `objects.lua`, which is backported from the Catformer project and provides object interaction/collision code (and is currently borked, whoops)
- `states.lua`, which details update/draw functions for each differing state of the game

To edit graphics, music, SFX, and the tile map, directly edit the saturns_rings.p8 file – only code should be replaced on stitching.
