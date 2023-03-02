include player.lua
include camera.lua
include collision.lua
include printer.lua
include stars.lua
include objects.lua

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
    --demo camera shake
    if(btnp(4))cam:shake(15,2)
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
end
