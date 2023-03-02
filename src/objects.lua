-->8
--object logic

--object spawn list
--1/2:  map coordinates x/y
--3/4:  collision width/height
--5/6:  sprite index #s for
--      before/after states
--7/8:  map coordinates for
--      after sprites
--9/10: width/height of after
--      sprites
--11:   sfx index number

objs={}
objs.init=function()
	objs.obj={}
	local object={}
	object.x=13
	object.y=42
	object.w=8
	object.h=8
	object.s1=63
	object.s2=0
	object.aw=8
	object.ah=8
	object.sfx=1
	object.done=false
	add(objs.all,object)
end

objs.draw=function()
--draws the "clean" sprite,
--then draws the broken sprite
--over that sprite; allows for
--partial updates (slightly
--wasteful but it works 😐)
	for o in all(objs.all) do
		if not o.done then
			spr(o.s1,o.x,o.y,
			(o.w+1)/8,(o.h+1)/8)
		else
			spr(o.s2,o.x2,o.y2,
			(o.w2+1)/8,(o.h2+1)/8,
			false,o.flip)
		end
	end
end

objs.interact=function()
	for o in all(objs.all) do
	  if (overlap(p1,o)) 
	  and btnp(3) and not
	  o.done then
		p1.objs+=1
		sfx(o.sfx, 3)
		o.done=true
	  end
	end
  end

--mboffin's overlap function
function overlap(a,b)
	return not (a.x>b.x+b.w or
				a.y>b.y+b.h or
				a.x+a.w<b.x or
				a.y+a.h<b.y)
	end