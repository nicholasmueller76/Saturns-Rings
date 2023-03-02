# pico8-stitcher
This is a basic plug and play library to "compile" a bunch of lua files to be written into a p8 (pico8) file.
Feel free to use this as you wish; just give a link to this repo or credit me. It's very crude method of doing this but it's pet project and should at least help with organization. 

# Instructions/Setup
1) Create a similar working directory for your project.
```
> Root
    > pico8-stitcher
    > src
        > fileA.lua
        > fileB.lua
        > data.lua
        > ...etc...
    > main.lua
    > cart_name.p8
    > data.json [optional]
```
2) Go into the **build.sh** file located in this repo.
    1) Change the pico8_file to point to your .p8 file.
    2) Make sure they are name the same and the file path is **relative**.
3) Code your pico8 cart to your heart desires.
    1) To link a .lua file to your main.lua file or other .lua files, add `#include file_name.lua` and make sure it's relative to the file that this statement is in.
        - Given the directory above, to include **fileA.lua** in **main.lua**, add `#include src/fileA.lua` to somewhere (anywhere) in **main.lua**
        - This stitcher program will link files recursively by linking the first instance of the include statement. This will only matter if there is an order of importance for certain files to be somewhere.
4) Run the **build.sh** file.
5) Assuming nothing went wrong, your p8 file should be written to and is ready to be run in the pico8 application.

## Code Example
```lua
-- main.lua
#include src/data.lua

function _init()
    setup_game_states()
end

function _draw()
    draw_game_loop()
end

function _update()
    update_game_loop()
end

-- misc functions
#include src/fileA.lua
#include src/fileB.lua
```
```lua
--- fileA.lua
function draw_game_loop()
    -- code
end
```
```lua
--- fileB.lua
function update_game_loop()
    -- code
end
```
```lua
--- data.lua
local global_table_str --[[remove]]
--[[json global_table_str data.json]]

function setup_game_states()
    global_table = unpack_table(global_table_str)
end
```

# Features
## Including seperate lua files
- This program should be able to link your lua files into a single pico8 file by using lua's basic `#include` keyword. 
- This program does not support functionality found in the normal lua enviroment and the .lua extention is just for the program to search for.
## JSON to string
- On any line in your lua files, you can add a 
    ```lua
    --[[json variable_name relative_path_to.json]]
    ```
    which will convert to 
    ```lua
    variable_name="json file stringified"
    ```
    during build time.
- In this repo, a crude `deserialization.lua` file is provided to convert the string to a lua table at runtime in pico8.
    - This file is 339 tokens in cost, so make sure you can store at least 340 tokens in a table before using this. Given the directory in the instruction setup example.
        ```lua
        -- Example usage
        -- data.lua

        local global_table_str --[[remove]]
        --[[json global_table_str data.json]]

        function setup_game()
            global_table = unpack_table(global_table_str)
        end
        ```
- The program should log to the console how many tokens you saved with this feature.
## Removable lines
- On any line in your lua files, you can add a 
    ```lua
    --[[remove]]
    ```
- This is mostly for tempory code lines that are placeholders for something.
- This can be used as 
    ```lua
    local global_table_str  --[[remove]]
    --[[json global_table_str data.json]]
    ```
    to shut VSCode up for its `global_table does not exist` warnings 
## Basic "linting"
- All lines that are commented will **not** be transfered to the .p8 file.
    - This is a design choice since the only place you really will be reading comments are in your .lua files.
- This program will check for multiple declarations of global functions
    - Given this
        ```lua
        -- FileA.lua
        3 function foobar()
        4     -- displays hello world in the top left corner in white
        5     print("hello world", 0, 0, 7)   
        6 end
        ```
        ```lua
        -- FileB.lua
        43 function foobar()
        44     -- displays goodbye world in the top left corner in white
        45     print("goodbye world", 0, 0, 7)   
        46 end
        ```
        The program should throw an exception that will report something similar to 
        ```
        Error::Multiple Function Declarations of `foobar`
        Found in `src/FileA.lua` on line 3 and `src/FileB.lua` on line 43
        ```