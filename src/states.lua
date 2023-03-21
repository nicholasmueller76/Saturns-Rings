-- states of the game as i'm aware of right now:
-- 0 - title screen
-- 1 - cutscene 1
-- 2 - level 1
-- 3 - cutscene 2
-- 4 - level 2
-- 5 - cutscene 3
-- 6 - level 3
-- 7 - cutscene 4
-- 8 - end + credits?
-- 9 - success
-- # - death

-- gameplay functions
function game_update()
	ticks+=1
  p1:update()
  cam:update()
  -- restart if we die
  if p1.y > 500 then
    sfx(snd.ouch)
    laststate=state
    state=10
  elseif p1.y < -12 then
    sfx(snd.meow)
    laststate=state
    state=9
  end
end

function game_draw()
  -- solid color is probably nicer
  if (state==2) cls(14)
  if (state==4) cls(13)
  if (state==6) cls(2)
  stars.draw()
  camera(cam:cam_pos())
  map(0,0,0,0,128,128)
  p1:draw()
  p1:draw_star_platforms()
  --hud
  camera(0,0)
  if state==2 then
    printc("press ❎ to jump!",64,4,7,0,0)
  elseif state==4 then
    printc("press 🅾️ to rocket dash!",64,4,7,0,0)
  else
    printc("you're almost there!",64,4,7,0,0)
  end
  --printc(p1.x..","..p1.y,64,12,7,0,0)
end

-- death/success screen functions
function pause_update(death)
  -- if player beat last level, advance to next level
	if death==0 then
    if btnp(4) or btnp(5) then
      if laststate==2 then
        state=3
      elseif laststate==4 then
        state=5
      elseif laststate==6 then
        state=7
      end
    end
  -- else, reset variables on death
  else
    if btnp(4) or btnp(5) then
      if (laststate==2) reset(l.one)
      if (laststate==4) reset(l.two)
      if (laststate==6) reset(l.three)
      state=laststate
    end
  end
end

function pause_draw(death)
  music(-1)
  cls(1)
  if death==0 then
    if laststate==2 then
      printc("you have broken the atmosphere",64,49,7,0,0)
    elseif laststate==4 then
      printc("you're farther in the milky way",64,49,7,0,0)
    else
      printc("you are now at saturn :)",64,49,7,0,0)
    end
    spr(104,57,57,2,2,true)
    printc("press ❎ or 🅾️ to continue",60,77,7,0,0)
  else
    printc("you have fallen back down",64,49,7,0,0)
    spr(100,57,57,2,2,true)
    printc("press ❎ or 🅾️ to try again",60,77,7,0,0)
  end
end

-- title screen functions
function title_update()
  if not musplay then
    music(mus.menu,0)
    musplay=true
  end
  if btnp(2) and titleloc > 0 then
    sfx(snd.adv)
    titleloc-=1
  elseif btnp(3) and titleloc < 2 then
    sfx(snd.adv)
    titleloc+=1
  end
  if btnp(5) and titleloc==0 then
    sfx(snd.confirm)
    music(-1)
    musplay=false
    laststate=state
    state=1
  elseif btnp(5) and titleloc==1 then
    sfx(snd.confirm)
    music(-1)
    musplay=false
    laststate=state
    state=8
  elseif btnp(5) and titleloc==2 then
    cls(0)
    stop("see you, space meowboy",0,0,7)
  end
end

function title_draw()
  cls(1)
  map(112,0,0,0,128,128)
  if titleloc==0 then
    spr(2,32,72,1,1)
  elseif titleloc==1 then
    spr(2,32,88,1,1)
  else
    spr(2,32,104,1,1)
  end
end

-- cutscene functions
function cutscene_update(cs)
  if not musplay then
    music(cs.music,0)
    musplay=true
  end
  if btnp(4) or btnp(5) then
    sfx(snd.adv)
    textnum+=1
    if textnum > #cs.t - 1 then
      musplay=false
      if (cs.nextstate==2) reset(l.one)
      if (cs.nextstate==4) reset(l.two)
      if (cs.nextstate==6) reset(l.three)
      state=cs.nextstate
    end
  end
end

function cutscene_draw(cs)
  if (state==1) cls(14)
  if (state==3) cls(13)
  if (state==5) cls(2)
  if (state==7) cls(1)
  -- dynamic sprite control
  if state==1 then
    spr(74,88,56,2,2)
    if textnum<=12 then -- normal cat
      spr(108,24,56,2,2,true)
    elseif textnum>12 then -- helmet cat
      spr(68,24,56,2,2,true)
    end
    if textnum==12 then
      -- helmet non-body
      spr(98,56,40,2,2)
    end
  elseif state==3 then
    spr(68,24,56,2,2,true)
    if textnum>=19 then -- draw jetpack
      spr(65,56,40,1,1)
    end
  elseif state==5 then
    spr(68,24,56,2,2,true)
    if textnum>=2 then -- draw cow
      spr(76,88,56,2,2)
    end
  else
    circfill(4,48,48,9)
    line(0,48,70,46,7)
    line(0,46,67,52,7)
    line(0,50,73,42,7)
    if textnum>=14 then -- draw frens
      spr(74,104,56,2,2)
      spr(76,104,40,2,2)
      spr(78,104,24,2,2)
    end
  end
  map(cs.map_x,cs.map_y,0,0,128,128)
  -- print the name first
  printo(cs.t[textnum][1],4,92,7,0,0)
  -- then the actual text
  printo(cs.t[textnum][2],4,104,7,0,0)
  -- and button prompts to advance
  print("❎|🅾️",99,123,2)
end

-- credits / end screen functions
function credits_update()
  if btnp(4) or btnp(5) then
    textnum=1
    state=0
    prevstate=nil
  end
end

function credits_draw()
  cls(0)
  map(56,36,0,0,128,128)
  printc("design by morgan creek",64,32,7,0,0)
  printc("art by clarissa gutierrez",64,40,7,0,0)
  printc("and siyuan guo",64,48,7,0,0)
  printc("audio by alex ling",64,56,7,0,0)
  printc("programming by michael dinh",64,64,7,0,0)
  printc("and nicholas mueller",64,72,7,0,0)
  printc("thank you for playing! :)",64,88,7,0,0)
end