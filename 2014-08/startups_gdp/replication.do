use "~/Google Drive/Work/Stata/pwt.dta", clear
merge m:1 iso using "/Users/Anton/Downloads/startups_by_country.dta"
g startups2pop = total_startups / pop 
label var startups2pop "startups per 1,000 inhabitants"
label var lnrgdpwok "Log of PPP GDP per worker at 2005 prices"
g lnstartups2pop = ln(startups2pop )
label var lnstartups2pop "log of startups per 1,000 inhabitants"
g gr = 1
replace gr = 2 if startups2pop > 0.02
