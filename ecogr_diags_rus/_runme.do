// 
// 
// Growth Diagnostics: Russia
// 
// 

/* 

NOTE: This file requires several datasets (PWT8, QoG, et al.).
Please, email to antontarasenko@gmail.com if you want all the replication files.

Instructions for replications

1. Create directory "o" in "ecogr_diags_rus"
2. Change parameters below
3. Run this file

*/

// Path to the working directory "ecogr_diags_rus"
cd "../ecogr_diags_rus"


// Parameters
glo gdc = "RUS" // can specify any country, but some graphs won't change
glo gdn = "Russia" // shortcut name for the country
glo gdi = "$dd" // input (data) directory



// 
// Part 2
// Recent growth
// 


/* Historical, Markevich */

use $gdi/rusgdp, clear

reg lgdp year
tsline lgdp || lfit lgdp year, ///
ti("Russia: Long-Term Growth") yti("Log of Index, 1913 = 4.6 = ln(100)") $gbl ///
xla(1885(15)2015) ///
name(rus_gdppc_1885, replace)
grex o/rus_gdppc_1885


/* Modern, PWT 8.1 */

use $gdi/pwt8, clear

egen t10_gdppc_y = xtile(gdppc), by(year) p(10(10)90)
egen a_g_gdppc_y = mean(g_gdppc), by(year t10_gdppc_y)
lab var g_gdppc "Growth of Real GDP per Capita, PPP"
lab var a_g_gdppc_y "Average growth in the same GDPPC decile, by year"


sort year t10_gdppc_y g_gdppc
by year t10_gdppc_y : gen t10_rank_y = _N - _n + 1
li year t10_rank_y if c == "$gdn" & !missing(t10_gdppc_y)


tsline g_gdppc a_g_gdppc_y if c == "$gdc" & !missing(g_gdppc), ///
ti("$gdn and the Peers") yti("Rate of growth") $gbl ///
name(gdc_decile_ts, replace)
grex o/gdc_decile_ts


egen fsu_gdppc_y = mean(gdppc) if fsu, by(year)
lab var fsu_gdppc_y "Average GDP PC in the former Soviet republics"
tsline gdppc fsu_gdppc_y if c == "$gdc" & !missing(gdppc), ///
ti("$gdn and the former Soviet Union") yti("GDP per capita") $gbl ///
yla(0(4000)16000) ///
name(gdc_fsu_ts, replace)
grex o/gdc_fsu_ts


xtline rkna2emp if inlist(c, "$gdc", "USA") & year >= 1990, ov ///
ti("$gdn: Capital per worker") yti("Capital stock per capita, 2005 USD") $gbl ///
yla(0(5e4)30e4) ///
name(gdc_rkna2emp_ts, replace)
grex o/gdc_rkna2emp_ts

so cid year
tw connected rkna2emp rkna if c == "$gdc" & y > 1990, ml(y) mlabpos(12) ///
ti("$gdn: Capital Stock and Capital per Worker") yti("Capital per worker") $gbl ///
name(gdc_rkna2emp_rkna, replace)
grex o/gdc_rkna2emp_rkna



// 
// Part 3
// Finance or Returns?
// 


/* Prepare data */

use $gdi/pwt7, clear

mer 1:1 c y using $dd/wdigi, nogen
drop if missing(c, y)
drop cid
encode country, gen(cid)
duplicates tag c y, gen(isdup)
drop isdup 
// xtset cid year

clonevar S = NY_GDS_TOTL_ZS // Savings % of GDP
clonevar I = ki // Investment % of GDP
clonevar CA = BN_CAB_XOKA_GD_ZS // Current account
clonevar IR = FR_INR_LEND // "Interest rate"


/* Feldstein-Horioka test (FHT) */

gen d_S_I = S - I
reg d_S_I CA if c == "$gdc" // Current account identity test for consistency

// Don't take the following three lines seriously
reg I S if g7, vce(cl cid) // FHT for G7
reg I S if oecd & y == 2005 // FHT for OECD
reg I S if c == "$gdc" // FHT for $gdc


/* Plots */

// Savings, investmetns
tsline I S if c == "$gdc" & !missing(I, S), ///
ti("$gdn: Savings and investments") $gbl ///
name(gdc_si_ts, replace)
grex o/gdc_si_ts

hist S if y == 2011, freq ///
ti("Savings rate worldwide, 2011") $gbl ///
name(hist_savg, replace)
grex o/hist_savg


// Net interest spread
tsline FR_INR_LNDP if c == "$gdc" & y > 1998, ///
ti("$gdn: Net interest spread") $gbl ///
yla(0(5)25) ///
name(gdc_nis_ts, replace)
grex o/gdc_nis_ts


// Real interest rate
tsline FR_INR_RINR if c == "$gdc" & y > 1998, ///
ti("$gdn: Real interest rate") $gbl ///
name(gdc_rir_ts, replace)
grex o/gdc_rir_ts



// 
// Part 4
// Human capital
//


use $gdi/pwt8, clear

sc l_gdppc hc || lfit l_gdppc hc || ///
sc l_gdppc hc if c == "$gdc", ml(country) || ///
if y == 2011, ///
leg(off) ///
ti("Output and human capital, 2011") yti("Log of GDPPC") xti("Human capital index") $gbl ///
name(gdc_gdp_humca, replace)
grex o/gdc_gdp_humca



//
// Part 5
// Uncertainty, taxation, and costs
// 


use $gdi/pwt8, clear

egen sd_g_gdppc_c_91 = sd(g_gdppc) if y > 1990, by(cid)
gen l_sd_g_gdppc_c_91 = ln(sd_g_gdppc_c_91)
egen a_g_gdppc_c_91 = mean(g_gdppc) if y > 1990, by(cid)
gen g20_gdppc = gdppc / L20.gdppc
gen l_g20_gdppc = ln(g20_gdppc)
lab var l_sd_g_gdppc_c_91 "Log of st. dev. of GDPPC growth"
lab var a_g_gdppc_c_91 "Average annual growth"
lab var l_g20_gdppc "Log of GDPPC index, 20-year period"
lab var l_gdppc "Log of GDPPC"


sc l_g20_gdppc l_sd_g_gdppc_c_91 || lfit l_g20_gdppc l_sd_g_gdppc_c_91 || ///
sc l_g20_gdppc l_sd_g_gdppc_c_91 if c == "$gdc", ml(country) mlabpos(6) || ///
if y == 2011, ///
leg(off) ///
ti("Growth and volatility: Cumulative (All countries, 1991-2011)") $gbl ///
name(xxx_net_growth_volay, replace)
grex o/xxx_net_growth_volay


outreg2 using o/gdp_f_volay, ///
title("Past volatility and current performance, 1991--2011") addnote("Log of GDPPC in 2011") ///
ctitle("Full sample") replace : ///
reg l_gdppc l_sd_g_gdppc_c_91 if y == 2011

outreg2 using o/gdp_f_volay, ///
ctitle("OECD") append : ///
reg l_gdppc l_sd_g_gdppc_c_91 if oecd & y == 2011

outreg2 using o/gdp_f_volay, ///
ctitle("Former Soviet Union") append label tex(pretty frag) : ///
reg l_gdppc l_sd_g_gdppc_c_91 if fsu & y == 2011


keep if y == 1991

sc a_g_gdppc_c_91 l_sd_g_gdppc_c_91 || lfit a_g_gdppc_c_91 l_sd_g_gdppc_c_91 || ///
sc a_g_gdppc_c_91 l_sd_g_gdppc_c_91 if c == "$gdc", ml(country) mlabpos(6) || ///
, ///
leg(off) ///
ti("Growth and volatility: Average (All countries, 1991-2011)") $gbl ///
name(xxx_growth_volay, replace)
grex o/xxx_average_growth_volay


sc l_sd_g_gdppc_c_91 l_gdppc || lfit l_sd_g_gdppc_c_91 l_gdppc || ///
sc l_sd_g_gdppc_c_91 l_gdppc if c == "$gdc", ml(country) mlabpos(6) || ///
, ///
leg(off) ///
ti("Output and volatility: All countries, 1991-2011") yti("Log of st. dev. of GDPPC annual change") xti("GDPPC in 1991") $gbl ///
name(xxx_gdp_volay, replace)
grex o/xxx_gdp_volay


sc l_sd_g_gdppc_c_91 l_gdppc || lfit l_sd_g_gdppc_c_91 l_gdppc || ///
sc l_sd_g_gdppc_c_91 l_gdppc if c == "$gdc", ml(country) || ///
if oecd, ///
leg(off) ///
ti("Output and volatility: OECD countries, 1991-2011") yti("Log of st. dev. of GDPPC annual change") xti("GDPPC in 1991") $gbl ///
name(oecd_gdp_volay, replace)
grex o/oecd_gdp_volay


sc l_sd_g_gdppc_c_91 l_gdppc || lfit l_sd_g_gdppc_c_91 l_gdppc || ///
sc l_sd_g_gdppc_c_91 l_gdppc if c == "$gdc", ml(country) mlabpos(6) || ///
if fsu, ///
leg(off) ///
ti("Output and volatility: FSU countries, 1991-2011") yti("Log of st. dev. of GDPPC annual change") xti("GDPPC in 1991") $gbl ///
name(fsu_gdp_volay, replace)
grex o/fsu_gdp_volay


outreg2 using o/volay_f_gdp, ///
title("Ex-post volatility as a function of the stage of development, 1991--2011") addnote("Log of GDPPC in 1991") ///
ctitle("Full sample") replace : ///
reg l_sd_g_gdppc_c_91 l_gdppc

outreg2 using o/volay_f_gdp, ///
ctitle("OECD") append : ///
reg l_sd_g_gdppc_c_91 l_gdppc if oecd

outreg2 using o/volay_f_gdp, ///
ctitle("Former Soviet Union") append label tex(pretty frag) : ///
reg l_sd_g_gdppc_c_91 l_gdppc if fsu


outreg2 using o/growth_f_volay, ///
title("Volatility and growth, 1991--2011") addnote("\emph{Notes:} The dependent variable is the mean growth rate of GDPPC over the period.") ///
ctitle("Full sample") replace : ///
reg a_g_gdppc_c_91 l_sd_g_gdppc_c_91

outreg2 using o/growth_f_volay, ///
ctitle("OECD") append : ///
reg a_g_gdppc_c_91 l_sd_g_gdppc_c_91 if oecd

outreg2 using o/growth_f_volay, ///
ctitle("Former Soviet Union") append label tex(pretty frag) : ///
reg a_g_gdppc_c_91 l_sd_g_gdppc_c_91 if fsu



use $gdi/wdigi, clear


xtline NE_GDI_FTOT_ZS if inlist(c, "RUS", "BRA","CHN","IND", "ZAF") & y > 1990, ov ///
ti("BRICS: Fixed capital formation") ///
name(gdi_brics, replace)
grex o/gdi_brics


tsline NE_GDI_FTOT_ZS NE_GDI_FPRV_ZS if c == "$gdc" & y > 1990, ///
ti("$gdn: Investments in fixed capital") yti("% of GDP") $gbl ///
name(gdi_gdn, replace)
grex o/gdi_gdn




// 
// Part 6
// Taxation and Laws
//


use $gdi/pwt7, clear

drop if y < 2000
so c y
foreach v in pc pg pi {
	* loc vl : lab var `v'
	clonevar i_`v' = `v'
	by c : replace i_`v' = `v' / `v'[1]
	* lab var i_`v' "`vl'"
}

tsline i_pc i_pg i_pi if c == "$gdc", ti("$gdn: Consumption and inflation") ///
yti("Price index, 2000 = 1") $gbl ///
name(infln_gdc, replace)
grex o/infln_gdc


use $gdi/unbundle, clear
clonevar c = shortnam 
encode country , gen(cid)
d xcon1990sj avexpr efhrpr7 

