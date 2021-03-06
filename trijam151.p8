pico-8 cartridge // http://www.pico-8.com
version 34
__lua__
function _init()
	spd = .2
	isgameover = false
	score = 0
	alive = 3
	shk = 0
	newhi=false
	
	hiscore = 0
	if stat(6) != "" and 
	stat(6) != nil then
		local n=tonum(stat(6))
		if n>hiscore then
			hiscore=n
		end
	end
	
	players = {}
	
	btns={⬇️,⬇️,⬇️}
	for i=1,3 do
		add(players,{
			n=i,
			s=i,
			d = false,
			
			x=100,
			y=i*40-20,
			
			bx=1,
			by=1,
			bw=6,
			bh=6,
			
			g=0.1,
			
			dx=0,
			dy=0,
			btn_=btns[i],
			
			sfxt=30,
		})
	end
	
	enemies = {}
	spawntimer={0,0,0}
end

function _update60()
	if not isgameover then
		score += 0.1 * alive
		
		for p in all(players)do
			if not p.d then 
				player_update(p)
			end
		end
		
		for i=1,3 do
			spawntimer[i]-=1
			if spawntimer[i]<0 and not players[i].d then
				spawntimer[i]=max(15*alive+rnd(10) + 20/(score/2),30)
				
				local t = rnd{1,2}
				if t==1 then
					add(enemies,{
						t=1,
						s=5,
						
						x=128,
						y=i*40-8-rnd(3*8),
						dx=-0.5-rnd(0.3),
					})
				elseif t==2 then
					add(enemies,{
						t=t,
						s=6,
						
						x=128,
						y=0,
						oy=i*40-20,
						dx=-0.5-rnd(0.3),
					})
				end
				
			end
		end
		
		for e in all(enemies)do
			e.x+=e.dx
		end
		
		shk *= 0.9
	end
	
	for e in all(enemies)do
		e.x+=e.dx
		if(e.x<-8)del(enemies,e)
		if(e.t==2)e.y=e.oy+sin(e.x/70)*12
	end
	
	shk =max(0, shk-0.5)
	
	if score>hiscore then
		hiscore=score
		newhi = true
	end
	
	if isgameover and btn(❎) then
		run(tostr(hiscore))
	end
end

function _draw()
	camera(rnd(shk)-shk,0)--rnd(shk)-shk)
	
	cls(12)
	if not isgameover then
		print("\^w\^t"..tostr(flr(score)), 15, 15,7)
		print("hi "..tostr(hiscore\1),15,30,7)
		map()
		for p in all(players)do
			if not p.d then 
				ospr(p.s,p.x,p.y,1,1,0)
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
		print("\^w\^tyou ded",40,20,7)
		print('yOUR SCORE WAS '.. tostr(flr(score))..'\n lol',20,40 )
		print("highest score: "..tostr(hiscore\1),20,60 )
		if newhi then
			print("new highscore!",20,80,10)
		end
		print("press ❎ to restart",20,100,7)
	end
end

-->8
--player

function player_update(p)
	if btn(⬆️) and p.colly then
		p.dy = -2
		sfx(0)
	end
	if(btn(⬅️))p.dx-=0.2
	if(btn(➡️))p.dx+=0.2
	
	if p.x <-4 then
		for a= p.n,3 do
			if not players[a].d then 
				players[a].d = true
				sfx(2)
				shk = 8
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
		
		if c then
			p.dx-=1
			if p.sfxt==0 then
				sfx(1)
				p.sfxt=30
			end
		end
	end
	
	p.sfxt=max(p.sfxt-1,0)
end

-->8
--collision
function is_solid(x,y)
	if(x>125 or y<0 or y>128)return true
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
	bounce=0.05
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
-->8
function ospr(s,x,y,w,h,col)
	w=w or 1
	h=h or 1
	col=col or 1
	local a=col
	pal{a,a,a, a,a,a,a, a,a,a,a, a,a,a,a,}
	for i=-1,1 do
		for j=-1,1 do
			spr(s,x+i,y+j,w,h)
		end
	end
	pal()
	pal(1,129,1)
	spr(s,x,y,w,h)
end
__gfx__
000000000088888000aa0aa000d66d0077d777770444440000111101000000000000000000000000000000000000000000000000000000000000000000000000
0000000088888888888aa8880d6666d066d666664444440001cccc21000000000000000000000000000000000000000000000000000000000000000000000000
0070070007717717888aa8880661616066d666664ffff4001c77cc21000000000000000000000000000000000000000000000000000000000000000000000000
0007700007e1771e0224422006166610dddddddd0f1f1f0017771121000000000000000000000000000000000000000000000000000000000000000000000000
00077000071777710881a1800666664477777d7700fff00017711121000000000000000000000000000000000000000000000000000000000000000000000000
0070070077711117088aa880d661166266666d660178110011117721000000000000000000000000000000000000000000000000000000000000000000000000
0000000077777770088111806666660466666d660177110001171121000000000000000000000000000000000000000000000000000000000000000000000000
0000000007777700081aa81006666004dddddddd0010100000111101000000000000000000000000000000000000000000000000000000000000000000000000
7a900000000001c70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77a9000000001c770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777a90000001c7770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777a90000001c7770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777a90000001c7770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777a90000001c7770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77a9000000001c770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7a900000000001c70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
a9d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d777hc
7a96666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d66hc7
77a9666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6hc77
77a9ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddhc77
77a97d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d777777hc77
77a96d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d666666hc77
7a966d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666hc7
a9ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddhc
7a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc7
77a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc77
777a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc777
777a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc777
777a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc777
777a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc777
77a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc77
7a9cccccccccccc777777cc7777cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc7
a9ccccccccccccc777777cc7777ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc
7a9cccccccccccccccc77cccc77ccccccccccccccccccccccccccccccccccccccccccccccchhhhchccccccccccccccccccccccccccccccccccccccccccccchc7
77a9ccccccccccccccc77cccc77cccccccccccccccccccccccccccccccccccccccccccccchcccc2hcccccccccccccccccccccccccccccccccccccccccccchc77
77a9ccccccccccccccc77cccc77ccccccccccccccccccccccccccccccccccccccccccccchc77cc2hcccccccccccccccccccccccccccccccccccccccccccchc77
77a9ccccccccccccccc77cccc77ccccccccccccccccccccccccccccccccccccccccccccch777hh2hcccccccccccccccccccccccccccccccccccccccccccchc77
77a9ccccccccccccccc77cccc77ccccccccccccccccccccccccccccccccccccccccccccch77hhh2hcccccccccccccccccccccccccccccccccccccccccccchc77
7a9cccccccccccccccc77cccc77ccccccccccccccccccccccccccccccccccccccccccccchhhh772hccccccccccccccccccccccccccccccccccccccccccccchc7
a9ccccccccccccccccc77cc777777cccccccccccccccccccccccccccccccccccccccccccchh7hh2hcccccccccccccccccccccccccccccccccccccccccccccchc
7a9cccccccccccccccc77cc777777ccccccccccccccccccccccccccccccccccccccccccccchhhhchccccccccccccccccccccccccccccccccccccccccccccchc7
77a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc77
777a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc777
777a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc777
777a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc777
777a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc777
77a9ccccccccccc7c7c777ccccc777c77ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc77
7a9cccccccccccc7c7cc7cccccccc7cc7cccccccccccccccccchhhhchccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchhhhchc7
a9ccccccccccccc777cc7cccccccc0000000cccccccccccccchcccc2hcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchcccc2hhc
7a9cccccccccccc7c7cc7cccccc0008888800cccccccccccchc77cc2hccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc77cc2hc7
77a9ccccccccccc7c7c777ccccc0888888880cccccccccccch777hh2hccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccch777hhhc77
77a9ccccccccccccccccccccccc0077h77h70cccccccccccch77hhh2hccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccch77hhhhc77
77a9cccccccccccccccccccccccc07eh77he0cccccccccccchhhh772hccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchhhh77hc77
77a9ccccccccccccccccccccccc007h7777h0ccccccccccccchh7hh2hcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchh7hhhc77
7a9cccccccccccccccccccccccc0777hhhh70cccccccccccccchhhhchccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchhhhchc7
a9ccccccccccccccccccccccccc0777777700ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc
7a97777777d7777777d7777777d007777700777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d77hc7
77a9666666d6666666d6666666d600000006666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6hc77
777a966666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666dhc777
777a9ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddhc777
777a9d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d77777hc777
777a9d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d66666hc777
77a96d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d666666hc77
7a9ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddhc7
a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc
7a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc7
77a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc77
77a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc77
77a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc77
77a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc77
7a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc7
a9cccccccccccccccccccccccccccccchhhhchcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc
7a9cccccccccccccccccccccccccccchcccc2hccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc7
77a9cccccccccccccccccccccccccchc77cc2hcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc77
777a9ccccccccccccccccccccccccch777hh2hccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc777
777a9ccccccccccccccccccccccccch77hhh2hccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc777
777a9ccccccccccccccccccccccccchhhh772hccccccccccccccccccccccccccccccc44444ccccccccccccccccccccccccccccccccccccccccccccccccchc777
777a9cccccccccccccccccccccccccchh7hh2hcccccccccccccccccccccccccccccc444444ccccccccccccccccccccccccccccccccccccccccccccccccchc777
77a9cccccccccccccccccccccccccccchhhhchcccccccccccccccccccccccccccccc4ffff4cccccccccccccccccccccccccccccccccccccccccccccccccchc77
7a9ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccfhfhfccccccccccccccccccccccccccccccccccccccccccccccccccchc7
a9ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccfffccccccccccccccccccccccccccccccccccccccccccccccccccccchc
7a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccch78hhccccccccccccccccccccccccccccccccccccccccccccccccccchc7
77a9ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccch77hhcccccccccccccccccccccccccccccccccccccccccccccccccchc77
77a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchchccccccccccccccccccccccccccccccccccccccccccccccccccchc77
77a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc77
77a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc77
7a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc7
a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchhhhhc
7a9ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000cccccccccccccccccccccccccccccccchccchc7
77a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000aa0aa00cccccccccccccccccccccccccccccchc77hc77
777a9ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0888aa8880cccccccccccccccccccccccccccccch77hc777
777a9ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0888aa8880cccccccccccccccccccccccccccccch77hc777
777a9ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0022442200cccccccccccccccccccccccccccccchhhhc777
777a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc088hah80cccccccccccccccccccccccccccccccchhhc777
77a9ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc088aa880ccccccccccccccccccccccccccccccccchhhc77
7a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc088hhh80cccccccccccccccccccccccccccccccccccchc7
a9d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d77777708haa8h07d7777777d7777777d7777777d7777777d777hc
7a96666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d666666000000006d6666666d6666666d6666666d6666666d66hc7
77a9666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6hc77
77a9ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddhc77
77a97d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d777777hc77
77a96d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d666666hc77
7a966d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666hc7
a9ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddhc
7a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc7
77a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc77
777a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc777
777a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc777
777a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc777
777a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc777
77a9ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc44444cccccccccccccccccccccccccccccccchc77
7a9ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc444444ccccccccccccccccccccccccccccccccchc7
a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc4ffff4cccccccccccccccccccccccccccccccccchc
7a9ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccfhfhfccccccccccccccccccccccccccccccccchc7
77a9ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccfffccccccccccccccccccccccccccccccccchc77
77a9ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccch78hhcccccccccccccccccccccccccccccccchc77
77a9ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccch77hhcccccccccccccccccccccccccccccccchc77
77a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchchccccccccccccccccccccccccccccccccchc77
7a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc7
a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc
7a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc7
77a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc77
777a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc777
777a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc777
777a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc777
777a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc777
77a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc77
7a9ccccccccccccccccccccccccccccccccccccccccccccccccccccchhhhchccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccchc7
a9ccccccccccccccccccccccccccccccccccccccccccccccccccccchcccc2hcccccccccccccccccccccccccccccc000000cccccccccccccccccccccccccccchc
7a9ccccccccccccccccccccccccccccccccccccccccccccccccccchc77cc2hccccccccccccccccccccccccccccc00d66d00cccccccccccccccccccccccccchc7
77a9cccccccccccccccccccccccccccccccccccccccccccccccccch777hh2hccccccccccccccccccccccccccccc0d6666d0ccccccccccccccccccccccccchc77
77a9cccccccccccccccccccccccccccccccccccccccccccccccccch77hhh2hccccccccccccccccccccccccccccc066h6h60ccccccccccccccccccccccccchc77
77a9cccccccccccccccccccccccccccccccccccccccccccccccccchhhh772hccccccccccccccccccccccccccccc06h666h00cccccccccccccccccccccccchc77
77a9ccccccccccccccccccccccccccccccccccccccccccccccccccchh7hh2hcccccccccccccccccccccccccccc0066666440cccccccccccccccccccccccchc77
7a9ccccccccccccccccccccccccccccccccccccccccccccccccccccchhhhchcccccccccccccccccccccccccccc0d66hh6620ccccccccccccccccccccccccchc7
a9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0666666040cccccccccccccccccccccccccchc
7a97777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d77777770066660040777777d7777777d7777777d77hc7
77a9666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d000000000666666d6666666d6666666d6hc77
777a966666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666dhc777
777a9ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddhc777
777a9d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d7777777d77777hc777
777a9d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d66666hc777
77a96d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d6666666d666666hc77
7a9ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddhc7

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
__sfx__
000100002005022050250502605027050270502805028050280502b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000012050120501205012050110500f0500e0500d0500b0500705001050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000024250202501e2501a25014250102500b25008250072500625004250022500125000250002500025000250002500025000200002000020000200002000020000200002000020000200002000020000200
