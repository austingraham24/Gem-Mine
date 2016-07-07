--
-- Project: Jewel Mine
-- Description: 
--
-- Version: 1.0
-- Managed with http://CoronaProjectManager.com
--
-- Copyright 2014 Paul Graham. All Rights Reserved.
-- 
local composer = require "composer" 
local scene = composer.newScene()
function scene:create ( event )
	local physics = require("physics")
	--physics.setDrawMode( "hybrid" )
	physics.start()
	physics.setGravity(0,0)
	w = display.contentWidth
	h = display.contentHeight
	local physicsData = (require "field").physicsData(scaleFactor)
	local gameGroup = self.view
	local lives = 3
	local score = 0
	local spin = 360
	local numShot = 0
	local shotTable ={}
	local rockTable = {}
	local numRocks = 0
	local gemTable = {}
	local numGems = 0
	local heartTable={}
	local numHearts = 0
	local maxShotAge = 1000
	local tick = 400  -- time between game loops in milliseconds
	local died=false
	local bg = display.newImage(gameGroup,"rockwall2.jpg")
	bg.x = w/2
	bg.y = h-bg.height/2
	--axe= display.newImage(gameGroup,"pick-axe2.png")
	--axe.x = w/2 
	--axe.y = h/2
	local rail = display.newImage(gameGroup,"rail2.jpg")
	rail.x = w/2
	rail.y = h-rail.height/2
	local swoosh = audio.loadSound("sounds/swoosh.mp3")
	local ding = audio.loadSound("sounds/ding.mp3")
	local clang = audio.loadSound("sounds/axe.mp3")
	local life = audio.loadSound("sounds/life.mp3")
	local explosion = audio.loadSound("sounds/explosion.wav")
	audio.setVolume( 1)
	audio.setVolume( 1,{channel=1})
	audio.setVolume( 1,{channel=2})
	audio.setVolume( .08,{channel=4})
	audio.fade( { channel=3, time=3000, volume=0.3 } )

	local cart = display.newImage(gameGroup,"Cart.png")
	--cart.x = w/2
	cart.x = -200
	cart.y = h-108
	physics.addBody (cart, physicsData:get("Cart"))
	cart.isFixedRotation = true
	cart.myName = "mine_cart"
	
	local shield = display.newImage(gameGroup,"shield.png")
	shield.x = w/2--+200
	shield.y = cart.y - 50
	--shield:scale(.8,.8)
	shield.alpha = .6	physics.addBody (shield, physicsData:get("shield"))	shield.myName = "shield"
--	
	local shield_icon = display.newImage(gameGroup,"shield_apple.png")
	shield_icon.x = w/2
	shield_icon.y = 100
	shield_icon:scale(.45,.45)
	
	local better = display.newImage(gameGroup,"better.png")
	better.x = w/2
	better.y = 150
	better:scale(.6,.6)
	better.alpha = 0
	local broken = display.newImage(gameGroup,"broken.png")
	broken.x = w/2
	broken.y = h/2-130
	broken.alpha = 0
	local menu = display.newImage(gameGroup,"menu.png")
	menu.y = -200
	menu.x =-200
	menu.alpha = 0
	menu:scale(.8,.8)

	
	local function newText()
 	  textLives = display.newText("Lives: "..lives, 0, 0, nil, 36)
	   textScore = display.newText("Score: "..score, 0, 0, nil, 36)
	   textLives:setTextColor(1,1,1)
	   textScore:setTextColor(1,1,1)
   	textLives.x = w-w/15--15
   	textScore.x = w/15--15
  	 textLives.y = 10
   	textScore.y =10
   	textLives.alpha = 0
   	textScore.alpha = 0
  	 textScore.anchorX = 0
   	textScore.anchorY = 0
    	textLives.anchorX = 1
  	 textLives.anchorY = 0
  	 transition.to(textLives,{time=500, alpha =1})
  	 transition.to(textScore,{time=500, alpha =1})
	end          
	
	local function mainMenu()
		menu:removeEventListener("tap",mainMenu)
		textLives:removeSelf()
   	 textScore:removeSelf()
		composer.gotoScene("menu","fade",500)
	end

	local function updateText()
	    textLives.text = "Lives: "..lives
	    textScore.text = "Score: "..score
	    textLives:toFront()
	    textScore:toFront()
	end
	

	
	local function cleanup(action)
		if (action == "destroy") then
			for i=1,table.getn(rockTable) do
				if(rockTable[i].myName~= nil) then
					rockTable[i]:removeSelf()
					rockTable[i].myName=nil
				end
			end
			for i=1,table.getn(gemTable) do
				if(gemTable[i].myName~= nil) then
					gemTable[i]:removeSelf()
					gemTable[i].myName=nil
				end
			end
			for i=1,table.getn(heartTable) do
				if(heartTable[i].myName~= nil) then
					heartTable[i]:removeSelf()
					heartTable[i].myName=nil
				end
			end
			for i=1,table.getn(shotTable) do
				if(shotTable[i].myName~= nil) then
					shotTable[i]:removeSelf()
					shotTable[i].myName=nil
				end
			end
		elseif (action == "upkeep")then
			for i=1,table.getn(rockTable) do
				if(rockTable[i].myName~= nil and rockTable[i].y > h+100) then
					rockTable[i]:removeSelf()
					rockTable[i].myName=nil

				end
			end
			for i=1,table.getn(gemTable) do
				if(gemTable[i].myName~= nil and gemTable[i].y > h+100) then
					gemTable[i]:removeSelf()
					gemTable[i].myName=nil
				end
			end
			for i=1,table.getn(shotTable) do
				if(shotTable[i].myName~= nil and shotTable[i].y <-50) then
					shotTable[i]:removeSelf()
					shotTable[i].myName=nil
				end
			end
			for i=1,table.getn(heartTable) do
				if(heartTable[i].myName~= nil and heartTable[i].y > h+100) then
					heartTable[i]:removeSelf()
					heartTable[i].myName=nil
				end
			end
		end
	end	
	
	local function fireshot(event)
		audio.play(swoosh)
		numShot = numShot+1
		shotTable[numShot] = display.newImage(gameGroup,"pick-axe2.png")
		physics.addBody(shotTable[numShot], physicsData:get("pick-axe2"))
		shotTable[numShot].isbullet = true
		shotTable[numShot].x=cart.x
		shotTable[numShot].y=cart.y
		cart:toFront()
		transition.to(shotTable[numShot], {y=-200, time=700, rotation = spin})
		--audio.play(fireSound)
		shotTable[numShot].myName="axe"
		shotTable[numShot].age=0
		if (spin== -360) then
			spin = 360
		else
			spin = -360
		end
		shield:toFront()
	end
	
		local function loadRocks()
		numRocks= numRocks +1
		rockTable[numRocks] = display.newImage("rock.png")
		--rockTable[numRocks]:scale(.7,.7)
		physics.addBody(rockTable[numRocks], physicsData:get("rock"))
		rockTable[numRocks].myName="rock"
		rockTable[numRocks].x = math.random(50,(w-50))
		rockTable[numRocks].y = math.random(100,(h/2))*-1
		transition.to(rockTable[numRocks],{time = math.random(5000,10000), y = math.random(h+100,h*1.25)})

	end
	
	local function loadGem()
	numGems= numGems +1
	if score <= 500 then
		num=1
	elseif score<=2000 then--5000 then
		num = math.random(1,75)
	elseif score<= 5000 then--20000 then
		num = math.random(1,90)
	else
		num = math.random(0,100)
	end
	--print(num)
	if num<=50 then
		gemTable[numGems] = display.newImage("blue.png")
		physics.addBody(gemTable[numGems], physicsData:get("blue_gem"))
		gemTable[numGems].myName="blue_gem"
	elseif num<=75 then
		gemTable[numGems] = display.newImage("red.png")
		physics.addBody(gemTable[numGems], physicsData:get("red_gem"))
		gemTable[numGems].myName="red_gem"
	elseif num<=90 then
		gemTable[numGems] = display.newImage("purple.png")
		physics.addBody(gemTable[numGems], physicsData:get("purple_gem"))
		gemTable[numGems].myName="purple_gem"
	else
		gemTable[numGems] = display.newImage("tri.png")
		physics.addBody(gemTable[numGems], physicsData:get("tri_gem"))
		gemTable[numGems].myName="tri_gem"
	end
	gemTable[numGems].x = math.random(5,(w-50))
	gemTable[numGems].y = h/math.random(1,3)*-1
	transition.to(gemTable[numGems],{time = math.random(6000,10000), y = math.random(h+100,h*1.25)})
	end
	
	local function loadHeart()
		if(lives<5)then
			num = math.random(1,100)
			--print(num)
			if (num>=85)then
				numHearts = numHearts+1
			heartTable[numHearts] =  display.newImage(gameGroup,"heart2.png")
				heartTable[numHearts].x = w/2
				heartTable[numHearts].y = h/2
				--heart:scale(.3,.3)
				physics.addBody(heartTable[numHearts],{density=1,friction=0.3,bounce=1,isSensor=true})
				heartTable[numHearts].myName = "heart"
				heartTable[numHearts].x = math.random(50,(w-50))
				heartTable[numHearts].y = math.random(100,(h/2))*-1
				transition.to(heartTable[numHearts],{time = 6000, y = math.random(h+100,h*1.25)})
			end
		end
	end

	
	local function startDrag( event )
		local t = event.target
		local phase = event.phase
		if "began" == phase then
			display.getCurrentStage():setFocus(t)
			t.isFocus = true
			--Store inital position
			t.x0 = event.x - t.x
			--shield.x = t.x0
			-- make the body type 'kinematic' to avoid gravity problems
			event.target.bodyType = "kinematic"
			-- stop current motion
			event.target:setLinearVelocity( 0,0)
			event.target.angularVelocity = 0
		elseif t.isFocus then
			if "moved" == phase then
				t.x = event.x - t.x0
				--shield.x = t.x
				if t.x < t.width/2 - 60 then
					t.x = t.width/2 - 60
				elseif t.x > w-(t.width/2)+60 then
					t.x = w-(t.width/2)+60 
				end
				shield.x = t.x
			elseif "ended" == phase or "cancelled" == phase then
				display.getCurrentStage():setFocus(nil)
				t.isFocus = false

				-- switch body type back to "dynamic"
				if (not event.target.isPlatform) then
					event.target.bodyType = "dynamic"
				end
			end
		end
		return true
	end
	
	local function gameLoop()
		updateText()
		cleanup("upkeep")
		--loadRocks()
		cart.y = h-108
		--remove old shots fired so they don't stack
		for i = 1, table.getn(shotTable) do
			if (shotTable[i].myName ~= nil and shotTable[i].age < maxShotAge) then
				shotTable[i].age = shotTable[i].age + tick
			elseif (shotTable[i].myName ~= nil) then
				shotTable[i]:removeSelf()
				shotTable[i].myName=nil
			end	
		end
		--timer.performWithDelay(1500, loadGem)
	end
	
	local function startGame()
		transition.to(heart,{time = 1000, y = h+60})
	    --spawnShip()
	    --newText()
	    
	    cart:addEventListener("touch", startDrag)
	    cart:addEventListener("tap", fireshot)

	    --timer.performWithDelay(350, addScore,30)
	    game_Loop = timer.performWithDelay(tick, gameLoop,0)
	    --gemLoop = timer.performWithDelay(1000, loadGem,0)
	    rockLoop = timer.performWithDelay(500, loadRocks,0)
	    heartLoop = timer.performWithDelay(4000, loadHeart,0)
	end
	
	local function gameOver()
		timer.pause(game_Loop)
		timer.cancel(game_Loop)
	    timer.cancel(gemLoop)
	    timer.cancel(rockLoop)
	    timer.cancel(heartLoop)
	    cart:removeEventListener("touch", startDrag)
		cart:removeEventListener("tap", fireshot)
		--Runtime:removeEventListener("collision", onCollision)
	    cart.myname = nil
	    cart:removeSelf()
		lose = display.newText(gameGroup, "Your Final Score: "..score,0,0,nil,50)
		lose.x = w/2
		lose.y = h/2
		lose.alpha = 0
		menu.y = h/2 + 150
		menu.x =w/2

		composer.removeHidden()
		transition.to(textLives,{time=500, alpha =0})
  	  transition.to(textScore,{time=500, alpha =0})
  	  transition.to(broken,{time=500, alpha =1})
  	  transition.to(better,{time=500, alpha =1})
		transition.to(lose,{time = 1000, alpha = 1})
		transition.to(menu,{time = 1000, alpha = 1})
		--timer.performWithDelay ( 3000, mainMenu)
	end
	
		local function reset()
		transition.to(cart,{time = 500, alpha = 1})
		--cart:addEventListener("touch", startDrag)
	    --cart:addEventListener("tap", fireshot)
	    timer.resume(gemLoop)
		timer.resume(rockLoop)
		timer.resume(heartLoop)
	end
	
		local function onCollision(event)
		--print(event.object1.myName)
		--print(event.object2.myName)		if(event.object1.myName =="shield" and event.object2.myName == "rock") or (event.object1.myName =="rock" and event.object2.myName == "shield") then
			if (event.object1.myName == "rock") then
				event.object1.myName=nil
				event.object1:removeSelf()
			else
				event.object2.myName=nil
				event.object2:removeSelf()
			end
		end
		if(event.object1.myName =="mine_cart" and event.object2.myName == "blue_gem") or (event.object1.myName =="blue_gem" and event.object2.myName == "mine_cart") then
			score=score+50
			audio.play(ding)
			if (event.object1.myName == "blue_gem") then
				event.object1:removeSelf()
				event.object1.myName=nil
			else
				event.object2.myName=nil
				event.object2:removeSelf()
			end
		end
		if(event.object1.myName =="mine_cart" and event.object2.myName == "red_gem") or (event.object1.myName =="red_gem" and event.object2.myName == "mine_cart") then
			score=score+100
			audio.play(ding)
			if (event.object1.myName == "red_gem") then
				event.object1.myName=nil
				event.object1:removeSelf()
			else
				event.object2.myName=nil
				event.object2:removeSelf()
			end
		end
		if(event.object1.myName =="mine_cart" and event.object2.myName == "purple_gem") or (event.object1.myName =="purple_gem" and event.object2.myName == "mine_cart") then
			score=score+500
			audio.play(ding)
			if (event.object1.myName == "purple_gem") then
				event.object1.myName=nil
				event.object1:removeSelf()
			else
				event.object2.myName=nil
				event.object2:removeSelf()
			end
		end
		if(event.object1.myName =="mine_cart" and event.object2.myName == "tri_gem") or (event.object1.myName =="tri_gem" and event.object2.myName == "mine_cart") then
			score=score+3000
			audio.play(ding)
			if (event.object1.myName== "tri_gem") then
				event.object1.myName=nil
				event.object1:removeSelf()
			else
				event.object2.myName=nil
				event.object2:removeSelf()
			end
		end
		if(event.object1.myName=="axe" and event.object2.myName == "rock" and event.object1.y >10) or (event.object1.myName =="rock" and event.object2.myName == "axe" and event.object2.y >10) then
			audio.play(clang)
			event.object1.myName=nil
			event.object2.myName=nil
			event.object1:removeSelf()
			event.object2:removeSelf()

		end
		if(event.object1.myName =="mine_cart" and event.object2.myName == "heart") or (event.object1.myName =="heart" and event.object2.myName == "mine_cart") then
			lives=lives+1
			audio.play(life)
			if (event.object1.myName== "heart") then
				event.object1.myName=nil
				event.object1:removeSelf()
			else
				event.object2.myName=nil
				event.object2:removeSelf()
			end
		end
		if(event.object1.myName =="mine_cart" and event.object2.myName == "rock") or (event.object1.myName =="rock" and event.object2.myName == "mine_cart") then
			audio.play(explosion,{channel=4})
			if (lives==1)then
				lives = lives - 1
				if (event.object1.myName == "rock") then
					event.object1.myName=nil
					event.object1:removeSelf()
				else
					event.object2.myName=nil
					event.object2:removeSelf()
				end
				timer.pause(gemLoop)
				timer.pause(rockLoop)
				timer.pause(heartLoop)
				cleanup("destroy")
				Runtime:removeEventListener("collision", onCollision)
				transition.to(cart,{time = 1000, alpha = 0, onComplete=gameOver})
			else
				--cart:removeEventListener("touch", startDrag)
	    		--cart:removeEventListener("tap", fireshot)
	    		cart.alpha = .5
				lives = lives - 1
				if (event.object1.myName == "rock") then
					event.object1.myName=nil
					event.object1:removeSelf()
				else
					event.object2.myName=nil
					event.object2:removeSelf()
				end
				timer.pause(gemLoop)
				timer.pause(rockLoop)
				timer.pause(heartLoop)
				cleanup("destroy")
				transition.to(cart,{time = 1000, x = w/2, onComplete=reset})
				--reset()
			end

		end
	end
	
	local function roll_cart()
		newText()
		transition.to(cart,{time = 2000,x = w/2,transition=easing.outQuad, onComplete = startGame})
	end
	
	--timer.performWithDelay(800, startGame)
	Runtime:addEventListener("collision", onCollision)
	menu:addEventListener("tap",mainMenu)
	timer.performWithDelay(800, roll_cart)

end
function scene:show(event) 
	local gameGroup = self.view
	--cart2:addEventListener("tap", go_menu)
end
function scene:hide(event) 
	local gameGroup = self.view 
	--cart:removeEventListener("touch", startDrag)
--	cart:removeEventListener("tap", fireshot)
--	Runtime:removeEventListener("collision", onCollision)
	--cart2:removeEventListener("tap", go_menu)
end
function scene:destroy(event)
	local gameGroup=self.view
end
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene