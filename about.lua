--
-- Project: misc.lua
-- Description: 
--
-- Version: 1.0
-- Managed with http://CoronaProjectManager.com
--
-- Copyright 2014 Paul Graham. All Rights Reserved.
-- 
display.setStatusBar( display.HiddenStatusBar )
local composer = require "composer" 
local scene = composer.newScene()
function scene:create ( event )
	w = display.contentWidth
	h = display.contentHeight
	--composer.removeHidden()
	local about_group = self.view
--	gem = display.newImage(about_group,"d4.png")
--	gem.x = w/2
--	gem.y = h/3
--	gem.alpha = 0--.5

	local cover = display.newImage(about_group,"images/topCover.jpg")
	cover.x=w/2
	cover.y=-1*(cover.height/2)
	local darkness = display.newImage(about_group,"cover.png")
	darkness.x = w/2
	darkness.y = h/2
	darkness:scale(1.5,1.5)

	local bg = display.newImage(about_group,"images/rockBackground.jpg")
	bg.x = w/2
	bg.y = h/2--h-bg.height/2
	bg.rotation=180
	bg:scale(1.5,1.5)
	bg:toBack()

	-- local bannerTest= display.newImage(about_group,"images/bannerTestSmall.jpg")
	-- bannerTest.anchorX=0
	-- bannerTest.anchorY=0
	-- bannerTest.x = (w/2) - 160
 --  bannerTest.y = h-80
 --  bannerTest.alpha=0

 --  local bannerTest2= display.newImage(about_group,"bannerTest.jpg")
	-- bannerTest2.anchorX=0
	-- bannerTest2.anchorY=0
	-- bannerTest2.x = (w/2)-234
 --  bannerTest2.y = h-60
 --  bannerTest2.alpha=0


  local menu=display.newImage(about_group,"menu.png")
  menu.x = w/2
  menu.y = h*3/4
  menu:scale(.8,.8)
  menu.alpha=0

--	local inst = display.newImage(about_group,"instr.png")
--	inst.x = w/2
--	inst.y = h/2 - 50
--	inst:scale(.7,.7)
--	inst.alpha = .8
	audio.fade( { channel=3, time=3000, volume=.5 } )
	local titleGroup=display.newGroup()
	titleGroup.alpha=0
	local row1Group=display.newGroup()
	row1Group.alpha=0
	local row2Group=display.newGroup()
	row2Group.alpha=0
	local row3Group=display.newGroup()
	row3Group.alpha=0
	local row4Group=display.newGroup()
	row4Group.alpha=0
	local row5Group=display.newGroup()
	row5Group.alpha=0


	local gameItems = display.newImage(titleGroup,"gameItems.png")
	gameItems.x = w/2
	gameItems.y = 100
	gameItems:scale(1.5,1.5)
	local gems = display.newImage(titleGroup,"gemstones.png")
	gems.anchorX = 0
	gems.anchorY = 0
	gems.x = 20
	gems.y = h/8
	local power = display.newImage(titleGroup,"power-ups.png")
	power.anchorX = 0
	power.anchorY = 0
	power.x = 20
	power.y = h/3+70

	local shield1 = display.newImage(row1Group,"blue_shield.png")
	shield1.x = w/6 - 20
	shield1.y = h/2+50
	shield1.alpha = 1
	local shield2 = display.newImage(row2Group,"red_shield.png")
	shield2.x = w*2/6-10
	shield2.y =h/2+50
	shield2.alpha = 1
	local shield3 = display.newImage(row3Group,"purple_shield.png")
	shield3.x = w/2
	shield3.y = h/2+50
	shield3.alpha = 1
	local shield4 = display.newImage(row4Group,"tri_shield.png")
	shield4.x = w*4/6+15
	shield4.y = h/2+50
	shield4.alpha = 1
	
	local gem1 = display.newImage(row1Group,"blue1.png")
	gem1.x = w/6 - 20
	gem1.y = h/4+25
	gem1:scale(.7,.7)
	local gem2 = display.newImage(row2Group,"red1.png")
	gem2.x = w*2/6-10
	gem2.y = h/4+25
	gem2:scale(.7,.7)
	local gem3 = display.newImage(row3Group,"purple1.png")
	gem3.x = w/2
	gem3.y = h/4+25
	gem3:scale(.7,.7)
	local gem4 = display.newImage(row4Group,"tri1.png")
	gem4.x =w*4/6+15
	gem4.y = h/4+25
	gem4:scale(.7,.7)
	

	local heart=display.newImage(row5Group,"heart2.png")
	heart.x = w*5/6+30--w*2/6-10
	heart.y = h/2+50--h*2/3+50
	heart:scale(1.5,1.5)
	
	local greenGem = display.newImage(row5Group, "crystal1.png")
	greenGem.x=w*5/6+30
	greenGem.y=h/4+25
	--greenGem:scale(.3,.3)
	local function load_buttons()
		transition.to(menu,{time=500, alpha=1})

	end
	
	local function load_display5()
		transition.to(row5Group,{time=500, alpha=1, onComplete=load_buttons})
	end
	
	local function load_display4()
		transition.to(row4Group,{time=500, alpha=1, onComplete=load_display5})
	end
	
	local function load_display3()
		transition.to(row3Group,{time=500, alpha=1,onComplete=load_display4})
	end
	
	local function load_display2()
		transition.to(row2Group,{time=500, alpha=1,onComplete=load_display3})
	end
	
	local function load_display1()
		transition.to(row1Group,{time=500, alpha=1,onComplete=load_display2})

	end
	local function load_display()
		transition.to(titleGroup,{time=500, alpha=1,onComplete=load_display1})
		--transition.to(bannerTest,{time=500, alpha=1})
		--transition.to(bannerTest2,{time=500, alpha=1})

	end
	function go_menu()
		if _G.adsAvailable then
			_G.hideAd()
		end
		menu:removeEventListener("tap", go_menu)
		titleGroup:removeSelf()
		row1Group:removeSelf()
		row2Group:removeSelf()
		row3Group:removeSelf()
		row4Group:removeSelf()
		row5Group:removeSelf()
		menu:removeSelf()

		composer.gotoScene("menu","fade",800)
	end
	
	function fade_menu()
		transition.to(titleGroup,{time=500,alpha=0,onComplete=go_menu})
		transition.to(row1Group,{time=500,alpha=0})
		transition.to(row2Group,{time=500,alpha=0})
		transition.to(row3Group,{time=500,alpha=0})
		transition.to(row4Group,{time=500,alpha=0})
		transition.to(row5Group,{time=500,alpha=0})
		transition.to(menu,{time=500,alpha=0})

	end
	
	local function activate()
		--menu:addEventListener("tap", go_menu)
		--[[if _G.adsAvailable then
			_G.showAd("banner",0,h-60)
		end]]
		timer.performWithDelay ( 500, load_display)
		composer.removeHidden()
	end
	menu:addEventListener("tap",fade_menu)
	timer.performWithDelay ( 1000, activate)

end
function scene:show(event) 
	local about_group = self.view 

end
function scene:hide(event) 
	local about_group = self.view 

end
function scene:destroy(event)
	local about_group=self.view
end
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene