--player functions

--make the player
function m_player(x,y)
  
  --todo: refactor with m_vec.
  local p=
  {
    x=x,
    y=y,

    dx=0,
    dy=0,

    w=16,
    h=16,

    max_dx=1,--max x speed
    max_dy=2,--max y speed

    jump_speed=-1.5,--jump velocity
    acc=0.05,--acceleration
    dcc=0.4,--decceleration
    air_dcc=0.9,--air decceleration
    grav=0.15,

    --helper for more complex
    --button press tracking.
    --todo: generalize button index.
    jump_button=
    {
        update=function(self)
            --start with assumption
            --that not a new press.
            self.is_pressed=false
            if btn(5) then
                if not self.is_down then
                    self.is_pressed=true
                end
                self.is_down=true
                self.ticks_down += 1
            else
                self.is_down=false
                self.is_pressed=false
                self.ticks_down=0
            end
        end,
        --d
        is_pressed=false,--pressed this frame
        is_down=false,--currently down
        ticks_down=0,--how long down
    },

    jump_hold_time=0,--how long jump is held
    min_jump_press=5,--min time jump can be held
    max_jump_press=15,--max time jump can be held

    grounded=false,--on ground

    airtime=0,--time since grounded
    
    dash_hold_time=0,   --how long dash is held
    max_dash_press=10,   --max time dash can be held
    max_dash_dtime=10,  --max time dash dx can be applied

    max_dash_dx=6,--max x speed while dashing
    max_dash_dy=6,--max y speed while dashing
    dash_speed=-1.75,--dash velocity

    dash_dirx = 0,
    dash_diry = 0,
    can_dash=true,

    dash_button=
    {
        update=function(self)
            --start with assumption
            --that not a new press.
            self.is_pressed=false
            if btn(4) then
                if not self.is_down then
                    self.is_pressed=true
                end
                self.is_down=true
                self.ticks_down+=1
            else
                self.is_down=false
                self.is_pressed=false
                self.ticks_down=0
            end
        end,
        --d
        is_pressed=false,--pressed this frame
        is_down=false,--currently down
        ticks_down=0,--how long down
    },

    --animation definitions.
    --use with set_anim()
    anims=
    {
        ["stand"]=
        {
            ticks=30,--how long is each frame shown.
            frames={68},--what frames are shown.
        },
        ["walk"]=
        {
            ticks=5,
            frames={100,102},
        },
        ["jump"]=
        {
            ticks=15,
            frames={104},
        },
        ["slide"]=
        {
            ticks=11,
            frames={102},
        },
    },

    curanim="walk",--currently playing animation
    curframe=1,--curent frame of animation.
    animtick=0,--ticks until next frame should show.
    flipx=false,--should sprite be flipped?

    --request new animation to play.
    set_anim=function(self,anim)
      if(anim==self.curanim)then return--early out.
      end
      local a=self.anims[anim]
      self.animtick=a.ticks--ticks count down.
      self.curanim=anim
      self.curframe=1
    end,
  
    --STAR PLATFORMS (I know these should probably not be in the player script but whatever)
    
    --Star platform locations:
    star_loc = {{41, 54}, {36, 46}, {45, 40}, {45, 36}, {45, 32}, 
    {40, 48}, {38, 30}, {40, 24}, {39, 16}, {44,13}, {43, 6}},

    star_anims=
    {
        ["solid"]=
        {
            ticks=200,--how long is each frame shown.
            frames={82},--what frames are shown.
        },
        ["disappearing"]=
        {
            ticks=4,--how long is each frame shown.
            frames={87, 71, 70, 0},--what frames are shown.
        },
        ["gone"]=
        {
            ticks=200,--how long is each frame shown.
            frames={0},--what frames are shown.
        },
        ["appearing"]=
        {
            ticks=4,--how long is each frame shown.
            frames={0, 70, 71, 87},--what frames are shown.
        },
    },

    star_global_ticks = 0, --a global timer that determines what stage the star platforms are in
    --ticks 0-199: solid
    --ticks 200-215: disappearing
    --ticks 216-415: gone
    --ticks 415-431: appearing
    --tick 432 resets the ticks to 0

    star_curanim="solid",--currently playing animation
    star_curframe=1,--curent frame of animation.
    star_animtick=0,--ticks until next frame should show.

    --request new animation to play.
    star_set_anim=function(self,star_anim)
      if(star_anim==self.star_curanim)then return--early out.
      end
      local a=self.star_anims[star_anim]
      self.star_animtick=a.ticks--ticks count down.
      self.star_curanim=star_anim
      self.star_curframe=1
    end,

    --call once per tick.
    update=function(self)

      --track button presses
      bl=btn(0) --left
      br=btn(1) --right
      bu=btn(2) --up
      bd=btn(3) --down

      --move left/right
      if bl==true then
        self.dx-=self.acc
        br=false--handle double press
      elseif br==true then
        self.dx+=self.acc
      else
        if self.grounded then
          self.dx*=self.dcc
        else
          self.dx*=self.air_dcc
        end
      end

      --limit walk speed
      if self.dash_hold_time>0 and self.dash_hold_time<self.max_dash_dtime then
        self.dx=mid(-self.max_dash_dx,self.dx,self.max_dash_dx)
      else
        self.dx=mid(-self.max_dx,self.dx,self.max_dx)
      end
      
      --move in x
      self.x+=self.dx
      
      --hit walls
      collide_side(self)

      --jump buttons
      self.jump_button:update()

      --jump is complex.
      --we allow jump if:
      --    on ground
      --    recently on ground
      --    pressed btn right before landing
      --also, jump velocity is
      --not instant. it applies over
      --multiple frames.
      if self.jump_button.is_down then
        --is player on ground recently.
        --allow for jump right after 
        --walking off ledge.
        local on_ground=(self.grounded or self.airtime<5)
        --was btn presses recently?
        --allow for pressing right before
        --hitting ground.
        local new_jump_btn=self.jump_button.ticks_down<10
        --is player continuing a jump
        --or starting a new one?
        if self.jump_hold_time>0 or (on_ground and new_jump_btn) then
          if self.jump_hold_time==0 then --new jump snd
            if self.jump_speed==-3 then
              sfx(snd.cloud)
            else
              sfx(snd.jump)
            end
          end
          self.jump_hold_time+=1
          --keep applying jump velocity
          --until max jump time.
          if self.jump_hold_time<self.max_jump_press then
            self.dy=self.jump_speed--keep going up while held
          end
          p1.cloud_jump=false
        end
      else
          self.jump_hold_time=0
      end

      -- no dashing until level 2
      if state >= 4 then
        --shake camera during a dash
        if btnp(4) and 
        can_dash and 
        self.dash_hold_time==0 then
            cam:shake(15,2)
        end

        if bl and not br then dash_dirx = 1
        elseif br and not bl then dash_dirx = -1
        else dash_dirx = 0
        end

        if bd and not bu then dash_diry = -1
        elseif bu and not bd then dash_diry = 1
        else dash_diry = 0
        end

        --if abs(dash_dirx)+abs(dash_diry) > 1 then
          --dash_dirx *= (sqrt(2)/2)
          --dash_diry *= (sqrt(2)/2)
        --end

        self.dash_button:update()
        --dash is complex.
        --dash can be done in midair
        --but only once before needing to refresh
        --refresh happens when hitting the ground
        --also, dash velocity is
        --not instant. it applies over
        --multiple frames.
        if self.dash_button.is_down then
          --is player continuing a dash
          --or starting a new one?
          if can_dash then
            if(self.dash_hold_time==0)sfx(snd.dash)--new dash snd
            self.dash_hold_time+=1
            --keep applying dash velocity
            --until max dash time.
            if self.dash_hold_time<self.max_dash_press then
              self.dy=self.dash_speed*dash_diry
              self.dx=self.dash_speed*dash_dirx
            else
              can_dash=false
            end
          end
        else
          self.dash_hold_time=0
        end
      end
      --move in y
      self.dy+=self.grav
      if self.dash_hold_time>0 and self.dash_hold_time<self.max_dash_dtime then
        self.dy=mid(-self.max_dash_dy,self.dy,self.max_dash_dy)
      else
        self.dy=mid(-self.max_dy,self.dy,self.max_dy)
      end
      self.y+=self.dy

      --floor
      if not collide_floor(self) then
        self:set_anim("jump")
        self.grounded=false
        self.airtime+=1
      else
        can_dash=true
      end

      --roof
      collide_roof(self)

      --handle playing correct animation when
      --on the ground.
      if self.grounded then
        if br then
          if self.dx<0 then
              --pressing right but still moving left.
              self:set_anim("slide")
          else
              self:set_anim("walk")
          end
        elseif bl then
          if self.dx>0 then
            --pressing left but still moving right.
            self:set_anim("slide")
          else
            self:set_anim("walk")
          end
        else
          self:set_anim("stand")
        end
      end

      --flip
      if bl then
        self.flipx=false
      elseif br then
        self.flipx=true
      end

      --anim tick
      self.animtick-=1
      if self.animtick<=0 then
        self.curframe+=1
        local a=self.anims[self.curanim]
        self.animtick=a.ticks--reset timer
        if self.curframe>#a.frames then
            self.curframe=1--loop
        end
      end

      self.star_global_ticks+=1

      --star anim ticks
      self.star_animtick-=1
      if self.star_animtick<=0 then
        self.star_curframe+=1
        local a=self.star_anims[self.star_curanim]
        self.star_animtick=a.ticks--reset timer
        if self.star_curframe>#a.frames then
            self.star_curframe=1--loop
        end
      end

      if self.star_global_ticks < 200 then
        self:star_set_anim("solid")
      elseif self.star_global_ticks < 216 then
        self:star_set_anim("disappearing")
      elseif self.star_global_ticks < 416 then
        self:star_set_anim("gone")
      elseif self.star_global_ticks < 432 then
        self:star_set_anim("appearing")
      else
        self.star_global_ticks = 0
      end
    end,

    --draw the player
    draw=function(self)
      local a=self.anims[self.curanim]
      local frame=a.frames[self.curframe]
      spr(frame,
        self.x-(self.w/2),
        self.y-(self.h/2),
        self.w/8,self.h/8,
        self.flipx,
        false)
    end,

    draw_star_platforms=function(self)
      local a=self.star_anims[self.star_curanim]
      local frame=a.frames[self.star_curframe]
      
      local width = 1

      for s in all(self.star_loc) do
        if(self.star_curanim == "solid") then
          width = 2
          mset(s[1], s[2], 82)        
          mset(s[1]+1, s[2], 83)
        else
          mset(s[1], s[2], 0)
          mset(s[1]+1, s[2], 0)
        end

        spr(frame, s[1] * 8, s[2] * 8, width, 1, false, false)
      end
    end,
  }
  return p
end