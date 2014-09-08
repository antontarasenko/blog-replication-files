import delimited "../../2014-08/investing_risks/cb_companies.csv", varnames(1) clear
g id = 1
collapse (count) id, by(country_code funding_rounds)
lab var id "Total number of startups"
bysort country_code : egen country_total = total(id)

gr bar (asis) id if country_total > 500 & funding_rounds < 6 & !inlist(country_code, "USA", "GBR"), name("total_by_funding_country", replace) over(funding_rounds) by(country_code, title("The number of startups by funding stage and country"))
gr bar (asis) id if country_total > 500 & funding_rounds < 6 & inlist(country_code, "USA", "GBR"), name("total_by_funding_country_usa_gbr", replace) over(funding_rounds) by(country_code, title("The number of startups by funding stage and country"))
