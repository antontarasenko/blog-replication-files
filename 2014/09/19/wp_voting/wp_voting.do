import delimited "aft4.tsv", rowrange(1:12e6) clear

drop page_title page_namespace

label define anon 0 "Anonymous" 1 "Registered user"
lab values user_id anon

so timestamp 
gen n = _n

destring rating_value rating_key, replace force
drop if !inrange(rating_value, 0, 5)
drop if !inrange(rating_key, 1, 4)
g pid = timestamp + string(page_id, "%12.0g") + string(rev_id, "%12.0g")
g date = date(timestamp, "YMD#")      
format date %td
drop timestamp page_id rev_id
drop if !inrange(date, mdy(1,1,2010), mdy(1,1,2014))

save aft4_temp, replace


collapse (count) n, by(user_id rating_value)

gr bar (sum) n if user_id == 0, name("votes_anon_all", replace) title("Voting by anonymous users on Wikipedia") over(rating_value)
gr bar (sum) n if user_id == 1, name("votes_reg_all", replace) title("Voting by registered users on Wikipedia") over(rating_value)
graph combine votes_reg votes_anon, name("votes_combined_all", replace)

gr bar (sum) n if user_id == 0 & rating_value > 0, name("votes_anon", replace) title("Voting by anonymous users on Wikipedia") over(rating_value)
gr bar (sum) n if user_id == 1 & rating_value > 0, name("votes_reg", replace) title("Voting by registered users on Wikipedia") over(rating_value)
graph combine votes_reg votes_anon, name("votes_combined", replace)

clear


use aft4_temp

collapse (mean) rating_value, by(date)
tsset date
tsline rating_value, name("rating_value_by_date", replace)

clear


/* Corr across ratings */

use aft4_temp

drop n
collapse (mean) rating_value, by(pid rating_key)
reshape wide rating_value, i(pid) j(rating_key)

rename rating_value1 trustworthy
rename rating_value2 objective
rename rating_value3 complete
rename rating_value4 well_written

n: summarize trustworthy-well_written

n: corr trustworthy-well_written
