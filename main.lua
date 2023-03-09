-->8
--core logic
#include src/player.lua
#include src/camera.lua
#include src/collision.lua
#include src/printer.lua
#include src/stars.lua
#include src/objects.lua
#include src/states.lua

--log
printh("\n\n-------\n-start-\n-------")

--sfx
snd=
{
  ouch=0,
  meow=8,
  jump=28,
  dash=29,
  cloud=30,
  land=31
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
		palt(0, false)
		palt(3, true)
    --remove delay for btnp
    poke(0x5f5c, 255)
    ticks=0
    delay_count=0
    delay_on=false
    p1=m_player(24,480)
    p1:set_anim("walk")
    objs.init()
    stars.init()
    cam=m_cam(p1)
    state=0
    -- uncomment to enable music
    -- music(mus.bgm,300)
end

--p8 functions
--------------------------------

function _init()
    reset()
end

function _update60()
    if state==0 then
      game_update()
    else
      pause_update()
    end
end

function _draw()
    if state==0 then
      game_draw()
    elseif state==1 then
      pause_draw(1)
    else
      pause_draw(0)
    end
end