--
-- Project: Jewel Mine
-- Description: 
--
-- Version: 1.0
-- Managed with http://CoronaProjectManager.com
--
-- Copyright 2014 Austin Graham & Katey Bluel. All Rights Reserved.
-- 

display.setStatusBar( display.HiddenStatusBar )
local composer = require "composer"
w = display.contentWidth
h = display.contentHeight
print(w,h)

score =0
mute=false

--_G.ads = require "ads"
--_G.showAd=""
--_G.adsAvailable=""
--_G.hideAd=""

_G.coronaAds = require( "plugin.coronaAds" )
_G.bannerPlacement = "bottom-banner-320x50"
_G.interstitialPlacement = "interstitial-1"
_G.adListener=""

_G.adListener = function( event )

         -- Successful initialization of Corona Ads
         if ( event.phase == "init" ) then
           -- Show an ad
           coronaAds.show( bannerPlacement, false )
           --coronaAds.show( interstitialPlacement, true ) -- second arg i for y/n button
         end
     end

_G.coronaAds.init( "cf57ca56-eb84-4877-9a7e-133d1c1f51dd", _G.adListener )

--setting up ads
--[[adListener=function(event)
	if event.isError then
		print("Error Loading Ad")
		adsAvailable=0
	else
		adsAvailable=1
	end
end

showAd = function(adType,newX,newY)
	local adX,adY = newX,newY
	if adsAvailable then
		ads.show("banner",{x=adX,y=adY,isAnimated=false})
	end
end

ads.init("admob","ca-app-pub-5699344652048896/2960842560", adListener) --starts the system

hideAd=function()
	ads.hide()
end

showAd() --preload an ad
hideAd()]]--

--handling splash screen and going to menu
function main()
	--logo=display.newImage("logo.jpg")
	logo = display.newImage("cave.png")
	logo.x = w/2
	logo.y = 400
	logo:scale(.8,.8)
	logo.alpha = 0
	timer.performWithDelay ( 500, fade_in)
end

function fade_in()
	transition.to(logo,{time=1000, alpha = 1})
	timer.performWithDelay ( 1800, fade_out)
end

function fade_out()
	transition.to(logo,{time=800, alpha = 0})
	timer.performWithDelay ( 800, change_scene)
end

function change_scene()
	logo:removeSelf()
	--composer.gotoScene( "miners5","fade", 500 )
	composer.gotoScene( "menu","crossFade", 700 )
end
main()
--timer.performWithDelay ( 500, change_scene)
