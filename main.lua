#include src/player.lua
#include src/camera.lua
#include src/collision.lua
#include src/printer.lua
#include src/stars.lua
#include src/objects.lua

-->8
--core logic

--log
printh("\n\n-------\n-start-\n-------")

--sfx
snd=
{
  jump=0,
}

--music tracks
mus=
{
  bgm=0 
}

--game flow
--------------------------------

--reset the game to its initial
--state. use this instead of
--_init()
function reset()
    --remove delay for btnp
    poke(0X5f5c, 255)
    ticks=0
    p1=m_player(24,496)
    p1:set_anim("walk")
    objs.init()
    stars.init()
    cam=m_cam(p1)
    -- uncomment to enable music
    -- music(mus.bgm,300)
end

--p8 functions
--------------------------------

function _init()
    reset()
end

function _update60()
    ticks+=1
    objs.interact()
    p1:update()
    cam:update()
end

function _draw()
    cls(0)
    stars.draw()
    camera(cam:cam_pos())
    map(0,0,0,0,128,128)
    objs.draw()
    p1:draw()
    --hud
    camera(0,0)
    printc(cam.pos.x..","..cam.pos.y,64,4,7,0,0)
    printc(p1.x..","..p1.y,64,12,7,0,0)
    printc(tostr(p1.dash_hold_time),64,20,7,0,0)
end
