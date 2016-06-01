-- created for the pico8 jam 2
-- in two days by @friedyeti
-- theme was "chain reaction"

-- config
numberofcircles = 32
numberofshots = 5

useseed = false
seed = 8675309

-- called once at the start
function _init()
	cls()
	if(useseed) then srand(seed) end
	circle = {}
	explodedcircle = {}
	for x=1,numberofcircles do
		make_circle(rnd(127),rnd(127),2+rnd(5),6,.1+rnd(1),rnd(2)-1,rnd(2)-1)
	end
	crosshair = {}
	crosshair.x = 64
	crosshair.y = 64
	crosshair.shotsremaining = numberofshots

	gamemenu = true
	gamewon = false
	gamelost = false

	endgametimer = 60

	flashingtext = {}
	flashingtext.color = 7
	flashingtext.countdown = 50
	music(0,0,1)
end

-- called once a frame
function _update()
	handle_input()
	if(gamemenu) then countdown_flashing_text() end
	if(not gamemenu) then
		foreach(circle,move_circle)
		foreach(circle,check_collision_with_exploded_circles)
		foreach(explodedcircle,decay_exploded_circle)
		if(not (gamewon or gamelost)) then	check_if_won() end
		if(gamewon or gamelost) then
			if(btnp(4) and endgametimer < 0) then _init() end
		end
	end
end

-- called once a frame
function _draw()
	cls()
	if(gamemenu) then
		spr(8,32,16,8,8)
		print("destroy all circles!",26,90,7)
		print("press z to start", 32,97,flashingtext.color)
		print("@friedyeti",44,120,6)
		print("#p8jam2",50,114,6)
		spr(32,35,118)
	else
		foreach(explodedcircle,draw_exploded_circle)
		foreach(circle,draw_circle)
		spr(1,crosshair.x-4,crosshair.y-4)
		if (crosshair.shotsremaining > 0)
			then for i=1,crosshair.shotsremaining
				do spr(16,8*i,8) end
		end
		if(gamewon) then print("you won!",50,50,7) end
		if(gamelost)
			then print("you lose!",48,50,7)
			print(count(circle).." remaining", 40,64,7) end
		if(gamewon or gamelost) then endgametimer = endgametimer - 1
			if(endgametimer < 0) then print ("press z to restart",30,80,7) end end
	end
end

function make_circle(x,y,circradius,circcolor,circspeed,circdx,circdy)
	local tempcircle = {}
	tempcircle.x = x
	tempcircle.y = y
	tempcircle.radius = circradius
	tempcircle.color = circcolor
	tempcircle.dx = circspeed * circdx
	tempcircle.dy = circspeed * circdy
	tempcircle.explosionradius = circradius

	add(circle,tempcircle)
	return tempcircle
end

function move_circle(currentcircle)
	currentcircle.x = currentcircle.x + currentcircle.dx
	currentcircle.y = currentcircle.y + currentcircle.dy
	if (currentcircle.x > 127) then currentcircle.x = 0 end
	if (currentcircle.x < 0) then currentcircle.x = 127 end
	if (currentcircle.y > 127) then currentcircle.y = 0 end
	if (currentcircle.y < 0) then currentcircle.y = 127 end
end

function draw_circle(currentcircle)
	circfill(currentcircle.x,currentcircle.y,currentcircle.radius,currentcircle.color)
--	circfill(currentcircle.x,currentcircle.y,currentcircle.radius-1,currentcircle.color)
--	if(currentcircle.radius < 3) then spr(2,currentcircle.x,currentcircle.y)
--	elseif(currentcircle.radius < 4) then spr(3,currentcircle.x,currentcircle.y)
--	elseif(currentcircle.radius < 5) then spr(4, currentcircle.x,currentcircle.y)
--	elseif(currentcircle.radius < 6) then spr(5,currentcircle.x, currentcircle.y)
--	else spr(6,currentcircle.x,currentcircle.y) end
end

function draw_exploded_circle(currentcircle)
	circfill(currentcircle.x,currentcircle.y,currentcircle.explosionradius,9)
	circfill(currentcircle.x,currentcircle.y,currentcircle.explosionradius-2,10)
	circfill(currentcircle.x,currentcircle.y,currentcircle.explosionradius/2,7)
end

function explode_circle(currentcircle)
--	currentcircle.color = 12
	sfx(1)
	currentcircle.timeremaining = 60
	add(explodedcircle,currentcircle)
	del(circle,currentcircle)
end

function decay_exploded_circle(currentcircle)
	currentcircle.explosionradius = currentcircle.explosionradius + currentcircle.radius * 0.0333333
	currentcircle.timeremaining = currentcircle.timeremaining - 1
	if (currentcircle.timeremaining < 0) then del(explodedcircle,currentcircle) end
end

function check_collision_with_exploded_circles(currentcircle)
	if(count(explodedcircle) > 0) then
		for i=1,count(explodedcircle)
			do collide_circles(currentcircle,explodedcircle[i])
		end
	end
end

function collide_circles(currentcircle,currentexplodedcircle)
	if((currentcircle.x < currentexplodedcircle.x + currentexplodedcircle.explosionradius)
		and (currentcircle.x > currentexplodedcircle.x - currentexplodedcircle.explosionradius)
		and (currentcircle.y < currentexplodedcircle.y + currentexplodedcircle.explosionradius)
		and (currentcircle.y > currentexplodedcircle.y - currentexplodedcircle.explosionradius))
			then explode_circle(currentcircle) end

end

function handle_input()
	if(btn(0)) then crosshair.x = crosshair.x - 1 end
	if(btn(1)) then crosshair.x = crosshair.x + 1 end
	if(btn(2)) then crosshair.y = crosshair.y - 1 end
	if(btn(3)) then crosshair.y = crosshair.y + 1 end

	if(crosshair.x > 127) then crosshair.x = 127 end
	if(crosshair.x < 0) then crosshair.x = 0 end
	if(crosshair.y > 127) then crosshair.y = 127 end
	if(crosshair.y < 0) then crosshair.y = 0 end

	if((btnp(4)) and (crosshair.shotsremaining > 0) and not gamemenu) then shoot()
	elseif((btnp(4)) and (gamemenu)) then gamemenu = false
		sfx(4) end
end

function shoot()
	-- check overlap with all circles
	-- if any overlap, call explode on them
	sfx(0)
	crosshair.shotsremaining = crosshair.shotsremaining - 1
	if (crosshair.shotsremaining < 0) then crosshair.shotsremaining = 0 end
	--foreach(circle,check_overlap_with_crosshair)
	local currentcircle = make_circle(crosshair.x,crosshair.y,2,8,0,0,0)
	sfx(1)
	currentcircle.timeremaining = 60
	add(explodedcircle,currentcircle)
	del(circle,currentcircle)
end

function check_overlap_with_crosshair(currentcircle)
	if((crosshair.x < currentcircle.x + currentcircle.radius)
		and (crosshair.x > currentcircle.x - currentcircle.radius)
		and (crosshair.y < currentcircle.y + currentcircle.radius)
		and (crosshair.y > currentcircle.y - currentcircle.radius))
			then explode_circle(currentcircle) end
end

function check_if_won()
	if(count(circle) < 1) then gamewon = true
		sfx(3)
	elseif((crosshair.shotsremaining < 1) and (count(explodedcircle) < 1)) then gamelost = true
		sfx(2) end
end

function countdown_flashing_text()
	flashingtext.countdown = flashingtext.countdown - 1
	if(flashingtext.countdown == 25) then flashingtext.color = 5 end
	if(flashingtext.countdown == 0)
		then flashingtext.color = 7
		flashingtext.countdown = 50 end
end
