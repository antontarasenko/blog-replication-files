import excel "competitions.xlsx", sheet("combined") firstrow clear
/* Merk uses R^2 for ranking */
replace result = 1 - result if competition == "merk"
sort competition result 
by competition: g rel_dist = ( result / result[1] - 1 ) * 100
by competition: g rank = _n
lab var rel_dist "Relative distance from the first place, %"
graph bar (asis) rel_dist if rank <= 20 & competition != "math", name("athletes_vs_data_scis", replace) /* title("Competition among athletes and data scientists") */ over(rank, sort(rank) label(labsize(vsmall))) ylabel(, angle(horizontal)) by(competition) nofill
