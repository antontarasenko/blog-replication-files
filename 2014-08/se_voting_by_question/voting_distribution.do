/* Data from: http://data.stackexchange.com/stackoverflow/query/220753/upvotes-and-downvotes-for-answers-per-question */

import delimited "votes_by_answer.csv", varnames(1) clear
rename questionid q
rename answerid a
drop postlink 
codebook n if votetypeid == .
replace votetypeid = 0 if votetypeid == .
reshape wide n, i(q a) j(votetypeid)
rename n0 no_votes
rename n2 uv
rename n3 dv
replace uv = 0 if no_votes == 1
replace dv = 0 if no_votes == 1
drop no_votes 

replace uv = 0 if uv == .
replace dv = 0 if dv == .
g net = uv - dv

lab var uv "Upvotes"
lab var dv "Downvotes"
lab var net "Upvotes - Downvotes"


gsort q -net
by q: g pos = _n
lab var pos "Position in the list of answers"

sort q a
by q: g total_a = _N
lab var total_a "Total number of answers to a question"
g rel_pos = pos / total_a
lab var rel_pos "Relative position of the answer"

egen total_uv_by_q = total(uv), by(q)
g frac_uv = uv / total_uv_by_q
lab var total_uv_by_q "Total upvotes in a question"
lab var frac_uv "The answer's fraction of upvotes in a question"

egen total_net_by_q = total(net), by(q)
g frac_net = net / total_net_by_q
drop total_net_by_q 
lab var frac_net "The answer's fraction of net votes to total net votes in a question"

n: summarize uv-frac_net

glo gr_bar_over = ", label(nolabel)"

preserve 
collapse (count) a, by(q)
n: tabulate a 
lab var a "Number of answers to a question"
histogram a, name("count_a_by_q", replace) discrete width(1) xscale(range(1 25))
restore

preserve
drop if total_a > 16
gr bar (mean) frac_uv, name("mean_frac_uv_over_pos_by_total_a", replace) over(pos $gr_bar_over) by(total_a)
gr bar (mean) uv, name("mean_uv_over_pos_by_total_a", replace) over(pos $gr_bar_over) by(total_a)
restore

/* 
gr bar (mean) net, name(mean_net_over_pos, replace) over(pos $gr_bar_over) nofill
gr bar (mean) frac_net, name(mean_frac_net_over_pos, replace) over(pos $gr_bar_over)
gr bar (mean) net, name(mean_net_over_rel_pos, replace) over(rel_pos $gr_bar_over)
gr bar (mean) frac_net, name(mean_frac_net_over_rel_pos, replace) over(rel_pos $gr_bar_over)
*/
