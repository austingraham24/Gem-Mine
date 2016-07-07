--
-- Project: Jewel Mine
-- Description: 
--
-- Version: 1.0
-- Managed with http://CoronaProjectManager.com
--
-- Copyright 2015 Austin Graham. All Rights Reserved.
-- 

local composer = require "composer" 
local scene = composer.newScene()
function scene:create ( event )
	local settingsGroup = self.view
	
	--lev_# is the correlating mine car of that level to rol in
	
	local bg = display.newImage(settingsGroup,"levels_bg.png")
	bg.x = w/2
	bg.y = h/2
	local lev_1 = display.newImage(settingsGroup,"level_1.png")
	lev_1.x=w/4 + 1000
	lev_1.y=h/8
	local lev_2=display.newImage(settingsGroup,"level_2.png")
	lev_2.x=w*3/4 + 500
	lev_2.y=h/8
	local lev_3=display.newImage(settingsGroup,"level_3.png")
	lev_3.x=w/4 - 500
	lev_3.y=h*3/8
	local lev_4=display.newImage(settingsGroup,"level_4.png")
	lev_4.x=w*3/4-1000
	lev_4.y=h*3/8
	
	local appleUpper=display.newImage(settingsGroup,"apple_upper.png")
	appleUpper.x=w/4
	appleUpper.y=h*5/8 + 20
	appleUpper.alpha=0
	local appleLower=display.newImage(settingsGroup,"apple_lower.png")
	appleLower.x=w/4 + 20
	appleLower.y=h*5/8
	appleLower.alpha=0
	
	local lev_5 = display.newImage(settingsGroup,"level_5.png")
	lev_5.x=w/4 + 1000
	lev_5.y=h*5/8
	menu = display.newImage(settingsGroup,"menu_cart.png")
	menu.y = h*5/8
	menu.x =w*3/4+500
	--menu:scale(.8,.8)
	--menu.alpha=0
	--local cover =  display.newImage(settingsGroup,"levels-cover.png")
	--cover.x = w/2
	--cover.y = h/2
	audio.fade( { channel=3, time=3000, volume=.5 } )
	
	--to be changed based on the level tapped
	local sceneName=""
	
	function activate()
		if _G.adsAvailable then
			_G.showAd("banner",0,h-60)
		end
		timer.performWithDelay ( 500, roll1)
		composer.removeHidden()
	end

	--roll____ rolls in the corresponding car	and calls the next car part way through
	function roll1()
		transition.to(lev_1,{time=2500, x = w/4, transition=easing.outQuad})
		timer.performWithDelay ( 1000,roll2)
	end
	
	function roll2()
		transition.to(lev_2,{time=2500, x = w*3/4, transition=easing.outQuad})
		timer.performWithDelay ( 1000,roll4)
	end
	
	function roll3()
		transition.to(lev_3,{time=2500, x = w/4, transition=easing.outQuad})
		timer.performWithDelay ( 1000,roll5)
	end
	
	function roll4()
		transition.to(lev_4,{time=2500, x = w*3/4, transition=easing.outQuad})
		timer.performWithDelay ( 1000,roll3)
	end
	
	function roll5()
		transition.to(lev_5,{time=2500, x = w/4, transition=easing.outQuad})
		timer.performWithDelay ( 1000,rollMenu)
	end
	
	function rollMenu()
		transition.to(menu,{time=2500, x = w*3/4, transition=easing.outQuad, onComplete=apples})
	end
	
	--a finishing touch to the level 5 cart, also adds event listeners to all cars
	function apples()
		appleUpper.alpha=1
		appleLower.alpha=1
		transition.to(appleUpper,{time=500,y=appleUpper.y-20})
		transition.to(appleLower,{time=500,x=appleLower.x-20})
		lev_5:addEventListener("tap",level5)
		lev_4:addEventListener("tap",level4)
		lev_3:addEventListener("tap",level3)
		lev_2:addEventListener("tap",level2)
		lev_1:addEventListener("tap",level1)
		menu:addEventListener("tap", go_menu)
	end
	
	--the following all differ based on the car tapped. all move every other car offscreen, sets sceneName to the correct name and then calls to
	--fade the screen
	function go_menu()
		sceneName="menu"
		transition.to(lev_1,{time=2500, x = w/4 - 500, transition=easing.inOutQuad, onComplete=allButOne})
		transition.to(lev_2,{time=2500, x = w*3/4 + 500, transition=easing.inOutQuad})
		transition.to(lev_3,{time=2500, x = w/4 -500, transition=easing.inOutQuad})
		transition.to(lev_4,{time=2500, x = w*3/4+500, transition=easing.inOutQuad})
		transition.to(lev_5,{time=2500, x = w/4 - 500, transition=easing.inOutQuad})
		transition.to(appleUpper,{time=500,alpha=0})
		transition.to(appleLower,{time=500,alpha=0})
	end
	
	function level1()
		sceneName="miners1"
		transition.to(lev_2,{time=2500, x = w*3/4 + 500, transition=easing.inOutQuad})
		transition.to(lev_3,{time=2500, x = w/4 -500, transition=easing.inOutQuad})
		transition.to(lev_4,{time=2500, x = w*3/4+500, transition=easing.inOutQuad, onComplete=allButOne})
		transition.to(lev_5,{time=2500, x = w/4 - 500, transition=easing.inOutQuad})
		transition.to(menu,{time=2500, x = w*3/4 + 500, transition=easing.inOutQuad})
		transition.to(appleUpper,{time=500,alpha=0})
		transition.to(appleLower,{time=500,alpha=0})
	end
	
	function level2()
		sceneName="miners2"
		transition.to(lev_1,{time=2500, x = w/4 - 500, transition=easing.inOutQuad, onComplete=allButOne})
		transition.to(lev_3,{time=2500, x = w/4 -500, transition=easing.inOutQuad})
		transition.to(lev_4,{time=2500, x = w*3/4+500, transition=easing.inOutQuad})
		transition.to(lev_5,{time=2500, x = w/4 - 500, transition=easing.inOutQuad})
		transition.to(menu,{time=2500, x = w*3/4 + 500, transition=easing.inOutQuad})
		transition.to(appleUpper,{time=500,alpha=0})
		transition.to(appleLower,{time=500,alpha=0})
	end
	
	function level3()
		sceneName="miners3"
		transition.to(lev_1,{time=2500, x = w/4 - 500, transition=easing.inOutQuad, onComplete=allButOne})
		transition.to(lev_2,{time=2500, x = w*3/4 + 500, transition=easing.inOutQuad})
		transition.to(lev_4,{time=2500, x = w*3/4+500, transition=easing.inOutQuad})
		transition.to(lev_5,{time=2500, x = w/4 - 500, transition=easing.inOutQuad})
		transition.to(menu,{time=2500, x = w*3/4 + 500, transition=easing.inOutQuad})
		transition.to(appleUpper,{time=500,alpha=0})
		transition.to(appleLower,{time=500,alpha=0})
	end
	
	function level4()
		sceneName="miners4"
		transition.to(lev_1,{time=2500, x = w/4 - 500, transition=easing.inOutQuad, onComplete=allButOne})
		transition.to(lev_2,{time=2500, x = w*3/4 + 500, transition=easing.inOutQuad})
		transition.to(lev_3,{time=2500, x = w/4 -500, transition=easing.inOutQuad})
		transition.to(lev_5,{time=2500, x = w/4 - 500, transition=easing.inOutQuad})
		transition.to(menu,{time=2500, x = w*3/4 + 500, transition=easing.inOutQuad})
		transition.to(appleUpper,{time=500,alpha=0})
		transition.to(appleLower,{time=500,alpha=0})
	end
	
	function level5()
		sceneName="miners5"
		transition.to(lev_1,{time=2500, x = w/4 - 500, transition=easing.inOutQuad, onComplete=allButOne})
		transition.to(lev_2,{time=2500, x = w*3/4 + 500, transition=easing.inOutQuad})
		transition.to(lev_3,{time=2500, x = w/4 -500, transition=easing.inOutQuad})
		transition.to(lev_4,{time=2500, x = w*3/4+500, transition=easing.inOutQuad})
		transition.to(menu,{time=2500, x = w*3/4 + 500, transition=easing.inOutQuad})
		transition.to(appleUpper,{time=500,y=appleUpper.y+20})
		transition.to(appleLower,{time=500,x=appleLower.x+20})
	end
	
	--fades the screen out nicely
	function allButOne()
		transition.to(settingsGroup,{time=800,alpha=0,onComplete=moveOn})
	end
	
	--goes to the correct scene
	function moveOn()
		menu:removeEventListener("tap", go_menu)
		lev_1:removeEventListener("tap",level1)
		lev_2:removeEventListener("tap",level2)
		lev_3:removeEventListener("tap",level3)
		lev_4:removeEventListener("tap",level4)
		lev_5:removeEventListener("tap",level5)
		--composer.gotoScene("menu","fade",500)
		if _G.adsAvailable then
			_G.hideAd()
		end
		composer.gotoScene(sceneName,"fade",500)
	end

	timer.performWithDelay ( 1000, activate)
end

function scene:show(event) 
	local settingsGroup = self.view

end
function scene:hide(event) 
	local settingsGroup = self.view 

end
function scene:destroy(event)
	--local about_group=self.view
end
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene