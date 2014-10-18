import delimited "../../../../2014/08/investing_risks/cb_companies.csv", varnames(1) clear

g n = 1
lab var n "Startups"
destring funding_total_usd, force replace

collapse (count) n (sum) funding_total_usd, by(market founded_year)
drop if founded_year == .
bysort market: egen n_total = total(n)

encode(market), g(mid)
tsset mid founded_year

gr hbar (sum) n if n_total > 500, name(startups_over_500, replace) over(market, sort((sum) n) desc) title("The Number of Startups by Industry") note("Data source: CrunchBase") yla(, ang(h))
tsline n if tin(2000, 2013) & n_total > 500, name(startups_ts_by_market, replace) by(market, com title("The Number of New Startups by Market") note("Data source: CrunchBase")) yla(, ang(h))
tsline funding_total_usd if tin(2000, 2013) & n_total > 500, name(funding_ts_by_market, replace) by(market, com title("Total Funding by Market") note("Data source: CrunchBase")) yla(, ang(h))
