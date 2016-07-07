--
-- Project: miners2.lua
-- Description: 
--
-- Version: 1.0
-- Managed with http://CoronaProjectManager.com
--
-- Copyright 2015 Paul Graham. All Rights Reserved.
-- 
function scores()
		for i=0,9 do
			--print(i)
			numNums=numNums+1
			img = "numbers/"..numNums..".png"
			--print(img)
			numTable[numNums]=display.newImage(gameGroup,img)
			if (i==0) then
				print("yes")
				numTable[numNums].x = w/8
			else
				numTable[numNums].x = numTable[numNums-1].x + 40
			end
			numTable[numNums].y = h/2
		endend