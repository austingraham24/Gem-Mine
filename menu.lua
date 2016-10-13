--
-- Project: main.lua
-- Description: 
--
-- Version: 1.0
-- Managed with http://CoronaProjectManager.com
--
-- Copyright 2015 Austin Graham. All Rights Reserved.
-- 

display.setStatusBar( display.HiddenStatusBar )
local composer = require "composer" 
local scene = composer.newScene()
score = 0--500 -- 1000000000
function scene:create ( event )
	w = display.contentWidth
	h = display.contentHeight
	local menu_group = self.view
	local helpGroup=display.newGroup()
	helpGroup.alpha=0
	menu_group:insert(helpGroup)

	local cover = display.newImage(menu_group,"images/topCover.jpg")
	cover.x=w/2
	cover.y=-1*(cover.height/2)
	local darkness = display.newImage(menu_group,"cover.png")
	darkness.x = w/2
	darkness.y = h/2

	local bg = display.newImage(menu_group,"images/rockBackground.jpg")
	bg.x = w/2
	bg.y = h/2--h-bg.height/2
	bg.rotation=180
	bg:toBack()
	bg:scale(1.5,1.5) -- Mac only
	
	logo = display.newImage(menu_group,"logo3.png")
	logo.x = w/2
	logo.y = 300
	--logo:scale(.6,.6)

	local newRail=display.newImage(menu_group,"images/newTrack.png")
	newRail.x=w/2
	newRail.anchorY=0
	newRail.y=h-12

	local cart = display.newImage(menu_group,"Cart.png")
	cart.y = h-108
	cart2 = display.newImage(menu_group,"Cart2.png")
	cart2.y = h-108
	cart.x = -(cart.width)
	cart2.x =w+cart.width 
	
	--the three main buttons
	local play_button = display.newImage(menu_group,"play.png")
	play_button.x = w/2
	play_button.y = h/2+130
	play_button:scale(.8,.8)
	
	local about = display.newImage(menu_group,"about.png")
	about.x = w/5
	about.y = h/2+180
	about:scale(.75,.75)
	
	local levels = display.newImage(menu_group,"levels.png")
	levels.x = w*4/5
	levels.y = h/2+180
	levels:scale(.75,.75)
	
	--old credits
	--local auth =  display.newText(menu_group,"By Austin Graham and Katey Bluel", 0, 0, nil, 36)
	--auth.x = w/2
	--auth.y = h - 50

	--help icon, group and controls
	local helpIcon = display.newImage(menu_group,"images/help.png")
	helpIcon.x = w-50
	helpIcon.y = 50

	local instructions = display.newImage(helpGroup,"images/instructions.png")
	instructions.x = w/2
	instructions.y = h/2

	local confirm = display.newImage(helpGroup,"images/gotIt.png")
	confirm.anchorY = 0
	confirm.x = w/2
	confirm.y = (h/2)+(instructions.height/2)+5

	--background game audio
	bkgAudio = audio.loadSound("sounds/Mine-Theme.mp3")
	local roll = audio.loadSound("sounds/roll.mp3")
	--audio.setVolume( 1)
	if mute==false then
		audio.fade( { channel=1, time=1000, volume=1 } )
		audio.fade( { channel=2, time=1000, volume=1 } )
		--print(audio.getDuration(roll))
		--print(audio.getVolume({channel=3}))
		if (audio.getVolume({channel=3})==.3)then
			audio.fade( { channel=3, time=3000, volume=1 } )
		elseif (audio.getVolume({channel=3})==1)then
			background = audio.play(bkgAudio,{ channel=3, loops=-1, fadein=3000 })
		else
			audio.fade( { channel=3, time=3000, volume=1 } )
		end
	--print(audio.getVolume({channel=3}))
	end

	--menu is a boolean true if on menu, false if leaving (stops the rolling carts)
	local menu = true
	--changes based on menu button tapped
	local next_scene=""
	--which cart to roll: empty/full; used in cart_decide to alternate carts
	local cart_num=1

	--audio.dispose(roll1)
	--audio.dispose(roll2)
	--roll1:removeSelf()
	--roll2:removeSelf()
	
	--adds listeners and starts dynamic menu
	function activate()
		play_button:addEventListener("tap", go_play)
		about:addEventListener("tap", go_about)
		levels:addEventListener("tap", go_levels)
		helpIcon:addEventListener("tap", enterHelp)
		confirm:addEventListener("tap",leaveHelp)
		composer.removeHidden()
	end

	--help functions
	function enterHelp()
		play_button:removeEventListener("tap", go_play)
		about:removeEventListener("tap", go_about)
		levels:removeEventListener("tap", go_levels)
		helpGroup:toFront()
		transition.to(helpGroup,{time=500,alpha=1})
		transition.to(helpIcon,{time=500,alpha=0})
	end

	function leaveHelp()
		transition.to(helpGroup,{time=500,alpha=0})
		transition.to(helpIcon,{time=500,alpha=1})
		play_button:addEventListener("tap", go_play)
		about:addEventListener("tap", go_about)
		levels:addEventListener("tap", go_levels)
	end
	
	--alternates rolling mine cars across the screen
	function cart_decide()
		if menu == true then
			if cart_num==1 then
				cart_num=2
				cart.x = -cart.width
				roll1 = audio.play(roll,{channel=1})

				transition.to(cart,{time = 2800, x=w+cart.width})
				timer.performWithDelay ( 4000, cart_decide)
			else
				cart_num=1
				cart2.x =w+cart2.width
				roll2 = audio.play(roll,{channel=2})

				transition.to(cart2,{time = 3690, x=-cart.width})
				timer.performWithDelay ( 6000, cart_decide)
			end

		end
	end

	
	--default starts the player on level 1
	function go_play()
		menu = false
		play_button:removeEventListener("tap", go_play)
		next_scene = "miners"
		play_end = display.newImage(menu_group,"play_active.png")
		play_end.x = w/2
		play_end.y = h/2+130
		play_end:scale(.8,.8)
		play_end.alpha = 0

		transition.to(play_end,{time = 500, alpha = 1})
		transition.to(about,{time = 500, alpha = 0})
		transition.to(levels,{time = 500, alpha = 0})
		transition.to(play_button,{time = 500, alpha = 0})
		--transition.to(menuGroup,{time = 500, alpha = 0})
		timer.performWithDelay ( 900, change_scene)
	end
	
	--goes to about page
	function go_about()
		menu = false
		about:removeEventListener("tap", go_about)
		next_scene = "about"
		play_end = display.newImage(menu_group,"play_active.png")
		play_end.x = w/5
		play_end.y = h/2+180
		play_end:scale(.75,.75)
		play_end.alpha = 0
		transition.to(play_end,{time = 500, alpha = 1})
		transition.to(about,{time = 500, alpha = 0})
		transition.to(levels,{time = 500, alpha = 0})
		transition.to(play_button,{time = 500, alpha = 0})
		--transition.to(menu_group,{time = 500, alpha = 0})
		timer.performWithDelay ( 600, change_scene)
	end
	
	--goes to levels page
	function go_levels()
		menu = false
		levels:removeEventListener("tap", go_levels)
		next_scene = "levels"
		play_end = display.newImage(menu_group,"play_active.png")
		play_end.x = levels.x
		play_end.y =levels.y
		play_end:scale(.75,.75)
		play_end.alpha = 0
		transition.to(play_end,{time = 500, alpha = 1})
		transition.to(about,{time = 500, alpha = 0})
		transition.to(levels,{time = 500, alpha = 0})
		transition.to(play_button,{time = 500, alpha = 0})
		--transition.to(menu_group,{time = 500, alpha = 0})
		timer.performWithDelay ( 600, change_scene)
	end

	
	--the actual function to change the scenes based on the previous three functions.
	function change_scene()
		play_button:removeEventListener("tap", go_play)
		about:removeEventListener("tap", go_about)
		levels:removeEventListener("tap", go_levels)
		--transition.to(play_end,{time = 500, alpha = 0})
		if(next_scene=="about")then
			composer.gotoScene("about","crossFade",1000)
		elseif (next_scene =="levels")then
			composer.gotoScene("levels","fade",1000)
		elseif (next_scene =="miners")then
			composer.gotoScene("tutorial","crossFade",1000)
		end
	end
	
	function noSound()
		audio.setVolume(0)
		mute=true
	end
	
	function sound()
		audio.setVolume(1)
		mute=false
	end

	timer.performWithDelay ( 1000, activate)
	timer.performWithDelay (1000,cart_decide)

end


function scene:show(event) 
	local menu_group = self.view 
	transition.to(menu_group,{time = 500, alpha = 1})

end
function scene:hide(event) 
	local menu_group = self.view 

end
function scene:destroy(event) 
	local menu_group = self.view 
	menu_group:removeSelf()
end
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene
