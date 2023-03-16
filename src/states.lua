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
  if p1.y > 350 then
    cls(14)
  elseif p1.y > 250 then
    cls(6)
  elseif p1.y > 150 then
    cls(13)
  elseif p1.y > 50 then
    cls(2)
  else
    cls(1)
  end
  stars.draw()
  camera(cam:cam_pos())
  map(0,0,0,0,128,128)
  p1:draw()
  --hud
  camera(0,0)
  --printc(cam.pos.x..","..cam.pos.y,64,4,7,0,0)
  printc(p1.x..","..p1.y,64,12,7,0,0)
  --printc(tostr(p1.dash_hold_time),64,20,7,0,0)
  --printc(tostr(p1.cloud_jump),64,28,7,0,0)
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
  cls(1)
  if death==0 then
    if laststate==2 then
      printc("you have broken the atmosphere",64,49,7,0,0)
    elseif laststate==4 then
      printc("you're farther in the milky way",64,49,7,0,0)
    else
      printc("you are now at saturn",64,49,7,0,0)
    end
    spr(108,57,57,2,2,true)
    printc("press ❎ or 🅾️ to continue",60,77,7,0,0)
  else
    printc("you have fallen back down",64,49,7,0,0)
    spr(100,57,57,2,2,true)
    printc("press ❎ or 🅾️ to try again",60,77,7,0,0)
  end
end

-- title screen functions
function title_update()
  --titleticks+=1
  if btnp(4) or btnp(5) then
    laststate=state
    state=1
  end
end

function title_draw() --make it look nice later lol
  cls(0)
  printo("saturn's rings",0,0,7,0,0)
  printo("press ❎ or 🅾️ to start",0,12,7,0,0)
end

-- cutscene functions
function cutscene_update(cs)
  if btnp(4) or btnp(5) then
    textnum+=1
    if textnum > #cs.t - 1 then
      if (cs.nextstate==2) reset(l.one)
      if (cs.nextstate==4) reset(l.two)
      if (cs.nextstate==6) reset(l.three)
      state=cs.nextstate
    end
  end
end

function cutscene_draw(cs)
  cls(0)
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
  map(64,16,0,0,128,128)
  printc("design by morgan creek",64,32,7,0,0)
  printc("art by clarissa gutierrez",64,40,7,0,0)
  printc("and siyuan guo",64,48,7,0,0)
  printc("audio by alex ling",64,56,7,0,0)
  printc("programming by michael dinh",64,64,7,0,0)
  printc("and nicholas mueller",64,72,7,0,0)
  printc("thank you for playing! :)",64,80,7,0,0)
end