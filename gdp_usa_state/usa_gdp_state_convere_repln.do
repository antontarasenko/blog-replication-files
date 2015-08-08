// 
// RUNNING ANALYSIS
// 


use usa_state_gsp_pc, clear

// SIC to NAICS data transition
tsline gsp_sic gsp_naics if geofips == 0, $grf tline(1997) ///
ti("United States: Change from SIC to NAICS in 1997") name(usa_sic_naics, replace)

// leave only states
drop if !b_state

// default GSP
glo dgsp = "gsp_naics"

// samples
gen b_year = inlist(year, 1987, 1992, 1997, 2002, 2007, 2009)
gen b_out = inlist(geoname, "District of Columbia", "Alaska", "North Dakota")
// Alaska and North Dakota because of oil; D.C. for obvious reasons
lab var b_year "Is a 6-period sample?"
lab var b_out "Is an outlier?"


/* Post-2008 convergence */

sc g5_$dgsp l_$dgsp, ml(sid) msym(none) mlabpos(0) mlabsize(vsmall) || ///
lfit g5_$dgsp l_$dgsp || ///
if year == 2009 & !b_out, $grf ///
ti("US State Convergence after 2008: 2009-2014") yti("GSP PC growth") ///
name(usa_convere_2009_2014, replace)
grex usa_convere_2009_2014

reg g5_$dgsp l_$dgsp if year == 2009 & !b_out


/* 1987-2014 convergence */

so sid year
gen g27_$dgsp = F27.$dgsp / $dgsp  - 1

outreg2 using reg_full, replace ///
title("United States GSP Convergence, 1987-2014") addnote("\emph{Source: antontarasenko.com}") ///
ctitle("All states") : ///
reg g27_$dgsp l_$dgsp if year == 1987

outreg2 using reg_full, append ///
ctitle("Excl. outliers") tex(pretty frag) label: ///
reg g27_$dgsp l_$dgsp if !b_out & year == 1987

// post-2008 convergence
sc g27_$dgsp l_$dgsp if !b_out, ml(sid) msym(none) mlabpos(0) mlabsize(vsmall) || ///
sc g27_$dgsp l_$dgsp if b_out, ml(sid) msym(none) mlabpos(0) mlabsize(vsmall) mcolor(red) || ///
lfit g27_$dgsp l_$dgsp if !b_out || ///
if year == 1987, $grf ///
ti("US State Economic Convergence, 1987-2014") name(usa_convere_1987_2014, replace) ///
yti("GSP PC growth") xti("Log of real GSP per capita in 1987")
grex usa_convere_1987_2014


/* GSP variance */

egen t_year = tag(year)
egen sd_gsp_year = sd(l_$dgsp ), by(year)
egen sd_gsp_nodoc_year = sd(l_$dgsp ) if !inlist(geoname, "District of Columbia"), by(year)
lab var sd_gsp_year "With D.C."
lab var sd_gsp_nodoc_year "Without D.C."

tsline sd_gsp_year sd_gsp_nodoc_year if t_year, $grf lw(thick ..) ///
ti("Inequality across US states") yti("St. dev. of Log GSP across states") ///
yla(0(.05).3) leg(on) ///
name(sd_usa_gsp_ts, replace)
grex sd_usa_gsp_ts


/* Tables for 6 periods */

keep if b_year

sc g5_$dgsp l_$dgsp, ml(sid) msym(none) mlabpos(0) mlabsize(vsmall) || ///
lfit g5_$dgsp l_$dgsp || ///
if !b_out , $grby ///
by(year, ti("Gross state product (GSP) convergence by year")) yti("GSP growth over the next 5 years") ///
name(gsp_convere_periods, replace)
grex gsp_convere_periods 1800 1350

// formally
lab var g5_$dgsp ""

bys year : ///
outreg2 using reg_noout_period, ///
label title("Real GSP per capita growth in the next five years on initial GSP") addnote("\emph{Source: antontarasenko.com}") ///
replace tex(pretty landscape frag): ///
reg g5_$dgsp l_$dgsp if !b_out


// all 50 states
bys year : ///
outreg2 using reg_state_period, ///
label title("Real GSP per capita growth in the next five years on initial GSP") addnote("\emph{Source: antontarasenko.com}") ///
replace tex(pretty landscape frag): ///
reg g5_$dgsp l_$dgsp if !inlist(geoname, "District of Columbia")
