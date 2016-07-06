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
	local endGroup = self.view
	local numGroup=self.view
	numGroup.alpha=0
	local lives = 3
	local maxShieldLives=8
	local shieldLives = maxShieldLives
	score=0
	local score_4 = score
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
	--local bg = display.newImage(gameGroup,"rockwall2.jpg")
	local bg = display.newImage(gameGroup,"largeRocky.jpg")
	bg.x = w/2
	bg.y = h/2--h-bg.height/2
	bg.rotation=180
	bg:scale(.4,.4)
	local darkness = display.newImage(gameGroup,"blackness.png")
	--darkness.x = w/2
--	darkness.y = h/2-300
--	darkness:scale(.4,.4)
	darkness.x = w/2
	darkness.y = -100
	--darkness:scale(.4,.2)
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
	--audio.setVolume( .08,{channel=4})
	audio.fade( { channel=3, time=3000, volume=0.3 } )

	local shieldTable = {}
	local numShields=0
	
	local cart = display.newImage(gameGroup,"Cart.png")
	--cart.x = w/2
	cart.x = -200
	cart.y = h-108
	physics.addBody (cart, physicsData:get("Cart"))
	cart.isFixedRotation = true
	cart.myName = "mine_cart"
	
	local continue= display.newImage(endGroup,"continue.png")
	continue.y = -200
	continue.x =-200
	continue.alpha = 0

	
	local shield = display.newImage(gameGroup,"purpleShield.png")
	shield.x = w/2--+200
	shield.y = cart.y - 50
	--shield:scale(.8,.8)
	--shield.alpha = .6
	shield.alpha = 0
	physics.addBody (shield, physicsData:get("shield"))
	shield.myName = "shield"
	
	local numTable = {}
	local numNums = 0
	
	local shieldActive = false
--	
--	local shield_icon = display.newImage(gameGroup,"shield_apple.png")
--	shield_icon.x = w/2
--	shield_icon.y = 100
--	shield_icon:scale(.45,.45)
	
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
	
	local pauseButton=display.newImage(gameGroup,"pause.png")
	pauseButton.y = 50
	pauseButton.x = w - 50
	
	local pauseGroup=display.newGroup()
	pauseGroup.alpha=0
	local pauseMenu = display.newImage(pauseGroup,"pause_menu.png")
	pauseMenu.x = w/2
	pauseMenu.y= h/2
	--pauseMenu.alpha=0
	local resumeButton = display.newImage(pauseGroup, "resumeGame.png")
	resumeButton.x = w/2
	resumeButton.y = h/5+50
	local quitButton = display.newImage(pauseGroup, "quitGame.png")
	quitButton.x = w/2
	quitButton.y = h/3+50
	
	function pauseGame()
		cart:removeEventListener("tap", fireshot)
		cart:removeEventListener("touch", startDrag)
		timer.pause(game_Loop)
		timer.pause(gemLoop)
		timer.pause(rockLoop)
		timer.pause(heartLoop)
		timer.pause(shields)
		transition.pause()
		pauseMenu()
	end
	
	function pauseMenu()
		transition.to(pauseButton,{time=500,alpha=0})
		transition.to(textLives,{time=500,alpha=0})
		transition.to(textScore,{time=500,alpha=0})
		transition.to(pauseGroup,{time=500,alpha=1})
		resumeButton:addEventListener("tap",exitMenu)
	end
	
	function exitMenu()
		resumeButton:removeEventListener("tap",exitMenu)
		transition.to(pauseButton,{time=500,alpha=1})
		transition.to(pauseGroup,{time=500,alpha=0})
		transition.to(textLives,{time=500,alpha=1})
		transition.to(textScore,{time=500,alpha=1})
		timer.performWithDelay ( 500, resumeGame)
	end
	
	function resumeGame()
		cart:addEventListener("tap", fireshot)
		cart:addEventListener("touch", startDrag)
		timer.resume(game_Loop)
		timer.resume(gemLoop)
		timer.resume(rockLoop)
		transition.resume()
	end

	function scores()
		--local num1 =1000
		--local num2 = display.newImage(numGroup,"numbers/0.png")--11340
		--num2.x = w/2
		--num2.y=h/3+100
		--for i=0,9 do
--			--print(i)
--			numNums=numNums+1
--			img = "numbers/"..numNums..".png"
--			print(img)
--			numTable[numNums]=display.newImage(gameGroup,img)
--			if (i==0) then
--				print("yes")
--				numTable[numNums].x = w/8
--			else
--				numTable[numNums].x = numTable[numNums-1].x + 40
--			end
--			numTable[numNums].y = h/2
--		end
		num = tostring(score)
		--print(string.len(num))
		numSize = string.len(num)
		mult = 1
		if numSize%2~=0 then
			mult = numSize/2-.5
		else
			mult = numSize/2-.5
		end
		--print(mult)
		for i=1, numSize do
			local number = string.sub(num,i,i)
			numNums=numNums+1
			img = "numbers/"..number..".png"
			--print(img)
			numTable[numNums]=display.newImage(numGroup,img)
			if (i==1) then

				numTable[numNums].x = w/2 - (40*mult)
				print(numTable[numNums])
			else
				numTable[numNums].x = numTable[numNums-1].x + 40
			end
			numTable[numNums].y = h/3
			numTable[numNums].alpha=0
			transition.to(numTable[numNums],{time=1000,alpha=1})
		end
		--numGroup.alpha=0
	end
	
	function newText()
 	  textLives = display.newText("Lives: "..lives, 0, 0, nil, 36)
	   textScore = display.newText("Score: "..score, 0, 0, nil, 36)
	   textLives:setTextColor(1,1,1)
	   textScore:setTextColor(1,1,1)
   	--textLives.x = w-w/15--15
   	textLives.x=w/15
   	textScore.x = w/15--15
  	 --textLives.y = 10
  	 textLives.y = 60
   	textScore.y =10
   	textLives.alpha = 0
   	textScore.alpha = 0
  	 textScore.anchorX = 0
   	textScore.anchorY = 0
   	--textLives.anchorX = 1
   	textLives.anchorX = 0
  	 textLives.anchorY = 0
  	 transition.to(textLives,{time=500, alpha =1})
  	 transition.to(textScore,{time=500, alpha =1})
	end         
	
	function mainMenu()
		menu:removeEventListener("tap",mainMenu)
		textLives:removeSelf()
   	 textScore:removeSelf()
		composer.gotoScene("menu","fade",500)
	end

	function updateText()
	    textLives.text = "Lives: "..lives
	    textScore.text = "Score: "..score
	    textLives:toFront()
	    textScore:toFront()
	end
	
 function onward()
		gameGroup:removeSelf()
		continue:removeEventListener("tap",onward)
		textLives:removeSelf()
   	 textScore:removeSelf()
		composer.gotoScene("miners5","crossFade",500)
	end
	
	function nextLevel()
		Runtime:removeEventListener("collision", onCollision)
		timer.cancel(game_Loop)
		cart.myname = nil
	    cart:removeSelf()
		--transition.to(cart,{time = 700, x = w+200})
		onward = display.newImage(gameGroup, "Text_blank.png")
		onward.x = w/2
		onward.y = h/5
		onward.alpha = 0
		--onward:setFillColor ( 0,0,0)
		continue.y = cart.y
		continue.x =w+200
		continue.alpha = 1

		composer.removeHidden()
		transition.to(textLives,{time=500, alpha =0})
  	  transition.to(textScore,{time=500, alpha =0})
		transition.to(numGroup,{time=100,alpha = 1})
		transition.to(onward,{time = 1000, alpha = 1})
		--transition.to(continue,{time = 1000, x = w/2})
		transition.to(continue,{time = 2000,x = w/2,transition=easing.outQuad})
		scores()
	end
	
 function lowerShields()
		print("Shields failing!")
		transition.to(shield,{time=500, alpha = 0})
		shieldActive = false
		shieldLives = maxShieldLives
	end
	
 function raiseShields()
		if(shieldActive==false)then
			print("Raise Shields")
			shield.x=cart.x
			transition.to(shield,{time=500, alpha = .7,x = cart.x})
			shieldActive = true
		end
	end
	
	function cleanup(action)
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
			for i=1,table.getn(shieldTable) do
				if(shieldTable[i].myName~= nil) then
					shieldTable[i]:removeSelf()
					shieldTable[i].myName=nil
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
	
	function finalCleanup()
		cleanup("destroy")
		Runtime:removeEventListener("collision", onCollision)
		pauseButton:removeEventListener("tap",pauseGame)
		transition.to(pauseButton,{time = 500,alpha=0})
		--numTable.alpha=0
		transition.to(cart,{time = 2000,x = w+200,transition=easing.inQuad})
		timer.performWithDelay ( 2500, nextLevel)
	end
	
	function fireshot(event)
		audio.play(swoosh)
		numShot = numShot+1
		shotTable[numShot] = display.newImage(gameGroup,"pick-axe2.png")
		physics.addBody(shotTable[numShot], physicsData:get("pick-axe2"))
		shotTable[numShot].isbullet = true
		shotTable[numShot].x=cart.x
		shotTable[numShot].y=cart.y - 20
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
		shotTable[numShot]:toBack()
		bg:toBack()
		shield:toFront()
	end
	
		function loadRocks()
		pos_neg = math.random(0,1)
		mult=0
		if(pos_neg==0)then
			mult=1
		else
			mult=-1
		end
		local rock = math.random(1,3)
		numRocks= numRocks +1
		if rock == 1 then
			rockTable[numRocks] = display.newImage(gameGroup,"LRock1.png")
		elseif rock==2 then
			rockTable[numRocks] = display.newImage(gameGroup,"LRock2.png")
		else
			rockTable[numRocks] = display.newImage(gameGroup,"LRock3.png")
		end
		--rockTable[numRocks]:scale(.7,.7)
		--rockTable[numRocks]:scale(.3,.3)
		--physics.addBody(rockTable[numRocks], physicsData:get("rock"))
		physics.addBody(rockTable[numRocks],{density=1,friction=0.3,bounce=1})
		rockTable[numRocks].myName="rock"
		rockTable[numRocks].x = math.random(50,(w-50))
		rockTable[numRocks].y = math.random(100,(h/2))*-1
		--darkness:toBack()
		rockTable[numRocks]:toBack()
		bg:toBack()
		transition.to(rockTable[numRocks],{time = math.random(3000,4000), y = math.random(h+100,h*1.25),
		rotation = math.random(180,450)*mult})

	end
	
	function loadGem()
	numGems= numGems +1
--	if score <= 500 then
--		num=1
--	elseif score<=2000 then--5000 then
--		num = math.random(1,75)
--	elseif score<= 5000 then--20000 then
--		num = math.random(1,90)
--	else
		num = math.random(0,100)
	--end
	--print(num)
	if num>=80 then
		gemTable[numGems] = display.newImage(gameGroup,"blue.png")
		physics.addBody(gemTable[numGems], physicsData:get("blue_gem"))
		gemTable[numGems].myName="blue_gem"
	elseif(num>=40) then
		gemTable[numGems] = display.newImage(gameGroup,"red.png")
		physics.addBody(gemTable[numGems], physicsData:get("red_gem"))
		gemTable[numGems].myName="red_gem"
	else
		gemTable[numGems] = display.newImage(gameGroup,"purple.png")
		physics.addBody(gemTable[numGems], physicsData:get("purple_gem"))
		gemTable[numGems].myName="purple_gem"
	end
	gemTable[numGems].x = math.random(5,(w-50))
	gemTable[numGems].y = h/math.random(1,3)*-1
	--darkness:toBack()
	gemTable[numGems]:toBack()
	bg:toBack()
	transition.to(gemTable[numGems],{time = math.random(5000,7000), y = math.random(h+100,h*1.25)})
	end
	
	function loadHeart()
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
				--darkness:toBack()
				heartTable[numHearts]:toBack()
				bg:toBack()
				transition.to(heartTable[numHearts],{time = 6000, y = math.random(h+100,h*1.25)})
			end
		end
	end
	
 function loadShields()
		if(shieldActive==false) then
			num = 70--math.random(1,100)
			--print(num)
			if (num<=70) then
				numShields = numShields+1
				shieldTable[numShields]=display.newImage(gameGroup,"purple_shield.png")
				shieldTable[numShields].x = math.random(50,(w-50))
				shieldTable[numShields].y = math.random(100,(h/2))*-1
				shieldTable[numShields].myName = "red_shield"
				physics.addBody(shieldTable[numShields],{density=1,friction=0.3,bounce=1,isSensor=true})
				shieldTable[numShields]:toBack()
				bg:toBack()
				transition.to(shieldTable[numShields],{time = 5000, y = h+200})
			end
		end
	end

	
	function startDrag( event )
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
	
 function stopMoving()

		transition.cancel()
		lowerShields()
		cart:removeEventListener("tap", fireshot)
		for i=1,table.getn(rockTable) do
			transition.to(rockTable[i],{time=500, alpha = 0})

		end
		for i=1,table.getn(gemTable) do

				transition.to(gemTable[i],{time=500, alpha = 0})
		end
		for i=1,table.getn(gemTable) do
			transition.to(shotTable[i],{time=500, alpha = 0})
		end
		for i=1,table.getn(heartTable) do
			transition.to(heartTable[i],{time=500, alpha = 0})
		end
		for i=1,table.getn(shieldTable) do
			transition.to(shieldTable[i],{time=500, alpha = 0})
		end
		transition.to(cart,{time = 700, x = w/2})
		transition.to(shield,{time = 700, x = w/2})
		timer.performWithDelay ( 750, finalCleanup)
	end
	
	 function gameLoop()
		--print(shieldActive)
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
		if(score-score_4>=1500 and gemLoop~=nil)then
			timer.pause(gemLoop)
	    	timer.pause(rockLoop)
	    	timer.pause(heartLoop)
	    	timer.pause(shields)
	    	gemLoop=nil
	    	rockLoop=nil
	    	heartLoop=nil
	    	shields=nil
	    	stopMoving()
		end
		--timer.performWithDelay(1500, loadGem)
	end
	
	function startGame()
		composer.removeHidden()
		transition.to(heart,{time = 1000, y = h+60})
	    --spawnShip()
	    --newText()
	    --shieldsUp()
	    cart:addEventListener("touch", startDrag)
	    cart:addEventListener("tap", fireshot)
		--loadShields()
		loadRocks()
	    --timer.performWithDelay(350, addScore,30)
	    game_Loop = timer.performWithDelay(tick, gameLoop,0)
	    gemLoop = timer.performWithDelay(1500, loadGem,0)
	    rockLoop = timer.performWithDelay(1500, loadRocks,0)
	    heartLoop = timer.performWithDelay(4000, loadHeart,0)
	    shields = timer.performWithDelay ( 7000, loadShields,0)
	end
	
 function gameOver()
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
	
	function reset()
		transition.to(cart,{time = 500, alpha = 1})
		--cart:addEventListener("touch", startDrag)
	    --cart:addEventListener("tap", fireshot)
	    timer.resume(gemLoop)
		timer.resume(rockLoop)
		timer.resume(heartLoop)
		timer.resume(shields)
	end
	
	function onCollision(event)
		--print(event.object1.myName)
		--print(event.object2.myName)
		--print("Fired!")
		if(event.object1.myName =="shield" and event.object2.myName == "rock" and shieldActive==true) or (event.object1.myName =="rock" and event.object2.myName == "shield" and shieldActive==true) then
			--print(shieldActive)
			--print(shieldLives)
			if shieldLives~=1 then
				shield.alpha=.3
				transition.to(shield,{time=800,alpha=.7})
				shieldLives=shieldLives-1
				print("Shields down to "..(math.round(shieldLives/maxShieldLives*100)).."%")
				if (event.object1.myName == "rock") then
					event.object1.myName=nil
					event.object1:removeSelf()
				else
					event.object2.myName=nil
					event.object2:removeSelf()
				end
			else

				if (event.object1.myName == "rock") then
					event.object1.myName=nil
					event.object1:removeSelf()
				else
					event.object2.myName=nil
					event.object2:removeSelf()
				end
				lowerShields()
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
		if(event.object1.myName =="mine_cart" and event.object2.myName == "red_shield") or (event.object1.myName =="red_shield" and event.object2.myName == "mine_cart") then

			if (event.object1.myName == "red_shield") then
				event.object1:removeSelf()
				event.object1.myName=nil
			else
				event.object2.myName=nil
				event.object2:removeSelf()
			end
			raiseShields()
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
				timer.pause(shields)
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
				timer.pause(shields)
				cleanup("destroy")
				transition.to(cart,{time = 1000, x = w/2, onComplete=reset})
				--reset()
			end

		end
	end
	
	function roll_cart()
		composer.removeHidden()
		Runtime:addEventListener("collision", onCollision)
		pauseButton:addEventListener("tap",pauseGame)
		newText()
		--scores()
		transition.to(cart,{time = 2000,x = w/2,transition=easing.outQuad, onComplete = startGame})
	end
	
	--timer.performWithDelay(800, startGame)

	menu:addEventListener("tap",mainMenu)
	continue:addEventListener("tap",onward)
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
	--local gameGroup=self.view
end
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene