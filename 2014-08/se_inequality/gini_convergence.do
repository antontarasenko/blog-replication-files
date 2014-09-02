import delimited "reputation_sample.csv", varnames(1) clear

while _N > 20 {
	sample 90
	fastgini upvotes
	n: di (string(r(gini)) + "     | " + string(_N))
}
