// Kaggle
// https://www.kaggle.com/c/leapfrogging-leaderboards/data

cd "input"

clear
local csvfiles: dir "ALL_LEADERBOARDS" files "*.csv"

foreach file of local csvfiles {
	preserve
	insheet using ALL_LEADERBOARDS/`file', clear
	gen source = "`file'"
	save temp, replace
	restore
	append using temp
}

rm temp.dta // remove temporary .dta file
save leaderboards, replace

import delimited "teams.csv", clear
drop requestdate 
save teams, replace

cd ..

