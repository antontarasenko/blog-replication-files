import delimited "users_reputation.csv", varnames(1) clear

reshape wide n, i(userid) j(votetypeid)
rename n2 upvotes
rename n3 downvotes
lab var upvotes "upvotes"
lab var downvotes "downvotes"
g totalvotes = upvotes + downvotes 
lab var totalvotes "Total votes"
foreach i of varlist upvotes-totalvotes {
	g ln`i' = ln(`i')
	lab var ln`i' "ln(`i')"
}

n: fastgini upvotes 
n: fastgini downvotes 


gr bar (asis) upvotes if upvotes > 100, name("upvotes_inequality", replace) over(userid, sort(upvotes) label(nolabel)) nofill title("Upvotes inequality on StackExchange") subtitle("(only users with 100+ upvotes included)")
gr save upvotes_inequality upvotes_inequality.png, replace asis


# drop irregular visitors
drop if totalvotes < 10

lpoly lnupvotes lndownvotes, name("seniority_effect", replace) msize(vsmall) msymbol(point) title("Seniority effect on Stack Exchange")
gr save seniority_effect seniority_effect.png, replace asis

/* Top */
summarize upvotes, detail
return list

preserve
xtile x = upvotes, n(10)
li, clean
restore

preserve
xtile x = upvotes, n(100)
collapse (sum) upvotes , by(x)
so x
li x upvotes in -10/l, clean
summarize upvotes, detail
restore

/* Top 0.1% */

preserve
xtile x = upvotes, n(1000)
collapse (sum) upvotes , by(x)
so x
li x upvotes in -10/l, clean
summarize upvotes, detail
restore
