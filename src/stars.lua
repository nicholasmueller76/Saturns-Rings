-->8
--star parallax bg
--from lexaloffle.com/bbs/?pid=20624
stars={}

stars.bright=7
stars.dark=5
stars.init=function()
    stars.all={}
    for i=0,32 do
        s = {}
        s.x = rnd(128)
        s.y = rnd(100)+10
        s.c = i/32
        s.col = stars.dark
        if s.c>0.75 then s.col=stars.bright end
        add(stars.all,s)
    end
end

stars.draw=function()
    for s in all(stars.all) do
        --%n is where stars will stop on y axis
        pset(s.x,(s.y+ticks*s.c)%128,s.col)
    end
end