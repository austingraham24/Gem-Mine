local composer = require("composer")
local scene = composer.newScene()

local topGroup

local create = function (group)
	local w = display.contentWidth
	local h = display.contentHeight

	require("physics")
	physics.start()
	physics.setGravity(0,0)
	--physics.setDrawMode( "hybrid" )

	w = display.contentWidth
	h = display.contentHeight
	local physicsData = (require "field").physicsData(scaleFactor)
	local gameGroup = display.newGroup()--self.view
	topGroup:insert(gameGroup)
	--local endGroup = self.view
	--local numGroup=self.view
	local lives = 3
	score=0
	local shieldActive = false --whether or not the shield should be up
	local quit=false --To be used when a user wishes to quit the game
	local maxShieldLives=3
	local shieldLives = maxShieldLives -- shield variables
	local score2 = 0
	local spin = 360
	local numTable = {}
	local numNums = 0
	local numShot = 0
	local shotTable ={}
	local rockTable = {}
	local numRocks = 0
	local gemTable = {}
	local numGems = 0
	local heartTable={}
	local numHearts = 0
	local shieldTable = {}
	local numShields=0
	local fallingObjectDestinationPoint = 1.5*h

	local maxShotAge = 1000
	local tick = 400  -- time between game loops in milliseconds
	local died=false
	
	--Game Images (background, objects, etc)
	--local bg = display.newImage(gameGroup,"rockwall2.jpg")
	local darkness = display.newImage(gameGroup,"images/darkness.png")
	darkness.x = w/2
	darkness.y = h/2
	darkness:scale(1.5,1.5) -- for Mac versions only

	local bg = display.newImage(gameGroup,"images/rockBackground.jpg")
	bg.x = w/2
	bg.y = h/2--h-bg.height/2
	bg.rotation=180
	bg:toBack()
	bg:scale(1.5,1.5)

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


	local introPopUp=display.newImage(gameGroup,"images/tutorialIntro.png")
	introPopUp.x = w/2
	introPopUp.y = h/2 - 150
	introPopUp.alpha=0
	local beginButton = display.newImage(gameGroup,"beginButton.png")
	beginButton.x = w/2
	beginButton.y = introPopUp.y+120
	beginButton.alpha=0

	local controlPopUp1=display.newImage(gameGroup,"images/control1.png")
	controlPopUp1.anchorY=0
	controlPopUp1.x = w/2
	controlPopUp1.y = h/2 - controlPopUp1.height
	controlPopUp1.alpha=0

	local controlPopUp2=display.newImage(gameGroup,"images/control2.png")
	controlPopUp2.anchorY=0
	controlPopUp2.x = w/2
	controlPopUp2.y = h/2 - controlPopUp2.height
	controlPopUp2.alpha=0

	local controlPopUp3=display.newImage(gameGroup,"images/control3.png")
	controlPopUp3.anchorY=0
	controlPopUp3.x = w/2
	controlPopUp3.y = h/2 - controlPopUp3.height
	controlPopUp3.alpha=0

	local nextButton= display.newImage(gameGroup,"images/next.png")
	nextButton.x = (controlPopUp1.x + controlPopUp1.width/2) - (nextButton.width/2)-15
	nextButton.y = (h/2) - (nextButton.height/2) - 15
	nextButton.alpha=0

	local backButton= display.newImage(gameGroup,"images/back.png")
	backButton.x = (controlPopUp1.x - controlPopUp1.width/2) + (backButton.width/2)+15
	backButton.y = (h/2) - (backButton.height/2) - 15
	backButton.alpha=0

	local pointer1=display.newImage(gameGroup,"images/pointer-small.png")
	pointer1.alpha=0
	pointer1:scale(1,-1)
	
	--end group images (if you die and fail the level)
	local better = ""
	local broken = ""
	local menu = ""
	local continue= ""
	
	--The shield
	local shield = display.newImage(gameGroup,"blueShield.png")

	shield.alpha = 0
	physics.addBody (shield, physicsData:get("shield"))
	shield.myName = "shield"
	
	local shieldWeld = ""

	 local touchAnimOptions={width=500, height=500, numFrames=5}
	 local touchAnimSheet = graphics.newImageSheet("images/ringsAnim.png",touchAnimOptions)
	-- --local shield = display.newImage(gameGroup,"purpleShield.png")
	
	 local touchAnimSequenceData={
	 	{name="anim", start=1, count=5, time=800, loopCount=1}
	 	}
	
	 local ringAnim=display.newSprite(gameGroup,touchAnimSheet, touchAnimSequenceData)
	 ringAnim.x = w/2
	 ringAnim.y = h/2
	 ringAnim:setSequence('anim')
	 ringAnim:scale(.5,.5)
	 --ringAnim:play()
	 ringAnim.alpha=0

	--local rings = display.newImage(gameGroup,"ringsAnim.png")
	--rings.x=w/2
	--rings.y=h/2
	--rings:scale(.5,.5)

	--anonyFuctions
	goToCartInfo1 = function()
		transition.to(controlPopUp2,{time=250,alpha=0});
		transition.to(nextButton,{time=250,alpha=0});
		transition.to(backButton,{time=250,alpha=0});
		timer.performWithDelay(250,cartInfo1);
		end
	goToCartInfo2 = function() 
		transition.to(controlPopUp1,{time=250,alpha=0});
		transition.to(nextButton,{time=250,alpha=0});
		timer.performWithDelay(250,cartInfo2);
		end

	goToCartInfo3 = function() 
		transition.to(pointer1,{time=500, y = cart.y - 150, onComplete=function() 
			transition.to(pointer1,{time=250,alpha=0});
			transition.to(controlPopUp2,{time=250,alpha=0});
			transition.to(nextButton,{time=250,alpha=0});
			transition.to(backButton,{time=250,alpha=0});
			timer.performWithDelay(250,cartInfo3);
			end});
		end

	--Game Audio
	local swoosh = audio.loadSound("sounds/swoosh.mp3")
	local ding = audio.loadSound("sounds/ding.mp3")
	local clang = audio.loadSound("sounds/axe.mp3")
	local life = audio.loadSound("sounds/life.mp3")
	local explosion = audio.loadSound("sounds/explosion.wav")
	local gem = audio.loadSound("sounds/shells.mp3")
	local gong = audio.loadSound("sounds/gong.mp3")
	local punch = audio.loadSound("sounds/punch.mp3")
	--local decloak = audio.loadSound("sounds/decloak_romulan.mp3")
	--local cloak = audio.loadSound("sounds/cloak_romulan.mp3")
	if mute==false then
		audio.setVolume( 1)
		audio.setVolume( 1,{channel=1})
		audio.setVolume( 1,{channel=2})
		--audio.setVolume( .08,{channel=4})
		audio.fade( { channel=3, time=3000, volume=0.3 } )
	end

	--function listening for sprite events
	function spriteHandler(event)
		if(event.phase=='ended')then
			ringAnim.alpha=0
		end
	end

	--function to play tap anim
	function playTapAnim()
		ringAnim.x = cart.x
		ringAnim.y = cart.y
		ringAnim.alpha=1
		ringAnim:play()
	end

	--The openning prompt to begin the tutorial
	function openInst1()
		beginButton:addEventListener("tap",roll_cart)
		transition.to(beginButton,{time=500,alpha=1})
		transition.to(introPopUp,{time=500,alpha=1})
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
		--pauseButton:addEventListener("tap",pauseGame)
		transition.to(introPopUp,{time=500,alpha=0})
		--transition.to(pauseButton,{time=500,alpha=1})
		transition.to(cart,{time = 2000,x = w/2,transition=easing.outQuad, onComplete = startTutorial})
	end

	function sampleMoveCart1()
		transition.to(cart,{time=1000,x = 150, onComplete=function() transition.to(pointer1,{time=500, y = cart.y - 150}); end})
		transition.to(pointer1,{time=1000,x = 130})
		timer.performWithDelay(2000, sampleMoveCart2)
	end

	function sampleMoveCart2()
		transition.to(pointer1,{time=500,y = cart.y-75, onComplete=function()
			playTapAnim();
			timer.performWithDelay(1000,function()
				transition.to(cart,{time=1000,x = w/2});
				transition.to(pointer1,{time=1000,x = (w/2)-20});
				end);
			timer.performWithDelay(2000,goToCartInfo3);
			end
			})
	end


	--initiates the game
	function startTutorial()
		composer.removeHidden()
		--shield.x = cart.x
		--shield.y=cart.y-50
		--shieldWeld=physics.newJoint("weld",shield,cart,cart.x,cart.y)
		cartInfo1()
	    --cart:addEventListener("touch", startDrag)
	    --cart:addEventListener("tap", fireshot)
	    --loadGem()
	    --loadRocks()
	    --game_Loop = timer.performWithDelay(tick, gameLoop,0)
	    --gemLoop = timer.performWithDelay(2000, loadGem,0)
	    --rockLoop = timer.performWithDelay(2000, loadRocks,0)
		--heartLoop = timer.performWithDelay(4000, loadHeart,0)
	    --shieldLoop = timer.performWithDelay ( 7000, loadShields,0)
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
	
	--keeps lives and score updated on-screen
	function updateText()
	    textLives.text = "Lives: "..lives
	    textScore.text = "Score: "..score2
	    textLives:toFront()
	    textScore:toFront()
	end
	
	--first pop up about cart control
	function cartInfo1()
		backButton:removeEventListener("tap",goToCartInfo1)

		pointer1.x = (w/2) - 20
		pointer1.y = cart.y - 150
		transition.to(controlPopUp1,{time=250,alpha=1})
		transition.to(nextButton,{time=250,alpha=1})
		transition.to(pointer1,{time=250,alpha=1})
		--transition.to(backButton,{time=500,alpha=1})
		nextButton:addEventListener("tap", goToCartInfo2)
	end

	function cartInfo2()
		print('second control')
		nextButton:removeEventListener("tap",goToCartInfo2)
		transition.to(controlPopUp2,{time=250,alpha=1})
		--transition.to(nextButton,{time=250,alpha=1})
		transition.to(pointer1,{time=500,y=cart.y - 75,alpha=1, onComplete=function() playTapAnim(); end})
		transition.to(backButton,{time=250,alpha=1})
		backButton:addEventListener("tap",goToCartInfo1)
		timer.performWithDelay(1500, sampleMoveCart1)
		--nextButton:addEventListener("tap",cartInfo2)
	end

	function cartInfo3()
		print('third control')
		transition.to(controlPopUp3,{time=250,alpha=1})
		cart:addEventListener('touch',startDrag)

	end

	--shield functions
	function lowerShields()
		if(shield.alpha>0) then
			--audio.play(cloak)
		end
		print("Shields failing!")
		--physics.removeBody(shield) 
		transition.to(shield,{time=500, alpha = 0})
		shieldActive = false
		shieldLives=maxShieldLives
	end
	
	function raiseShields()
		if(shieldActive==false)then
			--audio.play(decloak)
			print("Raise Shields")
			--shield.x=cart.x
			transition.to(shield,{time=300, alpha = .7,x = cart.x})
			--physics.addBody (shield, physicsData:get("shield"))
			shield.myName = "shield"
			shieldActive = true
		end
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
		shield:toFront()
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

		rockTable[numRocks].myName="rock"
		rockTable[numRocks].x = math.random(50,(w-50))
		rockTable[numRocks].y = math.random(100,(h/2))*-1
		--darkness:toBack()
		rockTable[numRocks]:toBack()
		bg:toBack()
		transition.to(rockTable[numRocks],{time = math.random(4000,6000), y = math.random(fallingObjectDestinationPoint,fallingObjectDestinationPoint+200),
		rotation = math.random(180,450)*mult})

	end
	
	--creates the falling gems (blue in this case)
	function loadGem()
		numGems= numGems +1
		num = math.random(0,100)
		--print(num)
		if num<=80 then
			gemTable[numGems] = display.newImage(gameGroup,"blue.png")
			physics.addBody(gemTable[numGems], physicsData:get("blue_gem"))
			gemTable[numGems].myName="blue_gem"
		else
			gemTable[numGems] = display.newImage(gameGroup,"red.png")
			physics.addBody(gemTable[numGems], physicsData:get("red_gem"))
			gemTable[numGems].myName="red_gem"
		end
		gemTable[numGems].x = math.random(5,(w-50))
		gemTable[numGems].y = h/math.random(1,3)*-1
		--darkness:toBack()
		gemTable[numGems]:toBack()
		bg:toBack()
		transition.to(gemTable[numGems],{time = math.random(6000,8000), y = math.random(fallingObjectDestinationPoint,fallingObjectDestinationPoint+200)})
	end
	
	--cretaes shield power-ups
	function loadShields()
		if(shieldActive==false) then
			num = 70--math.random(1,100)
			--print(num)
			if (num<=70) then
				numShields = numShields+1
				shieldTable[numShields]=display.newImage(gameGroup,"blue_shield.png")
				shieldTable[numShields].x = math.random(50,(w-50))
				shieldTable[numShields].y = math.random(100,(h/2))*-1
				shieldTable[numShields].myName = "blue_shield"
				physics.addBody(shieldTable[numShields],{density=1,friction=0.3,bounce=1,isSensor=true})
				shieldTable[numShields]:toBack()
				bg:toBack()
				transition.to(shieldTable[numShields],{time = 5000, y = fallingObjectDestinationPoint})
			end
		end
	end
	
	--handles the user moving the car left to right
	function startDrag( event )
		shield:toFront()
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
			if(shieldActive==true)then
					--shield.x = t.x
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
		timer.resume(heartLoop)
		timer.resume(shieldLoop)
	end
	

	--maintians the game objects and removes unused ones form memory
	function cleanup(action)
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
		for i=1,table.getn(shieldTable) do
			if(shieldTable[i].myName~= nil) then
				shieldTable[i]:removeSelf()
				shieldTable[i].myName=nil
			end
		end
	end	

	--handles all collision detection
	function onCollision(event)

		if(event.object1.myName =="shield" and event.object2.myName == "rock" and shieldActive==true) or (event.object1.myName =="rock" and event.object2.myName == "shield" and shieldActive==true) then
			audio.play(punch)
			if shieldLives~=1 then
				shield.alpha=.3
				transition.to(shield,{time=800,alpha=.7})
				shieldLives=shieldLives-1
				print("Shields down to "..(math.round(shieldLives/3*100)).."%")
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
			score2=score2+50
			audio.play(gem)
			if (event.object1.myName == "blue_gem") then
				event.object1:removeSelf()
				event.object1.myName=nil
			else
				event.object2.myName=nil
				event.object2:removeSelf()
			end
		end
		
		if(event.object1.myName =="mine_cart" and event.object2.myName == "blue_shield") or (event.object1.myName =="blue_shield" and event.object2.myName == "mine_cart") then

			if (event.object1.myName == "blue_shield") then
				event.object1:removeSelf()
				event.object1.myName=nil
			else
				event.object2.myName=nil
				event.object2:removeSelf()
			end
			raiseShields()
		end
		
		if(event.object1.myName =="mine_cart" and event.object2.myName == "red_gem") or (event.object1.myName =="red_gem" and event.object2.myName == "mine_cart") then
			score2=score2+100
			audio.play(gem)
			if (event.object1.myName == "red_gem") then
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

		if(event.object1.myName =="mine_cart" and event.object2.myName == "rock") or (event.object1.myName =="rock" and event.object2.myName == "mine_cart") then


			if (lives==1)then
				audio.play(gong)
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
				timer.pause(shieldLoop)
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

	ringAnim:addEventListener('sprite',spriteHandler)

	timer.performWithDelay ( 800, openInst1)
	
end

function scene:create(event)
	local sceneGroup = display.newGroup()
end

function scene:willEnter(event)
	local sceneGroup = self.view
	topGroup = display.newGroup()
	sceneGroup:insert(topGroup)
	create(topGroup)
end

function scene:didEnter(event)
	local sceneGroup = self.view
end

function scene:willExit(event)
	local sceneGroup = self.view
end

function scene:didExit(event)
	local sceneGroup = self.view
	display.remove(topGroup)
	topGroup=nil
end

function scene:show(event)
	local sceneGroup=self.view
	local willDid = event.phase
	if(willDid=="will")then
		self:willEnter(event)
	elseif(willDid=="did")then
		self:didEnter(event)
	end
end
function scene:hide(event)
	local sceneGroup=self.view
	local willDid = event.phase
	if(willDid=="will")then
		self:willExit(event)
	elseif(willDid=="did")then
		self:didExit(event)
	end
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
return scene