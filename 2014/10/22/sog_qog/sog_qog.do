/* qog_ts.dta from http://www.qog.pol.gu.se/data/datadownloads/ */

use qog_ts, clear

g ln_pwt_rgdpch = ln(pwt_rgdpch)

sc pwt_rgdpch fi_sog, ml(year) msize(tiny) mlabpos(6) || line pwt_rgdpch fi_sog || if ccodealp=="USA", name(gdp_sog_usa, replace) title("Size of the government vs output per capita" "United States, 1970-2010", ) ysc(log) yla(, ang(h)) leg(off)
gr export gdp_sog_usa.png, wid(800) hei(600) replace


keep if year==2010


reg ln_pwt_rgdpch fi_sog
predict yhat
g fitted_values = exp(yhat)

sc pwt_rgdpch fi_sog, ml(ccodealp) msym(none) mlabpos(0) msize(tiny) || sc fitted_values fi_sog, name(gdp_sog, replace) title("Size of the government vs output per capita, 2010") ysc(log) yla(, ang(h))
gr export gdp_sog.png, wid(800) hei(600) replace


g level="1 low"
replace level="2 lower-middle" if pwt_rgdpch>1045
replace level="3 upper-middle" if pwt_rgdpch>4125
replace level="4 high" if pwt_rgdpch>12746

sc pwt_rgdpch fi_sog, ml(ccodealp) msym(none) mlabpos(0) msize(tiny) || lfit pwt_rgdpch fi_sog, name(gdp_sog_by_level, replace) ysc(log) yla(, ang(h)) by(level, r(1) title("Size of the government vs output per capita by output, 2010"))
gr export gdp_sog_by_level.png, wid(800) hei(600) replace

bysort level: reg ln_pwt_rgdpch fi_sog


drop fitted_values yhat
reg ln_pwt_rgdpch icrg_qog
predict yhat
g fitted_values = exp(yhat)

sc pwt_rgdpch icrg_qog, ml(ccodealp) msym(none) mlabpos(0) msize(tiny) || sc fitted_values icrg_qog, name(gdp_qog, replace) title("Quality of government vs output per capita, 2010") ysc(log) yla(, ang(h))
gr export gdp_qog.png, wid(800) hei(600) replace
