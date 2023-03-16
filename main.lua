-->8
--core logic
#include src/player.lua
#include src/camera.lua
#include src/collision.lua
#include src/printer.lua
#include src/stars.lua
#include src/states.lua

--log
--printh("\n\n-------\n-start-\n-------")

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
  one=
  {
    px=168, --where to spawn player x
    py=480, --where to spawn player y
    lx=208  --camera limit x (y is always the same)
    --music=mus.bgm --music track to play
  },
  two=
  {
    px=32,  
    py=480, 
    lx=72   
    --music=mus.bgm
  },
  three=
  {
    px=336,
    py=488,
    lx=344
    --music=mus.bgm
  }
}

--cutscene table
sce=
{
  one=
  {
    map_x=64, -- x location of cutscene on tilemap
    map_y=0,  -- y location of cutscene on tilemap
    nextstate=2, -- point to next level
    --music=mus.bgm, --music track to play
    t={
      {"cat","this is a test of the dialogue\nsystem, i sure hope this\nfunctions correctly"},
      {"cat","otherwise, i think i might\njust go purr-ticularly insane."},
      {"",""}
    }
  },
  two=
  {
    map_x=64,
    map_y=0,
    nextstate=4,
    --music=mus.bgm
    t={
      {"cat","second dialogue test."},
      {"new friend","and this time with an all-new\nfriend!!!!!!"},
      {"cat","who the heck are you"},
      {"",""}
    }
  },
  three=
  {
    map_x=64,
    map_y=0,
    nextstate=6,
    --music=mus.bgm
    t={
      {"cat","third dialogue test."},
      {"cat","really gonna just pad the\nlength here and see how much\ni can cram into this box."},
      {"cat","...about that much."},
      {"",""}
    }
  },
  four=
  {
    map_x=64,
    map_y=0,
    nextstate=8,
    --music=mus.bgm
    t={
      {"cat","final dialogue test."},
      {"cat","did you have fun with my\nmundane text experiments for\nthis systems prototyping?"},
      {"cat","i sure did :)"},
      {"new old friend","i did too!!!!!!"},
      {"cat","why are you still here"},
      {"",""}
    }
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
    textnum=1
    -- uncomment to enable music
    -- music(level.music,300)
end

--p8 functions
--------------------------------

function _init()
    palt(0, false)
    palt(3, true)
    --remove delay for btnp
    poke(0x5f5c, 255)
    state=0
    prevstate=nil
    titleticks=0
    textnum=1
end

function _update60()
    if state==2 or state==4 or state==6 then
      game_update()
    elseif state==0 then
      title_update()
    elseif state==1 then
      cutscene_update(sce.one)
    elseif state==3 then
      cutscene_update(sce.two)
    elseif state==5 then
      cutscene_update(sce.three)
    elseif state==7 then
      cutscene_update(sce.four)
    elseif state==8 then
      credits_update()
    elseif state==9 then
      pause_update(0)
    else --state 10
      pause_update(1)
    end
end

function _draw()
    if state==2 or state==4 or state==6 then
      game_draw()
    elseif state==0 then
      title_draw()
    elseif state==1 then
      cutscene_draw(sce.one)
    elseif state==3 then
      cutscene_draw(sce.two)
    elseif state==5 then
      cutscene_draw(sce.three)
    elseif state==7 then
      cutscene_draw(sce.four)
    elseif state==8 then
      credits_draw()
    elseif state==9 then
      pause_draw(0)
    else --state 10
      pause_draw(1)
    end
end