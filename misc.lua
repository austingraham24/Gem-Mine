--
-- Project: menu.lua
-- Description: 
--
-- Version: 1.0
-- Managed with http://CoronaProjectManager.com
--
-- Copyright 2014 Paul Graham. All Rights Reserved.
-- 
local physics = require("physics")
physics.start()
physics.setGravity(0,0)

display.setStatusBar( display.HiddenStatusBar )
w = display.contentWidth
h = display.contentHeight
bg = display.newImage("rockwall2.jpg")
bg.x = w/2
bg.y = h-bg.height/2
logo=display.newImage("logo.jpg")
logo.x = w/2
logo.y = 400
rail = display.newImage("rail2.jpg")
rail.x = w/2
rail.y = h-rail.height/2
--cart = display.newImage("Cart.png")
--cart.x = w/2
--cart.y = h-108
--physics.addBody (cart, {density=1.0, friction = 0.3, bounce=1.0})
cart = display.newImage("Cart.png")

cart.y = h-108
cart2 = display.newImage("Cart2.png")

cart2.y = h-108
cart.x = -(cart.width)
cart2.x =w+cart.width 
menu = true
cart_num=1

function cart_decide(cart)
	if menu == true then
		if cart_num==1 then
			cart_num=2
			cart_empty()
		else
			cart_num=1
			cart_full()
		end
	end
end
function cart_empty()
	cart.x = -cart.width

	transition.to(cart,{time = 1800, x=w+cart.width})
	timer.performWithDelay ( 3000, cart_decide)
end
function cart_full()
	print(cart2.x)
	cart2.x =w+cart2.width
	transition.to(cart2,{time = 5000, x=-cart.width})
	timer.performWithDelay ( 6000, cart_decide)
end
function end_menu()
	menu = false
	--transition.to(cart,{time = 500, alpha = 0})
	--transition.to(cart2,{time = 500, alpha = 0})
end
logo:addEventListener("tap", end_menu)
cart_full()
local function startDrag( event )
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

--cart:addEventListener("touch", startDrag)