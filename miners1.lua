--
-- Project: Gem Mine
-- Description: 
--
-- Version: 1.0
-- Managed with http://CoronaProjectManager.com
--
-- Copyright 2014 Austin Graham. All Rights Reserved.
-- 
local composer = require "composer" 
local scene = composer.newScene()
function scene:create ( event )
	--Game tables and variables
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
	local lives = 3
	score=0
	local quit=false --To be used when a user wishes to quit the game
	local score_1 = score
	local spin = 360
	local numTable = {}
	local numNums = 0
	local numShot = 0
	local shotTable ={}
	local rockTable = {}
	local numRocks = 0
	local gemTable = {}
	local numGems = 0

	--used to calculate the destinations of all transistion.to methods on objects falling so it is in one place.
	local fallingObjectDestinationPoint = 1.5*h

	local maxShotAge = 1000
	local tick = 400  -- time between game loops in milliseconds
	local died=false
	
	--Game Images (background, objects, etc)
	--local bg = display.newImage(gameGroup,"rockwall2.jpg")
	local darkness = display.newImage(gameGroup,"images/darkness.png")
	darkness.x = w/2
	darkness.y = h/2

	local bg = display.newImage(gameGroup,"images/rockBackground.jpg")
	bg.x = w/2
	bg.y = h/2--h-bg.height/2
	bg.rotation=180
	bg:toBack()
	--bg:scale(.4,.4)

	local newRail=display.newImage(gameGroup,"images/newTrack.png")
	newRail.x=w/2
	newRail.anchorY=0
	newRail.y=h-12

	local cart = display.newImage(gameGroup,"Cart.png")
	cart.x = -200
	cart.y = h-108
	physics.addBody (cart, physicsData:get("Cart"))
	cart.isFixedRotation = true
	cart.myName = "mine_cart"
	local pauseButton=display.newImage(gameGroup,"pause.png")
	pauseButton.y = 50
	pauseButton.x = w - 50
	pauseButton.alpha=0


	local goal=display.newImage(gameGroup,"pointGoal.png")
	goal.x = w/2
	goal.y = h/2 - 150
	goal.alpha=0
	local beginButton = display.newImage(gameGroup,"beginButton.png")
	beginButton.x = w/2
	beginButton.y = goal.y+120
	beginButton.alpha=0
	local scoreGoal = display.newImage(gameGroup,"numbers/1000.png")
	scoreGoal.x = w/2
	scoreGoal.y = goal.y
	scoreGoal.alpha=0
	
	--end group images (if you die and fail the level)
	local better = display.newImage(endGroup,"finalText.png")
	better.x = w/2
	better.y = 200
	--better:scale(.6,.6)
	better.alpha = 0
	local broken = display.newImage(endGroup,"broken.png")
	broken.x = w/2
	broken.y = h/2-130
	broken.alpha = 0
	local menu = display.newImage(endGroup,"menu.png")
	menu.y = -200
	menu.x =-200
	menu.alpha = 0
	menu:scale(.8,.8)
	local continue= display.newImage(endGroup,"continue.png")
	continue.y = -200
	continue.x =-200
	continue.alpha = 0
	
	--All images relating to the pause menu
	local pauseGroup=display.newGroup()
	pauseGroup.alpha=0
	local pauseMenu = display.newImage(pauseGroup,"pause_menu.png")
	pauseMenu.x = w/2
	pauseMenu.y= h/2
	--pauseMenu.alpha=0
	local resumeButton = display.newImage(pauseGroup, "resumeGame.png")
	resumeButton.x = w/2
	resumeButton.y = pauseMenu.y+125
	local quitButton = display.newImage(pauseGroup, "quitGame.png")
	quitButton.x = w/2
	quitButton.y = pauseMenu.y+250
	local cavernNumber=display.newImage(pauseGroup, "cavernNumber.png")
	cavernNumber.x = w/2 - 25
	cavernNumber.y = h/2 - ((pauseMenu.height/2)-180)
	local cavernNum=display.newImage(pauseGroup, "numbers/1.png")
	cavernNum.x=w/2+(cavernNumber.width/2.3 - 25)
	cavernNum.y = cavernNumber.y
	local cavernProgress=display.newImage(pauseGroup, "cavernProgress.png")
	cavernProgress.x = w/2
	cavernProgress.y = cavernNumber.y + 100

	-- local tempAd = display.newImage(pauseGroup,"bannerTest.jpg")
	-- --tempAd.alpha=0
	-- tempAd.anchorX=0
	-- tempAd.anchorY=0
	-- tempAd.x=(w/2)-234
	-- tempAd.y=pauseMenu.y+360

	--Game Audio
	local swoosh = audio.loadSound("sounds/swoosh.mp3")
	local ding = audio.loadSound("sounds/ding.mp3")
	local clang = audio.loadSound("sounds/axe.mp3")
	local life = audio.loadSound("sounds/life.mp3")
	local explosion = audio.loadSound("sounds/explosion.wav")
	local gem = audio.loadSound("sounds/shells.mp3")
	local gong = audio.loadSound("sounds/gong.mp3")
	if mute==false then
		audio.setVolume( 1)
		audio.setVolume( 1,{channel=1})
		audio.setVolume( 1,{channel=2})
		--audio.setVolume( .08,{channel=4})
		audio.fade( { channel=3, time=3000, volume=0.3 } )
	end



	
	--The openning prompt to begin
	function openGoal()
		beginButton:addEventListener("tap",roll_cart)
		transition.to(beginButton,{time=500,alpha=1})
		transition.to(goal,{time=500,alpha=1})
		transition.to(scoreGoal,{time=500,alpha=1})
	end
	
	--rolls in the car, removes the prompt and begins to initiate game
	function roll_cart()
		newText()
		transition.to(darkness,{time=500,alpha=1})
		beginButton:removeEventListener("tap",roll_cart)
		transition.to(beginButton,{time=500,alpha=0})
		transition.to(goal,{time=500,alpha=0})
		transition.to(scoreGoal,{time=500,alpha=0})
		--scores()
		Runtime:addEventListener("collision", onCollision)
		pauseButton:addEventListener("tap",pauseGame)
		transition.to(goal,{time=500,alpha=0})
		transition.to(pauseButton,{time=500,alpha=1})
		transition.to(cart,{time = 2000,x = w/2,transition=easing.outQuad, onComplete = startGame})
	end

	
	--initiates the game
	function startGame()
		composer.removeHidden()

	    cart:addEventListener("touch", startDrag)
	    cart:addEventListener("tap", fireshot)

	    loadGem()
	    loadRocks()
	    game_Loop = timer.performWithDelay(tick, gameLoop,0)
	    gemLoop = timer.performWithDelay(2000, loadGem,0)
	    rockLoop = timer.performWithDelay(2000, loadRocks,0)

	end
	
	--pasues game
	function pauseGame()
		cart:removeEventListener("tap", fireshot)
		cart:removeEventListener("touch", startDrag)
		timer.pause(game_Loop)
		timer.pause(gemLoop)
		timer.pause(rockLoop)
		transition.pause()
		pauseMenuAction()
	end
	--brings up the pause menu
	function pauseMenuAction()
		if _G.adsAvailable then
			--_G.showAd("banner",(w/2)-pauseMenu.width/2,pauseMenu.y+360)
		end
		transition.to(pauseButton,{time=500,alpha=0})
		transition.to(textLives,{time=500,alpha=0})
		transition.to(textScore,{time=500,alpha=0})
		transition.to(pauseGroup,{time=500,alpha=1})

		--scores()
		resumeButton:addEventListener("tap",exitMenu)
		quitButton:addEventListener("tap",quitLevel)
	end
	--exits pause menu
	function exitMenu()
		resumeButton:removeEventListener("tap",exitMenu)
		if _G.adsAvailable then
			--_G.hideAd()
		end
		transition.to(pauseButton,{time=500,alpha=1})
		transition.to(pauseGroup,{time=500,alpha=0})
		transition.to(textLives,{time=500,alpha=1})
		transition.to(textScore,{time=500,alpha=1})
		if(quit==true)then
			timer.performWithDelay ( 500, stopMoving)
		else
			timer.performWithDelay ( 500, resumeGame)
		end
	end
	
	function quitLevel()
		quit=true
		exitMenu()
	end
	
	function resumeGame()
		cart:addEventListener("tap", fireshot)
		cart:addEventListener("touch", startDrag)
		timer.resume(game_Loop)
		timer.resume(gemLoop)
		timer.resume(rockLoop)
		transition.resume()
	end
	

	--creates new lives and score text at the top of the screen
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
	
	--keeps the game running smoothly; also stops the game when a point value is reached.
	function gameLoop()
		updateText()
		cleanup("upkeep")
		bg:toBack()
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
		if((score-score_1)>=1000)then
			--timer.pause(gemLoop)
	    	--timer.pause(rockLoop)
	    	--gemLoop=nil
	    	--rockLoop=nil
	    	timer.pause(game_Loop)
	    	timer.cancel ( game_Loop )
	    	stopMoving()
		end
		--timer.performWithDelay(1500, loadGem)
	end
	
	--keeps lives and score updated on-screen
	function updateText()
	    textLives.text = "Lives: "..lives
	    textScore.text = "Score: "..score
	    textLives:toFront()
	    textScore:toFront()
	end
	
	--function for throwing pick axe when player taps the car
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
	end
	
	--function to create falling rocks
	function loadRocks()
		--print("rocks")
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
			physics.addBody(rockTable[numRocks], physicsData:get("LRock1"))
		elseif rock==2 then
			rockTable[numRocks] = display.newImage(gameGroup,"LRock2.png")
			physics.addBody(rockTable[numRocks], physicsData:get("LRock2"))
		else
			rockTable[numRocks] = display.newImage(gameGroup,"LRock3.png")
			physics.addBody(rockTable[numRocks], physicsData:get("LRock3"))
		end

		--physics.addBody(rockTable[numRocks], physicsData:get("rock"))
		--physics.addBody(rockTable[numRocks],{density=1,friction=0.3,bounce=1})
		rockTable[numRocks].myName="rock"
		rockTable[numRocks].x = math.random(50,(w-50))
		rockTable[numRocks].y = math.random(100,(h/2))*-1
		--darkness:toBack()
		rockTable[numRocks]:toBack()
		bg:toBack()
		transition.to(rockTable[numRocks],{time = math.random(4000,6000), y = math.random(fallingObjectDestinationPoint,fallingObjectDestinationPoint+100),
		rotation = math.random(180,450)*mult})

	end
	
	--creates the falling gems (blue in this case)
	function loadGem()
		numGems= numGems +1

		gemTable[numGems] = display.newImage(gameGroup,"blue.png")
		physics.addBody(gemTable[numGems], physicsData:get("blue_gem"))
		gemTable[numGems].myName="blue_gem"

		gemTable[numGems].x = math.random(5,(w-50))
		gemTable[numGems].y = h/math.random(1,3)*-1

		gemTable[numGems]:toBack()
		bg:toBack()
		transition.to(gemTable[numGems],{time = math.random(6000,8000), y = math.random(fallingObjectDestinationPoint,fallingObjectDestinationPoint+200)})
	end
	
	--handles the user moving the car left to right
	function startDrag( event )
		local t = event.target
		local phase = event.phase
		if "began" == phase then
			display.getCurrentStage():setFocus(t)
			t.isFocus = true
			--Store inital position
			t.x0 = event.x - t.x

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
	
	--called if hit with a rock to allow the player control again
	function reset()
		transition.to(cart,{time = 500, alpha = 1})
		cart:addEventListener("touch", startDrag)
	    cart:addEventListener("tap", fireshot)
	    timer.resume(gemLoop)
		timer.resume(rockLoop)
	end
	
	--will print out the uses score at the end using graphics
	function scores()

		num = tostring(score)
		print(num)
		--print(string.len(num))
		numSize = string.len(num)
		mult = 1
		if numSize%2~=0 then
			mult = numSize/2-.5
		else
			mult = numSize/2-.5
		end
		print(mult)
		for i=1, numSize do
			local number = string.sub(num,i,i)
			numNums=numNums+1
			img = "numbers/"..number..".png"
			print(img)
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
	

	--maintians the game objects and removes unused ones form memory
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

			for i=1,table.getn(shotTable) do
				if(shotTable[i].myName~= nil) then
					shotTable[i]:removeSelf()
					shotTable[i].myName=nil
				end
			end
		elseif (action == "upkeep")then
			for i=1,table.getn(rockTable) do
				if(rockTable[i].myName~= nil and rockTable[i].y >= fallingObjectDestinationPoint-50) then
					rockTable[i]:removeSelf()
					rockTable[i].myName=nil

				end
			end
			for i=1,table.getn(gemTable) do
				if(gemTable[i].myName~= nil and gemTable[i].y >= fallingObjectDestinationPoint-50) then
					gemTable[i]:removeSelf()
					gemTable[i].myName=nil
				end
			end
			for i=1,table.getn(shotTable) do
				if(shotTable[i].myName~= nil and shotTable[i].y <-100) then
					shotTable[i]:removeSelf()
					shotTable[i].myName=nil
				end
			end

		end
	end
	
	--brings up a game over screen
	function gameOver()
		--timer.pause(game_Loop)
		timer.cancel(game_Loop)
	    timer.cancel(gemLoop)
	    timer.cancel(rockLoop)

		pauseButton:removeEventListener("tap",pauseGame)
		transition.to(pauseButton,{time = 500,alpha=0})
	    cart:removeEventListener("touch", startDrag)
		cart:removeEventListener("tap", fireshot)
		--lose = display.newText(gameGroup, "Your Final Score: "..score,0,0,nil,50)
--		lose.x = w/2
--		lose.y = h/2
--		lose.alpha = 0
		scores()
		menu.y = h/2 + 150
		menu.x =w/2
		composer.removeHidden()
		transition.to(textLives,{time=500, alpha =0})
  	  transition.to(textScore,{time=500, alpha =0})
  	  --transition.to(broken,{time=500, alpha =1})
  	  transition.to(better,{time=500, alpha =1})
		--transition.to(lose,{time = 1000, alpha = 1})
		transition.to(menu,{time = 1000, alpha = 1})
	end

	--goes to the menu after defeat
	function mainMenu()
		Runtime:removeEventListener("collision", onCollision)

		cart.myname = nil
	    cart:removeSelf()
		gameGroup:removeSelf()
		menu:removeEventListener("tap",mainMenu)
		textLives:removeSelf()
   	 textScore:removeSelf()
		composer.gotoScene("menu","fade",500)
	end
	
	--is called if the player reaches the target score; cleanly remoeves everything and begins moving player on
	function stopMoving()
		timer.pause(gemLoop)
	    timer.pause(rockLoop)
	    timer.cancel(gemLoop)
	    timer.cancel(rockLoop)
		transition.cancel()
		transition.to(textLives,{time=500, alpha =0})
  	  transition.to(textScore,{time=500, alpha =0})
		cart:removeEventListener("tap", fireshot)
		for i=1,table.getn(rockTable) do
			transition.to(rockTable[i],{time=500, alpha = 0})
		end
		for i=1,table.getn(gemTable) do
				transition.to(gemTable[i],{time=500, alpha = 0})
		end
		for i=1,table.getn(shotTable) do
			transition.to(shotTable[i],{time=500, alpha = 0})
		end
		transition.to(cart,{time = 700, x = w/2})
		timer.performWithDelay ( 750, finalCleanup)
	end

	--destroys all game objects and rolls out the mine car
	function finalCleanup()
		cleanup("destroy")
		--Runtime:removeEventListener("collision", onCollision)
		pauseButton:removeEventListener("tap",pauseGame)
		transition.to(pauseButton,{time = 500,alpha=0})
		transition.to(cart,{time = 2000,x = w+200,transition=easing.inQuad})
		if(quit==true)then
			timer.performWithDelay ( 2500, mainMenu)
		else
			timer.performWithDelay ( 2500, nextLevel)
		end
	end
	
	--brings up a congrats view and button to continue to next level
	function nextLevel()
		Runtime:removeEventListener("collision", onCollision)
		--timer.cancel(game_Loop)
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
		--transition.to(textLives,{time=500, alpha =0})
  	  --transition.to(textScore,{time=500, alpha =0})
		transition.to(numGroup,{time=100,alpha = 1})
		transition.to(onward,{time = 1000, alpha = 1})
		--transition.to(continue,{time = 1000, x = w/2})
		transition.to(continue,{time = 2000,x = w/2,transition=easing.outQuad})
		scores()
	end
	
	--moves to next level
	function onward()
		gameGroup:removeSelf()
		continue:removeEventListener("tap",onward)
		textLives:removeSelf()
   	 textScore:removeSelf()
		composer.gotoScene("miners2","crossFade",500)
	end

	--handles all collision detection
	function onCollision(event)

		if(event.object1.myName =="mine_cart" and event.object2.myName == "blue_gem") or (event.object1.myName =="blue_gem" and event.object2.myName == "mine_cart") then
			score=score+50
			audio.play(gem)
			if (event.object1.myName == "blue_gem") then
				event.object1:removeSelf()
				event.object1.myName=nil
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

		if(event.object1.myName =="mine_cart" and event.object2.myName == "rock") or (event.object1.myName =="rock" and event.object2.myName == "mine_cart") then

			if (lives==1)then
				lives = lives - 1
				audio.play(gong)
				if (event.object1.myName == "rock") then
					event.object1.myName=nil
					event.object1:removeSelf()
				else
					event.object2.myName=nil
					event.object2:removeSelf()
				end
				timer.pause(gemLoop)
				timer.pause(rockLoop)

				cleanup("destroy")
				Runtime:removeEventListener("collision", onCollision)
				transition.to(cart,{time = 1000, alpha = 0, onComplete=gameOver})
			else
				audio.play(explosion,{channel=4})
				cart:removeEventListener("touch", startDrag)
	    		cart:removeEventListener("tap", fireshot)
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

				cleanup("destroy")
				transition.to(cart,{time = 1000, x = w/2, onComplete=reset})
				--reset()
			end

		end
	end

	menu:addEventListener("tap",mainMenu)

	continue:addEventListener("tap",onward)
	--timer.performWithDelay(800, roll_cart)
	timer.performWithDelay ( 800, openGoal)

end

function scene:show(event) 
	local gameGroup = self.view

end
function scene:hide(event) 
	local gameGroup = self.view 

end
function scene:destroy(event)
	--local gameGroup=self.view
end
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene