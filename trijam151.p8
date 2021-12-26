pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
function _init()
	spd = .3
	isGameOver = false
	score = 0

	players = {}
	for i=1,3 do
		add(players,{
			n=i,
			s=i,
			
			x=rnd(128),
			y=rnd(128),
			
			bx=1,
			by=1,
			bw=6,
			bh=6,
			
			dx=0,
			dy=0,
		})
	end
end

function _update60()
	score += 0.1

	for p in all(players)do
		if(btn(⬅️))p.dx -= spd
		if(btn(➡️))p.dx += spd
		if(btn(⬆️))p.dy -= spd
		if(btn(⬇️))p.dy += spd
		
		if p.dx <0 then
			isGameOver = true
		end

		p.dx *= 0.95
		p.dy *= 0.95
		
		collide(p)
		
		p.x += p.dx
		p.y += p.dy
	end
end

function _draw()
	cls()
	map()
	
	for p in all(players)do
		spr(p.s,p.x,p.y)
	end
end

-->8
--collision
function is_solid(x,y)
	return check_flag(0,x,y)
end

function touches_rect(x,y,x1,y1,x2,y2)
	return x1 <= x
	   and x2 >= x
	   and y1 <= y
	   and y2 >= y
end
--[[
function circ_coll(a,b)
	--https://www.lexaloffle.com/bbs/?tid=28999
	--b: bullet
	local dx=a.x+4 - b.x
	local dy=a.y+4 - b.y
	local d = max(dx,dy)
	dx /= d
	dy /= d
	local sr = (a.r+b.r)/d
	
	return dx*dx+dy*dy < sr*sr 
end
--]]

function rect_overlap(a1,a2,b1,b2)
	--[[return not (a1.x>b2.x
	         or a1.y>b2.y 
	         or a2.x<b1.x
	         or a2.y<b1.y)--]]
	
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

function collide(o,bounce1)
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006606000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000066666000d00d0000888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000666666600d00d0008880800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000066666660000000d88000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700666666600d0000dd80000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000ddddd0088008800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000008880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
