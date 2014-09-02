clear
graph drop funding acq2clo
import delimited "/Users/Anton/Downloads/cb/cb_companies.csv", varnames(1) clear
g is_acquired = 0
replace is_acquired = 1 if status=="acquired"
g is_closed = 0
replace is_closed = 1 if status=="closed"
sort market
by market: g market_N=_N
by market: egen market_mean=mean(funding_total_usd)
by market: egen acq = total(is_acquired )
by market: egen clo = total(is_closed  )
g acq2clo = acq/clo
graph hbar (mean) funding_total_usd if market_N > 500, over(market, sort(market_mean) descending) name("funding")
graph hbar (mean) acq2clo if market_N > 500, over(market, sort(acq2clo) descending) name("acq2clo")
graph combine funding acq2clo, title("Investing and failures") note("Data source: CrunchBase.com. Calculations: atonbs.blogspot.com")
