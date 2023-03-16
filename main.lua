-->8
--core logic
#include src/player.lua
#include src/camera.lua
#include src/collision.lua
#include src/printer.lua
#include src/stars.lua
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

--level table
l=
{
  ichi=
  {
    finished=false,
    px=32,  --where to spawn player x
    py=480, --where to spawn player y
    lx=72   --camera limit x (y is always the same)
  },
  ni=
  {
    finished=false,
    px=168,
    py=480,
    lx=208
  },
  san=
  {
    finished=false,
    px=0,
    py=0,
    lx=344
  }
}

--game flow
--------------------------------

--reset the game to its initial
--state. use this instead of
--_init()
function reset(level)
    ticks=0
    delay_count=0
    delay_on=false
    p1=m_player(level.px,level.py)
    p1:set_anim("walk")
    stars.init()
    cam=m_cam(p1,level.lx)
    -- uncomment to enable music
    -- music(mus.bgm,300)
end

--p8 functions
--------------------------------

function _init()
    palt(0, false)
    palt(3, true)
    --remove delay for btnp
    poke(0x5f5c, 255)
    state=2
    prevstate=nil
    reset(l.ichi)
end

function _update60()
    if state==2 or state==4 or state==6 then
      game_update()
    elseif state==10 then
      pause_update(1)
    else --state 9
      pause_update(0)
    end
end

function _draw()
    if state==2 or state==4 or state==6 then
      game_draw()
    elseif state==10 then
      pause_draw(1)
    else --state 9
      pause_draw(0)
    end
end