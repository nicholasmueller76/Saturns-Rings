function game_update()
	ticks+=1
    objs.interact()
    p1:update()
    cam:update()
    -- restart if we die
    if p1.y > 500 then
      state=1
    elseif p1.y < -12 then
      sfx(snd.meow)
      state=2
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
  objs.draw()
  p1:draw()
  --hud
  camera(0,0)
  printc(cam.pos.x..","..cam.pos.y,64,4,7,0,0)
  printc(p1.x..","..p1.y,64,12,7,0,0)
  printc(tostr(p1.dash_hold_time),64,20,7,0,0)
end

function pause_update()
	if btnp(4) or btnp(5) then
		reset()
	end
end

function pause_draw(death)
  cls(1)
  if death==0 then
    printc("you have broken the atmosphere",64,49,7,0,0)
    spr(108,57,57,2,2,true)
    printc("press ❎ or 🅾️ to restart",60,77,7,0,0)
  else
    printc("you have fallen back down",64,49,7,0,0)
    spr(100,57,57,2,2,true)
    printc("press ❎ or 🅾️ to try again",60,77,7,0,0)
  end
end