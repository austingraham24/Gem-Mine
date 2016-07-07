--
-- Project: Jewel Mine
-- Description: 
--
-- Version: 1.0
-- Managed with http://CoronaProjectManager.com
--
-- Copyright 2014 Paul Graham. All Rights Reserved.
-- 
score_table={}
function add_Score(score)
	print(score)
	table.insert(score_table,score)
	print(score_table[0])
end