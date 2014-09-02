/*
# Get .csv on
# http://data.stackexchange.com/stackoverflow/query/219961/
*/

import delimited "voting.csv", varnames(1) clear
/* should we normalize rep? */
g rep = upvotes - downvotes 
lab var rep "Net votes"
g totalvotes = upvotes + downvotes 

fastgini upvotes 
fastgini downvotes

graph bar (asis) rep if totalvotes > 100, over(id, sort(rep) label(nolabel)) nofill title("Upvoting and downvoting on StackExchange") name("updown_total")

g lnupvotes = ln(upvotes )
g lndownvotes = ln(downvotes)
lab var lnupvotes "ln(UpVotes)"
lab var lndownvotes "ln(DownVotes)"

aaplot lnupvotes lndownvotes if totalvotes > 10, title("No bad guys") name("no_bad_guys")

/* Top 1%? */
drop if totalvotes < 10
xtile x = upvotes, n(100)
collapse (sum) upvotes, by(x)
li upvotes, clean
