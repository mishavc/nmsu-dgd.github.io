pico-8 cartridge // http://www.pico-8.com
version 27
__lua__

local inventory
local map_list
local player
local sheep
local debug_buffer
local game_statistics
local chat_window

function _init()
	map_list={}
	sheep=make_sheep(0,0)
	debug_buffer=""
	game_statistics={
		current_map=1,
		start_time=1,
		current_time=1,
		game_time=1,
		game_state="explore",
		change_map=function(self, newmap)
			self.current_map=newmap
		end,
		update=function(self)
			self.current_time=time()
			if (self.current_time-self.start_time)>=2 and self.game_time<24 then
				self.game_time+=1
				self.start_time=self.current_time
			elseif (self.current_time-self.start_time)>=2  and self.game_time>=24 then
				self.game_time=1
				self.start_time=self.current_time
			end
		end,
		draw=function(self)
			--debug_buffer=self.game_time
			line(94,114,94,118,10)
			line(95,114,95,118,10)
			line(100,114,100,118,9)
			line(101,114,101,118,9)
			spr(113,94,108,1,1,false,true)
			spr(113,94,116)
			if (self.game_time<=12) then
				sspr(112+(self.game_time),56,4,4,96,114)
			else
				sspr(112+((self.game_time-12)),60,4,4,96,114)
			end
		end
	}
	inventory={
		filled_spaces=0,
		inv_cursor=1,
		slot={},
		draw=function()
			--Update this to draw its own contents
			draw_window(0,104,15,2)
			rect(23,111,32,120,9)
			rect(34,111,43,120,9)
			rect(45,111,54,120,9)
			rect(56,111,65,120,9)
			rect(67,111,76,120,9)
			if inventory.inv_cursor==0 then
			else
				rect(((inventory.inv_cursor*11)+11),110,((inventory.inv_cursor*11)+22),121,7)
			end
		end
	}
	pump_menu={
		filled_spaces=0,
		menu_cursor=0,
		slot={},
		result=false,
		update=function()
			local ingrediants={dandelion=false,clover=false,violet=false}
			local last_flower={}
			for i=1,pump_menu.filled_spaces,1 do
				if pump_menu.slot[i].entity=="dandelion" then
					ingrediants.dandelion=true
					last_flower={"dandelion"}
				elseif pump_menu.slot[i].entity=="clover" then
					ingrediants.clover=true
					last_flower={"clover"}
				elseif pump_menu.slot[i].entity=="violet" then
					ingrediants.violet=true
					last_flower={"violet"}
				else
				end
			end
			--debug_buffer=debug_buffer..ingrediants.dandelion.."\n"..ingrediants.clover.."\n"..ingrediants.violet
			if pump_menu.slot[1] then
				if ingrediants.dandelion==true and ingrediants.clover==true and ingrediants.violet==true then
					pump_menu.result=make_milk({"dandelion","clover","violet"},"honeymilk",046,9,74)
				elseif ingrediants.dandelion==true or ingrediants.clover==true or ingrediants.violet==true then
					pump_menu.result=make_milk(last_flower,"flowermilk",047,9,74)
				else
					pump_menu.result=false
				end
			else
				pump_menu.result=false
			end
		end,
		draw=function()
			--Update this is to draw its own contents
			draw_window(1,9,2,9)
			rect(8,19,17,28,9)
			spr(112,9,29)
			rect(8,37,17,46,9)
			spr(112,9,47)
			rect(8,55,17,64,9)
			spr(113,9,65)
			rect(8,73,17,82,9)
			if pump_menu.menu_cursor==0 then
			else
				rect(7,18+((pump_menu.menu_cursor-1)*18),18,29+((pump_menu.menu_cursor-1)*18),7)
			end
			if pump_menu.result then
				pump_menu.result:draw()
			end
		end
	}
	
	chat_window={
		friend=sheep,
		sentence="2placeholder",
		chat_position=1,
		face=0,
		update=function(self)
			self.chat_position=self.friend.chat_state
			--debug_buffer=self.friend.chat_state
			if self.friend.chat_flag==1 then
				self.sentence=self.friend.chat_request[self.chat_position]
			elseif self.friend.chat_flag==2 then
				--Normal chat, no object selected
			elseif self.friend.chat_flag==3 then
				--Nope, that's the wrong object
			elseif self.friend.chat_flag==4 then
				self.sentence=self.friend.chat_reward[self.chat_position]
			else
				--Epilogue thank you
			end
			
			if btnp(4) or btnp(5) then
				self.face = tonum(sub(self.sentence,1,1))
				
				if self.face==3 then
					self.friend:setChatState(1)
					self.face=0
					game_statistics.game_state="explore"
				end
				
				self.friend.chat_state+=1
				
			end
			
			self.face = tonum(sub(self.sentence,1,1))
			
		end,
		draw=function(self)
			draw_window(0,104,15,2)
			if self.face==1 then 
				spr(11,106,108)
				spr(12,114,108)
				spr(27,106,116)
				spr(28,114,116)
				print(sub(self.sentence,2),10,110,6)
			elseif self.face==2 then
				spr(self.friend.portrait_sprites[1],5,108)
				spr(self.friend.portrait_sprites[2],13,108)
				spr(self.friend.portrait_sprites[3],5,116)
				spr(self.friend.portrait_sprites[4],13,116)
				print(sub(self.sentence,2),25,110,6)
			else
				if self.face==3 then
					self.face=0
					self.friend:setChatState(1)
					game_statistics.game_state="explore"
				end
			end
		end
	}
	
	player=make_tomi(56,20)
	make_map_list()
end

function draw_window(x1,y1,w,h)
	spr(064,x1,y1)
	for width=1,(w-1),1 do
		spr(065,x1+(width*8),y1)
	end
	spr(066,x1+(w*8),y1)
	for height=1,(h-1),1 do
		spr(080,x1,y1+(height*8))
		for width=1,(w-1),1 do
			
			spr(081,x1+(width*8),y1+(height*8))
		end
		spr(082,x1+(w*8),y1+(height*8))
	end
	spr(096,x1,y1+(h*8))
	for width=1,(w-1),1 do
		spr(097,x1+(width*8),y1+(h*8))
	end
	spr(098,x1+(w*8),y1+(h*8))
end

function _update()
    local obj
	for obj in all(map_list[game_statistics.current_map].objects) do
	    obj:update()
	end
	game_statistics:update()
	if game_statistics.game_state=="pump_menu" then
		pump_menu.update()
		player:update()
	elseif game_statistics.game_state=="chat" then
		chat_window:update()
	else
		player:update()
	end
end

function _draw()
    cls()
	--Draw Map tiles
	for map_tile in all(map_list[game_statistics.current_map].tiles) do
	    map_tile:draw()
	end
	--Draw Game objects
	for obj in all(map_list[game_statistics.current_map].objects) do
	    obj:draw()
	end
	--Draw Inventory or Chat Window
	if game_statistics.game_state=="chat" then
		chat_window:draw()
	else
		inventory.draw()
		for obj in all(inventory.slot) do
			obj:draw()
		end
	end
	--If in Pump_menu state, draw pump menu
	if game_statistics.game_state=="pump_menu" then
		pump_menu.draw()
		for obj in all(pump_menu.slot) do
			obj:draw()
		end
	end
	--Draw Player
	player:draw()
	print(debug_buffer,110,65,7)
	--Draw hitboxes
	--rect((player.x-2),(player.y+2),(player.x+4),(player.y+5),8)
	--rect((player.x+4),(player.y+2),(player.x+10),(player.y+5),12)
end

function make_map_list()
	map_field={
		"192193193193193193193193193193193193193193193194",
		"208209209241241209209241209209241241209241209210",
		"208209241241241241241241241241241241241241241210",
		"208209241241241241241241241241241241241241209210",
		"208241241241209241241241241241241241241241241210",
		"208241241241241241241241241241241241241241209210",
		"208209241241241241241241241209241241241241241210",
		"208241241241241209241241241241241241241241241210",
		"208241241241241241241241241241241209241241241210",
		"208241241241241241241209241241241241241241241210",
		"208209241209241241241241241241209241241241241210",
		"208209209241241241241241241241241209241241209210",
		"224225225225225225225225225225225225225225225226",
		"255255255255255255255255255255255255255255255255",
		"255255255255255255255255255255255255255255255255",
		"255255255255255255255255255255255255255255255255",
		"10;050070056;050056080;052015050;052040025;203033025;204041025;219033033;220041033;054092070;181120090",
	}
	map_cliff={
		"132133133133133133133133133133133133133133133133",
		"148180181180180149180180180149180181180180180180",
		"148180180181180180149180180180149180181180180180",
		"148180135136136136136136136136136136136136136138",
		"148180151152152152152152152152152152152152152154",
		"148180133133133133133133133133133133133133134154",
		"148180180180180180180180180180180180180180150154",
		"135136136136136136136136136136136136137180150154",
		"151152152152152152152152152152152152153180150154",
		"133133133133133133133133133133133133133180150154",
		"180180181180180149180180180149180181180180150154",
		"165165165165165165165180180180165165165165166154",
		"167168168168168168169180180180167168168168168170",
		"255255255255255255255255255255255255255255255255",
		"255255255255255255255255255255255255255255255255",
		"255255255255255255255255255255255255255255255255",
		"00"
	}
	map_house={
		"255255255255255255255255255255255255255255255255",
		"255255255255255255255255255255255255255255255255",
		"255255255255255255255255255255255255255255255255",
		"255255255255255255255255255255255255255255255255",
		"255255255255195196197197197197198199255255255255",
		"255255255255211213214213214213214215255255255255",
		"255255255255211200201201201201202215255255255255",
		"255255255255211216217217217217218215255255255255",
		"255255255255211216217217217217218215255255255255",
		"255255255255211216217217217217218215255255255255",
		"255255255255211216217217217217218215255255255255",
		"255255255255211232233233233233234215255255255255",
		"255255255255247250250250250250250251255255255255",
		"255255255255255255255255255255255255255255255255",
		"255255255255255255255255255255255255255255255255",
		"255255255255255255255255255255255255255255255255",
		"07;229048049;230056049;245048057;246056057;248049096;249057096;099065072"
	}

	map_list[1]=make_map(map_field)
	map_list[2]=make_map(map_house)
	map_list[3]=make_map(map_cliff)

end

function make_map(mapblock)
	local map={
		block=mapblock,
		objects={},
		tiles={}
	}
	local count=1
	for i=1,16,1 do
		for j=1,16,1 do
			map.tiles[count]=make_map_tile(sub(map.block[i],(1+(3*(j-1))),(j*3)),j,i)
			count+=1
		end
	end
	
	local n=tonum(sub(map.block[17],1,2))
	local sprite,x,y
	
	for k=1,n,1 do
		sprite=tonum(sub(map.block[17],(4+(10*(k-1))),(6+(10*(k-1)))))
		x=tonum(sub(map.block[17],(7+(10*(k-1))),(9+(10*(k-1)))))
		y=tonum(sub(map.block[17],(10+(10*(k-1))),(12+(10*(k-1)))))
		map.objects[k]=make_map_object(sprite,x,y)
	end
	return map
end

function make_map_tile(sprite,x,y)
	local map_tile={
		sprite=sprite,
		x=x*8-7,
		y=y*8-7,
		width=8,
		height=8,
		update=function(self)
		end,
		draw=function(self)
			spr(self.sprite,self.x-1,self.y-1)
		end
	}
	return map_tile
end

function make_map_object(sprite,x,y)
	if sprite==50 then
		return make_dandelion(x,y)
	elseif sprite==52 then
		return make_clover(x,y)
	elseif sprite==54 then
		return make_violet(x,y)
	elseif sprite==99 then
		return make_sheep(x,y)
	elseif sprite==203 or sprite==204 or sprite==219 or sprite==220 then
		return make_house(sprite,x,y)
	elseif sprite==181 then
		return make_cliff_entrance(sprite,x,y)
	elseif sprite==227 then
		return make_house_exit(sprite,x,y)
	elseif sprite==248 or sprite==249 then
		return doorway(sprite,x,y)
	elseif sprite==229 or sprite==230 or sprite==245 or sprite==246 then
		return make_pump(sprite,x,y)
	else
		return nil
	end
end

function make_sheep(x,y)
    return make_game_object(115,"Telemea",x,y,8,8,{
		direction="forward",
		portrait_sprites={67,68,83,84},
		quest_complete=true,
		quest_item="flowermilk",
		quest_reward=5,
		dance_counter=0,
		chat_state=1,
		chat_flag=1,
		chat_request={
		"2hello!",
		"1         hello,\n     can I help you?",
		"2yes!",
		"2flower milk,\n please and thank you!",
		"1      that seems\n       simple enough!",
		"3"
		},
		chat_convo={},
		chat_wrong={},
		chat_reward={
		"2oh gosh! that's...",
		"2perfect!!!",
		"2thank you so much, I'm \n going to savour this.",
		"1        you're wel-",
		"2I definitely won't\n just go home...",
		"2...and eat it\n with a spoon.",
		"1        what?",
		"2what?",
		"2anyway...",
		"2I'm going to dance\n in place for awhile.",
		"2thank you again!",
		"1  HAHA, you're welcome.",
		"3"},
		update=function(self)
			--code
		end,
		draw=function(self)
			if self.quest_complete==true and self.dance_counter<40 then
				spr(99,self.x,self.y)
				self.dance_counter+=1
			elseif self.quest_complete==true and self.dance_counter>=40 and self.dance_counter<80 then
				spr(100,self.x,self.y)
				self.dance_counter+=1
			else
				spr(100,self.x,self.y)
				self.dance_counter=0
			end
		end,
		setChatState=function(self,value)
			self.chat_state=value
		end
	})
end

function make_violet(x,y)
    return make_game_object(54,"violet",x,y,8,8,{
		collectible=true
	})
end

function make_clover(x,y)
    return make_game_object(52,"clover",x,y,8,8,{
		collectible=true
	})
end

function make_dandelion(x,y)
    return make_game_object(50,"dandelion",x,y,8,8,{
		collectible=true
	})
end

function make_house(sprite,x,y)
    return make_game_object(sprite,"house",x,y,8,8,{
		update_map=function()
			game_statistics:change_map(2)
			player.x=55
			player.y=87
		end
	})
end

function make_cliff_entrance(sprite,x,y)
    return make_game_object(sprite,"cliffentrance",x,y,8,8,{
		update_map=function()
			game_statistics:change_map(3)
			player.x=1
			player.y=87
		end
	})
end

function make_pump(sprite,x,y)
	if sprite==229 then
		return make_game_object(sprite,"topLpump",x,y,8,8,{
		})
	elseif sprite==230 then
		return make_game_object(sprite,"topRpump",x,y,8,8,{
		})
	elseif sprite==245 then
		return make_game_object(sprite,"bottomLpump",x,y,8,8,{
		})
	else
		return make_game_object(sprite,"bottomRpump",x,y,8,8,{
		})
	end
end

function doorway(sprite,x,y)
    return make_game_object(sprite,"doorway",x,y,8,8,{
		draw=function(self)
			spr(self.sprite,self.x,self.y)
		end,
		update_map=function(self)
			game_statistics:change_map(1)
			player.x=39
			player.y=40
		end
	})
end

function make_exit(sprite,map,newx,newy,x,y)
	return make_game_object(sprite,"exit",x,y,8,8,{
		update_map=function(self)
			game_statistics:change_map(map)
			player.x=newx
			player.y=newy
		end
	})
end

function doorway(sprite,x,y)
    return make_game_object(sprite,"doorway",x,y,8,8,{
		draw=function(self)
			spr(self.sprite,self.x,self.y)
		end,
		update_map=function(self)
			game_statistics:change_map(1)
			player.x=39
			player.y=40
		end
	})
end

function make_milk(recipe,name,sprite,x,y)
	return make_game_object(sprite,name,x,y,8,8,{
		recipe=recipe
	})
end

function make_tomi(x,y)
    return make_game_object(0,"tomi",x,y,8,8,{
		direction="left",
		walk_counter=0,
		x_v=0,
		y_v=0,
		portrait_sprites={11,12,27,28},
		update=function(self)
			if game_statistics.game_state=="pump_menu" then
				if btnp(0) then
					if inventory.inv_cursor<=1 then
						inventory.inv_cursor=5
						pump_menu.menu_cursor=0
					else
						inventory.inv_cursor+=-1
					end
				elseif btnp(1) then
					if inventory.inv_cursor==5 or inventory.inv_cursor==0 then
						inventory.inv_cursor=1
						pump_menu.menu_cursor=0
					else
						inventory.inv_cursor+=1
					end
				end
				if btnp(2) then
					if pump_menu.menu_cursor<=1 then
						pump_menu.menu_cursor=4
						inventory.inv_cursor=0
					else
						pump_menu.menu_cursor+=-1
					end
				elseif btnp(3) then
					if pump_menu.menu_cursor==4 or pump_menu.menu_cursor==0 then
						pump_menu.menu_cursor=1
						inventory.inv_cursor=0
					else
						pump_menu.menu_cursor+=1
					end
				end
				if btnp(4) then
					if pump_menu.menu_cursor>=1 and pump_menu.menu_cursor<4 then
						if pump_menu.slot[pump_menu.menu_cursor] then
							pump_menu.slot[pump_menu.menu_cursor]:add_to_inv(pump_menu.slot[pump_menu.menu_cursor]:remove_from_pump())
						end
					elseif pump_menu.result and pump_menu.menu_cursor==4 then
						for j=pump_menu.filled_spaces,1,-1 do
							for name in all(pump_menu.result.recipe) do
								if name==pump_menu.slot[j].entity then
									--debug_buffer=debug_buffer..name.."\n"
									pump_menu.slot[j]:remove_from_pump()
									break
								end
							end
						end
						pump_menu.result:add_to_inv()
						pump_menu.result=false
						
					else
						if pump_menu.filled_spaces < 3 then
							if inventory.slot[inventory.inv_cursor] then
								inventory.slot[inventory.inv_cursor]:add_to_pump(inventory.slot[inventory.inv_cursor]:remove_from_inv())
								
							end
						end
					end
				end
				if btnp(5) then
					game_statistics.game_state="explore"
					inventory.inv_cursor=1
					pump_menu.menu_cursor=0
				end
				
			elseif game_statistics.game_state=="explore" then
				if btn(0) then
					self.x_v=-1
					self.direction="left"
					self.walk_counter+=1
				elseif btn(1) then
					self.x_v=1
					self.direction="right"
					self.walk_counter+=1
				else
					self.x_v=0
				end
				if btn(2) then
					self.y_v=-1
					self.direction="up"
					self.walk_counter+=1
				elseif btn(3) then
					self.y_v=1
					self.direction="down"
					self.walk_counter+=1
				else
					self.y_v=0
				end
				if btnp(4) then
					--debug_buffer=self.direction
					for obj in all(map_list[game_statistics.current_map].objects) do
						local adjacency=self:check_for_adjacency(obj,self.direction)
						if adjacency==true and fget(obj.sprite,2) then
							--debug_buffer="Hit!"
							game_statistics.game_state="pump_menu"
						end
						if adjacency==true and fget(obj.sprite,3) then
							--debug_buffer="Hit!"
							game_statistics.game_state="chat"
						end
					end
				end
				if btnp(5) then
					inventory.inv_cursor+=1
					if inventory.inv_cursor==6 then
						inventory.inv_cursor=1
					end
				end
				local obj
				local count=1
				for obj in all(map_list[game_statistics.current_map].objects) do
					if self:check_for_hit(obj) and obj.collectible==true then
						if inventory.filled_spaces<5 then
							obj:add_to_inv()
							del(map_list[game_statistics.current_map].objects,map_list[game_statistics.current_map].objects[count])
						end
					end
					if self:check_for_hit(obj) and fget(obj.sprite,1) then
						obj.update_map()
					end
					count+=1
				end

				self.x=mid(0,(self.x+self.x_v),120)
				self.y=mid(0,(self.y+self.y_v),96)
				
				for obj in all(map_list[game_statistics.current_map].objects) do
					local hit_dir=self:check_for_collision(obj)
					if hit_dir=="top" and fget(obj.sprite,0) then
						self.y=obj.y+obj.height
					elseif hit_dir=="bottom" and fget(obj.sprite,0) then	
						self.y=obj.y-self.height
					elseif hit_dir=="left" and fget(obj.sprite,0) then	
						self.x=obj.x+obj.width
					elseif hit_dir=="right" and fget(obj.sprite,0) then	
						self.x=obj.x-self.width
					end
				end
				--Okay I legit hate that I have this code here, I'll think up a better solution later
				for map_tile in all(map_list[game_statistics.current_map].tiles) do
					local hit_dir=self:check_for_collision(map_tile)
					if hit_dir=="top" and fget(map_tile.sprite,0) then
						self.y=map_tile.y+map_tile.height
					end
					if hit_dir=="bottom" and fget(map_tile.sprite,0) then	
						self.y=map_tile.y-self.height
					end
					if hit_dir=="left" and fget(map_tile.sprite,0) then	
						self.x=map_tile.x+map_tile.width
					end
					if hit_dir=="right" and fget(map_tile.sprite,0) then	
						self.x=map_tile.x-self.width
					end
				end
			end
		end,
		
		draw=function(self)
		    if self.direction=="left" then
				spr(mid(1,(1+(self.walk_counter/3)),6),self.x,self.y)
			end
		    if self.direction=="right" then
				spr(mid(1,(1+(self.walk_counter/3)),6),self.x,self.y,1,1,true)
			end
		    if self.direction=="up" then
				spr(mid(33,(33+(self.walk_counter/3)),38),self.x,self.y)
			end
		    if self.direction=="down" then
				spr(mid(17,(17+(self.walk_counter/3)),22),self.x,self.y)
			end
			if self.walk_counter>=17 then
				self.walk_counter=1
			end
			if game_statistics.game_state!="chat" then
				spr(11,106,108)
				spr(12,114,108)
				spr(27,106,116)
				spr(28,114,116)
			end
		end
	})
end

function make_game_object(sprite,name,x,y,width,height,props)
    local obj={
		sprite=sprite,
		entity=name,
	    x=x,
		y=y,
		width=width,
		height=height,
		collectible=false,
		setx=function(self,x)
			self.x=x
		end,
		sety=function(self,y)
			self.y=y
		end,
		add_to_pump=function(self)
			self:setx(9)
			self:sety(20+(pump_menu.filled_spaces*18))
			add(pump_menu.slot,self)
			pump_menu.filled_spaces+=1
			--debug_buffer = debug_buffer..pump_menu.filled_spaces.."\n"
		end,
		remove_from_pump=function(self)
			local obj=del(pump_menu.slot,self)
			pump_menu.filled_spaces+=-1
			for i=1,pump_menu.filled_spaces,1 do
				pump_menu.slot[i]:setx(9)
				pump_menu.slot[i]:sety(20+((i-1)*18))
			end
			--debug_buffer = debug_buffer..pump_menu.filled_spaces.."\n"
			return obj
		end,
		add_to_inv=function(self)
			self:setx(24+(inventory.filled_spaces*11))
			self:sety(112)
			add(inventory.slot,self)
			inventory.filled_spaces+=1
		end,
		remove_from_inv=function(self)
			local obj=del(inventory.slot,self)
			inventory.filled_spaces+=-1
			for i=1,inventory.filled_spaces,1 do
				inventory.slot[i]:setx(24+((i-1)*11))
				inventory.slot[i]:sety(112)
			end
			return 
		end,
		update=function(self)
		end,
		draw=function(self)
			spr(self.sprite,self.x,self.y)
		end,
		check_for_hit=function(self,obj)
			return obj_overlap(self,obj) 
		end,
		check_for_collision=function(self,obj)
			local top_hitbox={
			    x=self.x+2,
				y=self.y,
				width=self.width-4,
				height=self.height/2
			}
			local bottom_hitbox={
			    x=self.x+2,
				y=self.y+self.height/2,
				width=self.width-4,
				height=self.height/2
			}
			local left_hitbox={
			    x=self.x,
				y=self.y+2,
				width=self.width/2,
				height=self.height-4
			}
			local right_hitbox={
			    x=self.x+self.width/2,
				y=self.y+2,
				width=self.width/2,
				height=self.height-4
			}
			if obj_overlap(top_hitbox, obj) then
				return "top"
			end
			if obj_overlap(bottom_hitbox, obj) then
				return "bottom"
			end
			if obj_overlap(left_hitbox, obj) then
				return "left"
			end
			if obj_overlap(right_hitbox, obj) then
				return "right"
			end
		end,
		check_for_adjacency=function(self,obj,direction)
			local top_hitbox={
			    x=self.x+2,
				y=self.y-2,
				width=self.width-4,
				height=self.height/2
			}
			local bottom_hitbox={
			    x=self.x+2,
				y=self.y+self.height/2,
				width=self.width-4,
				height=(self.height/2)+2
			}
			local left_hitbox={
			    x=(player.x-2),
				y=(player.y+2),
				width=6,
				height=4
			}
			local right_hitbox={
			    x=(player.x+4),
				y=(player.y+2),
				width=6,
				height=4
			}
			
			if direction=="up" and obj_overlap(top_hitbox, obj) then
				return true
			end
			if direction=="down" and obj_overlap(bottom_hitbox, obj) then
				return true
			end
			if direction=="left" and obj_overlap(left_hitbox, obj) then
				return true
			end
			if direction=="right" and obj_overlap(right_hitbox, obj) then
				return true
			end
		end
	}
	local key,value
	for key,value in pairs(props) do
		obj[key]=value
	end
	return obj
end

function line_overlap(min1,max1,min2,max2)
    return max1>min2 and max2>min1
end

function obj_overlap(obj1, obj2)
    return line_overlap(obj1.x,(obj1.x+obj1.width),obj2.x,(obj2.x+obj2.width)) and line_overlap(obj1.y,(obj1.y+obj1.height),obj2.y,(obj2.y+obj2.height))
end
__gfx__
0000000000fff50000fff50000fff50000fff50000fff50000fff500000000000000000000000000000000000f00065000650000000000000000000000000000
0000000005cf4f5005cf4f5005cf4f5005cf4f5005cf4f5005cf4f5000000000000000000000000000000000f4f465777655fff0000000000000000000000000
007007000ffff40f0ffff40f0ffff40f0ffff40f0ffff40f0ffff40f00000000000000000000000000000000f44f4777775ff44f000000000000000000000000
0007700000fff00f00fff00f00fff00f00fff00f00fff00f00fff00f00000000000000000000000000000000f444f7777f7f444f000000000000000000000000
0007700000ffff0f00ffff0f00ffff0f00ffff0f00ffff0f00ffff0f000000000000000000000000000000000f447777f7f4444f000000000000000000000000
0070070000ef4ff000e4fff000e4fff000ef4ff000ef4ff000ef4ff00000000000000000000000000000000000f4777f7f7f44f0000000000000000000000000
0000000000eeff00005fff0000eefff000eeff0005eefff000eefff000000000000000000000000000000000000df7ffddfdf400000000000000000000000000
000000000005f00000005f0005f005000005f00000f0050005f0050000000000000000000000000000000000000ceeefc7df4f00000000000000000000000000
0000000005ffff5005ffff5005ffff5005ffff5005ffff5005ffff5000000000000000000000000000000000000eeeffcc6ff400000000000000000000000000
00000000ffcffcffffcffcffffcffcffffcffcffffcffcffffcffcff0000000000000000000000000000000000eeefffffff4f67062221500f77aa400d222e10
0000000004f55f4004f55f4004f55f4004f55f4004f55f4004f55f400000000000000000000000000000000007665ffffff4f4760062150000faa40000d2e100
0000000000f44f0000f44f0000f44f0000f44f0000f44f0000f44f000000000000000000000000000000000005655fffffff4667062121500fa9a9400d2ee710
000000000ffffff00ffffff00ffffff00ffffff00ffffff00ffffff0000000000000000000000000000000000f55fffffff46676061211500f979a400dee7c10
0000000004feef4005feef4004feef4004feef4004feef5004feef40000000000000000000000000000000000044444fff466767061111500fa9a9400de7cc10
000000000ffeeff0004eeff00ffeeff00ffeeff00ffee4000ffeeff0000000000000000000000000000000000000067666667677061111500f9a99400d7ccc10
000000000050050000000500054005000050050000500000005004500000000000000000000000000000000000000767676777770066650000fff40000ddd100
00000000055ff550055ff550055ff550055ff550055ff550055ff550000000000000000000000000000000000000000000000000000000000000000000000000
00000000ff4554ffff4554ffff4554ffff4554ffff4554ffff4554ff00000000067ff45005b3b31006b7b35006777e8006777c100b7aa9300f7aa94006777a50
0000000004ffff4004ffff4004ffff4004ffff4004ffff4004ffff4000000000006f4500005b3100006b35000067e8000067c10000b7a30000bae3000067a900
0000000000ff4f0000ff4f0000f4ff0000ff4f0000f4ff0000ff4f000000000006f4f45005bbb31006b3b3500677ee800677cc100b7a99300feb374006b7fa30
000000000fff4ff00ff4fff00ff4fff00fff4ff00fff4ff00fff4ff000000000064f445005787310063b3350067eee80067ccc100ba999300fa97870067a3f50
000000000fff4ff00ff4fff00ff4fff00fff4ff00fff4ff00fff4ff00000000006f444500578731006b33350067eee80067ccc100ba999300fa9974006a9af50
000000000ff4fff00fff45000f4f4ff00ff4fff00054fff00ff4f4f000000000064f445005333310063b33500677ee800677cc100baa99300faa994006ba3f50
0000000000500500005000000050050000500500000005000050050000000000006665000055510000666500006668000066610000bbb30000fff40000666300
0000000077777775000000000000000000bd0d000000c000000000000bbb00000000bb00000000000000000000000000000000000ff0000000000b0b00003000
057777507666666500a0000006777f5000d7d00000c010c0000000003000300000ee3b0000a33a0000e8e8000004440000566700fff40000000000b000b33b00
0075570076777765079700000067f5000d0d0bd000000c1100000000b0077600bbe8eee00a4004000e8e88200045454005667770ff450ff00b0b0a390b8bb2b0
0555575076766565a979a0000677ff50d7d00d0d0010001000e0e020b0777660b3e768e003003a00e8e88282000bbb0056666767f445fff400b00aa908888820
0557775076766565079730a0067fff50bd0bd7db000c0000e00e7202b07767600e867e3b0a400000ee8e882800b7b330056676700450ff450a390a9908288820
055755507675556500a3ba7a067fff50000d0d7d00c110000e0320e0370707060eee8ebb00a34000007766000b7b3b33005667000ff0ff450aa90a9900828200
05555550766666650b0b03a00677ff50d0d7d0d000010010e72b03723000000000b3ee000a00a30a077777600b7b3b3300057000ff450ff00a9900a000082000
005755005555555500b000000066650000bd0d00c0000000023bb0200300000000bb0000004004040077760000bbb3b0000000000450000000a0000000000000
aaa95555555555555555aaa900000055555000000000000000000000000000500000050000000000000000000000000000000000000555000055550000000000
ae895555555555555555ae8900055577767650000000000000000000000005550000555000005000000055000000000000000000005555500555555500000000
a8899999999999999999a88905577767776765000000033333330000000005555000555500055500000055000000000000000000055555550555555500000000
99990000000000000000999956577777777655500000333333333300000055999999555500055500000555500000000000000000055554444555055500000000
55900000000000000000095555777777777566650003333333333300000059999999555500555550005555500000555500005555055544444444455500000000
55900000000000000000095505775577777566d50033333a33333300000099999999555500555550055555500000555506655555005544444444555500000000
5590000000000000000009550577775777775d500333333a33333300000099999999995005555555555555500000556666655555000044444445555500000000
55900000000000000000095500577657dd7765000333333333333300000099999999999005555555555555500000566666655555000044444c44555000000000
55900000000000000000095505755566c75576500333333333333300000099999999997005555555555555500000066666665555000044444c44440000000000
55900000000000000000095557766666cc5777650033333333333000000999999999997705555555555555500000666666666555000044444444440000000000
55900000000000000000095557666666657776750000333333333000055599999999997700555555555555500000666666666660000044444444400000000000
55900000000000000000095557666666657777650033333333333300095999999977797700555511155555000006666666666660000044444444000000000000
559000000000000000000955057ee6666d5776570333333333333330009999997777777000055511155550000006666666666660000044444440000000000000
559000000000000000000955006e666666d555763333333333333333000999997777777000055555555500000006e66666666660000044444000000000000000
55900000000000000000095500055556665667673333333333333333000000000077777000005555555000000006666666666600000044444000000000000000
55900000000000000000095500005767676777773333333333333333000000000077700000000055500000000000666666660000000004440000000000000000
55900000000000000000095500777700007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55900000000000000000095507677670076776700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55900000000000000000095555c66c5555c66c550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
559000000000000000000955076ee670076ee6700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa990000000000000000aaa900766700507667050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ae899999999999999999ae8905777750077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a8895555555555555555a88907777770077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99995555555555555555999900500500005005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccc7c7aa7c7
000a900000000000000000000067770000000000000000000000000000000000000000000000000000000000000000000000000000000000c7c77c7cc7c77c7c
000a9000aaaaaa99000000000ec67500000000000000000000000000000000000000000000000000000000000000000000000000000000007c7aa7c7cc7cc7c6
0aae8aa00aae8990000808000667775000000000000000000000000000000000000000000000000000000000000000000000000000000000c7a99a7cccc77cc6
0998899000a88900000888000066770000000000000000000000000000000000000000000000000000000000000000000000000000000000c6eee51110100077
000a9000000a90000000800000775770000000000000000000000000000000000000000000000000000000000000000000000000000000006ee88e5111010000
000a900000000000000000000077770000000000000000000000000000000000000000000000000000000000000000000000000000000000ee8998e511101000
0000000000000000000000000005600000000000000000000000000000000000000000000000000000000000000000000000000000000000e89aa98e51110100
003333000033330330330330003333003533b3333b3b34b333b533533bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000000000000000000000000000
03b3bb3003bbb33b33bb333303bbb33053b5bb66b6b6b66b6b6b5b353bbbbbbbbbbbbbbbbbbbbbb3bbbbbbbb0000000000000000000000000000000000000000
3b3bb3b33bbb3b333bb3b3333bbb3b33345666b66b666bb6bb6b654353bbbbbbbbbbbbbbbbbbbb35bb6bbbbb0000000000000000000000000000000000000000
3bbb3b333bb3b33b3bbb33b33bb3b3b3b566664666b6666b66b65b6353bbbbbbbbbbbbbbbbbbbb35bbbb6b350000000000000000000000000000000000000000
3bbbb3b33bbb3b333bb3b3333bbb3b33366666b6666b666b6b66b6635b3b3b33333b3b3333333b553bbb6b350000000000000000000000000000000000000000
3bbb3b333bb3b33b3bbb33b33b3333b33b666b6bb6b66666b6bbb66b55b555555555b55555555b555bb66b350000000000000000000000000000000000000000
03bbb33003bb33b3b3b33b3303b3b330b4b6b66bbb6bb66b6b666bb4555b744444444b444444b55553b66b350000000000000000000000000000000000000000
0033330000333033303303303b3bbb333b666bb6bbbbbbbbbbbbb66355b7a7ffffffbfffffff445553b6bb350000000000000000000000000000000000000000
0005500000055004504504503bbbb3b33b66666bbbbbbbbbbb66366354bf76fff6fff6f6666ffff553b6bb350000000000000000000000000000000000000000
000450000004500440f404403bbbbb333bb666b6b7bbbbbbb66b66b35fb666ff666f66f66666bf7553bb6b350000000000000000000000000000000000000000
0045500000455044004504503b3333b3b46bbb6bbbbb76bbb663664b5ffb66f6666f66666666f7a753b6bb350000000000000000000000000000000000000000
03f4303003f4334533f4345303bb3b303bb6666bbbb7655bbb66bb635bf666f6666f66666666bb7553b66b350000000000000000000000000000000000000000
3445430334454333344543333b3bb3b33b6b66b6bbbbbbbbbbbb66b3bfbf666666b666f66666fb4553bb6b350000000000000000000000000000000000000000
03443030034430333344333033bb3b33b4b6b66bb76b7bbbbb6b6b4bb4ff66666b6f6ff6666fffb553b66b350000000000000000000000000000000000000000
0033030000330000033330003bbbb3b33b6b66bbb665bb7bbbbbb6633bfff6ff6fbfffff6ffff45353b6bb350000000000000000000000000000000000000000
0000000000000000000000003bbbbbb334bbbbbbbbbbbbbbb6b66bb4b3555555553555555555553b53b66b350000000000000000000000000000000000000000
00333300000000000f4444403bbbbbb33b6666b6bbbbbbbbbbbbbb63bb55555555555555555555bb53b66b350000000000000000000000000000000000000000
03ebbb3000065500f4fffff403bbbb30366bbb6bb6bbb6bbbb6666b4b5333333333333333333335b3bbb6b350000000000000000000000000000000000000000
3bb3b3b300666550ff4444f4003333003bb666666b6b6b6666b6b3b3533bbbbbbbbbbbbbbbbbb335bb66bb350000000000000000000000000000000000000000
33bb3be3076656554fffffeb00045000b66b6b66b666b666666b666b53b66bbbbbb66b6666bb6b35b66b6b350000000000000000000000000000000000000000
3bbebb3376766565f444b435000450003bb636b666666b666636666353b66b6bb6bbbb66bbb66b3566b66b350000000000000000000000000000000000000000
3b3bb3b3676656554f55e355003443003456b66666b66b6b6b666663533bbbbbbbbbbbbbbbbbb335bbbbb3350000000000000000000000000000000000000000
43bbbb3466656550f4f454350344543053b56b666b6b66b6b4b66635453333333333333333333354333333540000000000000000000000000000000000000000
04333340065555000f45535000344300353b33b3b4344b3b3b33b353445555555555555555555544555555440000000000000000000000000000000000000000
00003300000000a000000000333b33bbbbbbbbbb6bbbbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000
00003b3000000a9a00000d003b33333bbbbbbbbbbb66b6bb00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000030000a000a00dd007003bb33b3bbbbbbbbbbb66766b00000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000a9a03b30700000033b333bbbbbbbbbbb6b7a76b00000000000000000000000000000000000000000000000000000000000000000000000000000000
0330000000a000300000ddd03333333bbbbbbbbbb66b766b00000000000000000000000000000000000000000000000000000000000000000000000000000000
3b30033003b30a00000007003b33b33bbbbbbbbbb676b66b00000000000000000000000000000000000000000000000000000000000000000000000000000000
03003b300030a9a00dd0000033b33b3bbbbbbbbbb7a7bbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000030000000a0000700000333b33bbbbbbbbbbbb7b6bb600000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444400055555555555555555555555555555555550005555554545455454545554550000000000000000000000000000000000000000
444444b4b4b4b444b444b444000554444444444444444444444444444445500044444444aaaaaaaa444444440000222222210000000000000000000000000000
4444444bbbbbbbbb3bbb444400054445555555555555555555555555544450004444444a22a22a22a444444400227ee8e8821100000000000000000000000000
444444bb3b3bbbbbbbb3b44b0005444595959959599559959599595954445000545455a2aa2aa2aa2a545545027e7e8e88822210000000000000000000000000
444b4b3bb3bbb3b3bbbb3bb4000544455959559595599559595595955444500044444a2a22222222a2a444447e7e722222228221000000000000000000000000
4444b3bbbbbbbb3bbbbbb3b400054445959999999999999999999a59544450005545a2a2222222222a2a54557e77ee8e88882281000000000000000000000000
444b3bbbbb3b3bbbb3b3bb34000544455999a9999a9999999a99999554445000444a2a222222222222a2a4447e72222222222821000000000000000000000000
44bbbbbbbbb3bbbbbb3bbbb4000544459a99a99a999a9a999a999a995444500044a2a22222222222222a2a447e7e878888888221000000000000000000000000
44b3b3bbbbbbbbbbbbb3b3b40005444500000000999999999a999999544450004a2a2222222222222222a2a477e8e78222222211000000000000000000000000
44bb3bbbbbbbbbbbbbbb3bb400054445000000009a999a999a999a99544450004a2a2222222222222222a2a47222e7824ffff421000000000000000000000000
4bbbbbbb3b3bbbbb3b3bbb34000544450000000099999a999a9a9a99544450005aa222222222222222222aa507f427827f777f40000000000000000000000000
4bbbbbbbb3bb3b3bb3bbbbb400054445000000009a999a9999999a99544450004a2a2222222222222222a2a40f747224f7f42740000000000000000000000000
43b3bbbbbbbbb3bbbbbb3b3400054445000000009a999a9999999999544450004a2a2222222222222222a2a407f4fdd47f7ddf40000000000000000000000000
4b3bb3b3bbbbbbbbbbbbb3b400054445000000009a999a999a999a99544450004aa222222222222222222aa50f74fd54f7f7f740000000000000000000000000
4bbbbb3b3b3bbbbbbbbbbbb400054445000000009a999a99aa999a99544450005a2a2222222222222222a2a40555fdd455555550000000000000000000000000
43bbbbbbb3bbbbbbbbbbbb340005444500000000999999999a999999544450004a2a2222222222222222a2a40000555500000000000000000000000000000000
43b3b3bbbbbbbbbbbbb3b3b4088880000000000000000000000000000000000044a2a22222222222222a2a440000000000000000000000000000000000000000
443b3bbbbbbbb3b3bbbb3b342888888000000000000000000000000000000000444a2a222222222222a2a4440000000000000000000000000000000000000000
444bb3b3b3b3bb3bbbbbb3442deee888800888000000000000000000000000005455a2a2222222222a2a44440000000000000000000000000000000000000000
4443bb3bbb3bbbbb3b3b3444222eeeeeeeeee88200000000000060000000000044444a2a22222222a2a554540000000000000000000000000000000000000000
4444b3bbbbbb3b3bb3b34444222222eeeeeeee22000f44400005060000000000444444a2aa2aa2aa2a4444440000000000000000000000000000000000000000
44443433b3b3bbb33b34444402222222222222200054444665500600000000005454554a22a22a22a55454550000000000000000000000000000000000000000
44444444343b334443444444004004000040040000f55567666506000000000044444444aaaaaaaa444444440000000000000000000000000000000000000000
444444444443444444444444040000000000004000f4f44555500600000000005555544445455454545545550000000000000000000000000000000000000000
00000000bbbbbbbb0550005000000000006655000054f46666650600000544455544444444444455555555555444500000000000000000000000000000000000
000fff00bbbbbbbb5665056500f44400067666500045556766650500000544444555555555555554444444444444500000000000000000000000000000000000
00f9f440bbbbbbbb0550005005444450005555000004f466666506000005444445dddddddddddd54444444444444500000000000000000000000000000000000
0f4f4944bbbbbbbb576505650f5555400666665000000056565505000005544445dddddddddddd54444444444445500000000000000000000000000000000000
0ff44445bbbbbbbb566505750f4f4440067666500006600565500500000555555555555555555555555555555555500000000000000000000000000000000000
0f944454bbbbbbbb57650565054f4450066666500060050000055000000000000000000000000000000000000000000000000000000000000000000000000000
05454545bbbbbbbb5765056504555540056565500006005655500000000000000000000000000000000000000000000000000000000000000000000000000000
00555550bbbbbbbb05500050004f4f00005655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000909000000000000000000000000000009000000000000000000000000
0101010100000001010101000000000001010101000000010101010000000000010101010000000101010100000000000000000000020000000000000000000000000001010101010000000101000000000000010001010100000002020000000000000101050500000000000101000000000000000505010202010101010000
__map__
c0c1c1c1c1c1c1c1c1c1c1c1c1c1c1c2ff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d1f1f1d1f1f1f1f1f1f1d1d1f1d1d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0f1d1f1f1f1f1d1d1f1f1f1f1d1f1d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0f1f1f1f1f1d1f1f1f1f1f1f1f1f1d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0f1f1d1f1f1f1f1f1f1f1d1f1f1d1d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0f1f1f1d1d1f1f1f1d1f1f1f1f1f1d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d1f1f1f1f1f1f1f1f1f1f1d1f1d1d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d1f1f1f1f1f1f1f1f1d1f1f1f1f1d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0f1f1f1f1d1f1f1f1f1d1f1f1f1f1d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0f1f1d1f1f1f1d1f1f1f1f1f1f1d1d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d1f1f1f1f1f1f1f1f1f1f1d1f1f1d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0f1f1f1f1f1d1d1f1f1d1f1f1f1f1d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0f1d1f1d1f1f1f1d1f1f1f1f1f1d1d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d1f1f1f1f1f1f1f1f1f1f1f1d1d1d200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e1e1e1e1e1e1e1e1e1e1e1e1e1e1e200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
