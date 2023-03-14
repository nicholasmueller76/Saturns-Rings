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
    dcc=0.5,--decceleration
    air_dcc=1,--air decceleration
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

    jump_hold_time=0,--how long jump is held
    min_jump_press=5,--min time jump can be held
    max_jump_press=15,--max time jump can be held

    grounded=false,--on ground

    airtime=0,--time since grounded
    
    dash_hold_time=0,   --how long dash is held
    max_dash_press=7,   --max time dash can be held
    max_dash_dtime=20,  --max time dash dx can be applied

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
      if(anim==self.curanim)return--early out.
      local a=self.anims[anim]
      self.animtick=a.ticks--ticks count down.
      self.curanim=anim
      self.curframe=1
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
            if self.jump_speed==-2 then
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
  }
  return p
end