/*
# Get .csv data from:
# http://data.stackexchange.com/stackoverflow/query/157405/how-many-did-each-user-asked-questions-and-gave-answers
*/

import delimited "users_sample.csv", varnames(1) clear
rename posttypeid ptype
rename owneruserid user
drop userlink 
sample 5
label define D 1 "Q" 2 "A"
label values ptype D

ssc install fastgini
fastgini n if ptype == 1
fastgini n if ptype == 2

graph bar (asis) n if n > 10, over(user, sort(n) descending label(nolabel)) over(ptype) ylabel(, labsize(vsmall)) nofill
