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
  land=31,
  adv=25,
  confirm=26
}

--music tracks
mus=
{
  cs1=8,
  l1=32,
  cs2=24,
  l2=40,
  cs3=16,
  l3=0,
  cs4=56,
  menu=63
}

--level table
l=
{
  one=
  {
    px=32,  --where to spawn player x
    py=480, --where to spawn player y
    lx=72,   --camera limit x (y is always the same)
    music=mus.l1 --music track to play
  },
  two=
  {
    px=168,  
    py=480,
    lx=208,
    music=mus.l2
  },
  three=
  {
    px=376,
    py=490,
    lx=344,
    music=mus.l3
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
    music=mus.cs1, --music track to play
    t={
      {"friend bunny","so... i guess this is it.\nyou're finally doing it!"},
      {"cat","i know... i've been waiting\nfor this my whole life..."},
      {"friend bunny","yeah, this has been your dream\nfor as long as we've been\nfriends. are you excited?"},
      {"cat","of course! but i'm also\nnervous... what if something\nhappens?"},
      {"friend bunny","yeah, space is pretty scary...\nand unpredictable...\nand big..."},
      {"friend bunny","and there's black holes...\nand supernovas...\nand aliens!"},
      {"cat","..."},
      {"friend bunny","i'm kidding! mostly. you'll\nbe fiiiine. i'm sure you'll\nfind help along the way!"},
      {"friend bunny","...but just between you and me\ni'd avoid any suspicious ufos."},
      {"cat","uh, if you say so..."},
      {"cat","okay, i think i'm good to go!"},
      {"friend bunny","alright! here's your space\nhelmet. you're officially\nready to see saturn's rings!"},
      {"friend bunny","good luck, cat-stronaut o7"},
      {"cat (now a stronaut)","thanks, bunny. i can't wait\nto tell you all about it when\ni get back!"},
      {"",""}
    }
  },
  two=
  {
    map_x=80,
    map_y=0,
    nextstate=4,
    music=mus.cs2,
    t={
      {"some kinda unicorn","hello~"},
      {"cat-stronaut","uh, hi?"},
      {"space unicorn, apparently","hi there~ i'm *space unicorn*"},
      {"cat-stronaut","woah, hi. i'm cat-stronaut."},
      {"space unicorn","nice to meet you,\ncat-stronaut! ~yaaaay~"},
      {"cat-stronaut","uhh, why so excited?"},
      {"space unicorn","well, not that many people\ntravel out to space so i've\nbeen suuuper bored out here"},
      {"space unicorn","but now i have you, my new\n~space bestie~"},
      {"cat-stronaut","haha... okay...\ni can't stay too long though,\ni'm trying to get to saturn!"},
      {"space unicorn","*dang* that's far. is all you\nbrought that space helmet...?"},
      {"cat-stronaut","...uh, yeah?"},
      {"space unicorn","that's cool, that's cool...\nyou're never gonna make it\nlike that though."},
      {"cat-stronaut","huh? what? why?"},
      {"space unicorn","there's a bunch of arduous\nplatforming gaps and weird\nplatform-type shapes up ahead!"},
      {"cat-stronaut","...oh."},
      {"space unicorn","yeah, sorry bestie."},
      {"cat-stronaut","...well, i guess i'll head ba-"},
      {"space unicorn","wait hold on a second"},
      {"space unicorn","i forgot i had this jetpack"},
      {"cat-stronaut","for real?"},
      {"space unicorn","yeah, it's rad, dude. it lets\nyou boost in *any* direction!"},
      {"cat-stronaut","well, that sounds like 1) fun,\nand 2) just what i need to\ntraverse the next level"},
      {"space unicorn","for real, bro. alright, i'll\nlet you borrow it under one\ncondition."},
      {"cat-stronaut","alright, what is it?"},
      {"space unicorn","we gotta be\nspace besties\n~forever~"},
      {"cat-stronaut","haha, that sounds like a fair\ntrade."},
      {"",""}
    }
  },
  three=
  {
    map_x=64,
    map_y=16,
    nextstate=6,
    music=mus.cs3,
    t={
      {"cat-stronaut","oh boy... that's a lot of\nshooting stars."},
      {"unspecified cow","..."},
      {"cat-stronaut","..."},
      {"unspecified cow","...hey dude."},
      {"cat-stronaut","...hey. you got any idea\nwhat's up with all those\nstars ahead?"},
      {"unspecified cow","oh, yeah. see, those are\nlocalized star fields."},
      {"unspecified cow","they sorta appear and\ndisappear on a regular\ninterval."},
      {"cat-stronaut","...huh."},
      {"unspecified cow","you can even stand on 'em, but\ndon't get caught with your\nstars down."},
      {"unspecified cow","because then you'll fall."},
      {"unspecified cow","all the way back down."},
      {"unspecified cow","to not saturn."},
      {"cat-stronaut","...huh. how do you know all\nthis?"},
      {"the moober cow","oh you know, i run a small\nlittle space travel operation\ncalled moober."},
      {"the moober cow","you might've heard of me or\nsomething."},
      {"cat-stronaut","...i don't think i have,\nbut thanks for the advice?"},
      {"",""}
    }
  },
  four=
  {
    map_x=80,
    map_y=16,
    nextstate=8,
    music=mus.cs4,
    t={
      {"cat-stronaut","wow... i've finally made it...\ni made it to saturn's rings!"},
      {"cat-stronaut","it's everything i could have\nimagined! :o"},
      {"cat-stronaut","saturn is so beautiful from\nhere...and the rings are so\nmesmerizing."},
      {"cat-stronaut","it looks like they're made of\nglitter!"},
      {"cat-stronaut","and it's so giant! i feel so\nsmall compared to it..."},
      {"cat-stronaut","..."},
      {"cat-stronaut","...huh. you know, saturn is\nmuch more peaceful than i\nimagined."},
      {"cat-stronaut","it's actually so calm... and\nquiet. there's really nobody\nelse out here!"},
      {"cat-stronaut","almost kind of lonely when\nyou think about it..."},
      {"cat-stronaut","...but i guess its okay to be\na little lonely. it's good to\nbe by yourself sometimes."},
      {"cat-stronaut","i couldn't have made it this\nfar without everyone's help."},
      {"cat-stronaut","i can't wait to tell them\nabout this trip!"},
      {"???","nah you don't gotta do that\nwe're all here lmao"},
      {"cat-stronaut","! you're all here!"},
      {"friend bunny (can breathe)","we sure are, pal. how about we\ncelebrate with a picture?"},
      {"cat-stronaut","oh heck yes"},
      {"","and then pretend a flash\nhappens here i'm lazy :("},
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
    music(level.music,0,14)
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
    musplay=false
    titleloc=0
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