pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
function _init()
	spd = .2
	isgameover = false
	score = 0
	alive = 3
	shk = 0
	
	players = {}
	
	btns={⬇️,⬇️,⬇️}
	for i=1,3 do
		add(players,{
			n=i,
			s=i,
			d = false,
			
			x=128-i*20,
			y=i*40-20,
			
			bx=1,
			by=1,
			bw=6,
			bh=6,
			
			g=0.1,
			
			dx=0,
			dy=0,
			btn_=btns[i]
		})
	end
	
	enemies = {}
	spawntimer={0,0,0}
end

function _update60()
	if not isgameover then
		score += 0.1
		
		for p in all(players)do
			if not p.d then 
				player_update(p)
			end
		end
		
		for i=1,3 do
			spawntimer[i]-=1
			if spawntimer[i]<0 then
				spawntimer[i]=60+rnd(50)
				
				add(enemies,{
					s=5,
					
					x=128,
					y=i*40-8-rnd(3*8),
					dx=-0.5-rnd(0.3),
				})
			end
		end
		
		for e in all(enemies)do
			e.x+=e.dx
		end
		
		shk *= 0.9
	end
end

function _draw()
	camera(rnd(shk)-shk,rnd(shk)-shk)
	
	cls(12)
	if not isgameover then
		print(flr(score), 15, 15)
		map()
		for p in all(players)do
			if not p.d then 
				spr(p.s,p.x,p.y)
			end
		end
		
		for e in all(enemies)do
			spr(e.s,e.x,e.y)
		end
		
		for i=0,128,8do
			local y = sin(t()+i/16)*0.9
			spr(16,y,i)
			spr(17,121-y,i)
		end
	end
	if isgameover then
		print("you ded",50,64)
		print('yOUR SCORE WAS '.. tostr(flr(score))..'\n you noob',40,80 )
	end
end

-->8
--player

function player_update(p)
	if btn(⬆️) and p.colly then
		p.dy = -2
	end
	if(btn(⬅️))p.dx-=0.2
	if(btn(➡️))p.dx+=0.2
	
	if p.x <-8 or p.x >128 then
		for a= p.n,3 do
			if not players[a].d then 
				players[a].d = true
				players[a].x = 0
				alive -= 1
			end
		end
		if alive <= 0 then
			isgameover = true
		end
	end
	
	p.dx *= 0.9
	p.dy += p.g
	
	local x,y,xy=iscoll(p)
	p.colly=y
	
	collide(p,x,y,xy)
	
	p.x += p.dx
	p.y += p.dy
	
	for e in all(enemies)do
		local c=rect_overlap(
		p,
		{x=p.x+p.bw+p.bw, 
		y=p.y+p.by+p.bh},
		{x=e.x+2, y=e.y+2},
		{x=e.x+6, y=e.y+6})
		
		if(c) p.dx-=1
	end
end

-->8
--collision
function is_solid(x,y)
	if(y<0 or y>128)return true
	return check_flag(0,x,y)
end

function touches_rect(x,y,x1,y1,x2,y2)
	return x1 <= x
	   and x2 >= x
	   and y1 <= y
	   and y2 >= y
end

function rect_overlap(a1,a2,b1,b2)
	return a1.x<b2.x
	   and a1.y<b2.y 
	   and a2.x>b1.x
	   and a2.y>b1.y--]]
end

function collision(x,y,w,h,flag)
	return 
	   is_solid(x,  y)
	or is_solid(x+w,y)
	or is_solid(x,  y+h)
	or is_solid(x+w,y+h) 
end


function check_flag(flag,x,y)
	return fget(mget((x\8),(y\8)),flag)
end

function iscoll(o,bounce1)
	local x,y = o.x,o.y
	local dx,dy = o.dx,o.dy
	local w,h = o.bw,o.bh
	local ox,oy = x+o.bx,y+o.by
	local bounce = 0.4
	
	--collisions
	local we,he = w-1, h-1
	local coll_x = collision( 
	ox+dx, oy,    we, he)
	local coll_y = collision(
	ox,    oy+dy, we, he)
	local coll_xy = collision(
	ox+dx, oy+dy, we, he)
	
	return coll_x,coll_y,coll_xy
end

function collide(o,coll_x,coll_y,coll_xy)
	bounce=0.1
	if coll_x then
		o.dx *= -bounce
	end
	
	if coll_y then
		o.dy *= -bounce
	end
	
	if coll_xy and 
	not coll_x and not coll_y then
		--prevent stuck in corners 
		o.dx *= -bounce
		o.dy *= -bounce
	end
end
__gfx__
000000000088888000aa0aa000d66d0077d777770444440000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000088888888888aa8880d6666d066d666664444440000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070007717717888aa8880661616066d666664ffff40000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700007e1771e0224422006166610dddddddd0f1f1f0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000071777710881a1800666664477777d7700fff00000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070077711117088aa880d661166266666d660178110000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000077777770088111806666660466666d660177110000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000007777700081aa81006666004dddddddd0010100000000000000000000000000000000000000000000000000000000000000000000000000000000000
7a900000000001c70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77a9000000001c770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777a90000001c7770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777a90000001c7770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777a90000001c7770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777a90000001c7770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77a9000000001c770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7a900000000001c70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0404040404040404040404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040404040404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040404040404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0404040404040404040404040404040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
