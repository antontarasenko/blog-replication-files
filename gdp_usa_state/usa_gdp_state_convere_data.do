// 
// PREPARING DATA
//

/* Use "usa_state_gsp_pc.dta" OR create it youself:

1.
Download from http://www.bea.gov/regional/downloadzip.cfm
- gsp_sic_all_PC.zip
- gsp_naics_all_PC.zip

2.
Add prefixes "sic" and "naics" to columns 19xx and 20xx in the original CSV files.

3.
Run this code to obtain "usa_state_gsp_pc.dta"

*/

import delimited "gsp_sic_all_PC.csv", clear
save gsp_sic_all_PC, replace
import delimited "gsp_naics_all_PC.csv", clear
save gsp_naics_all_PC, replace

use gsp_sic_all_PC, clear

mer 1:1 geofips using gsp_naics_all_PC, keepusing(naics1997-naics2014) nogen

// missing
drop sic1963-sic1986

// reshape into panel
reshape long sic naics, i(geofips geoname) j(year)
lab var year Year

ren sic gsp_sic
ren naics gsp_naics
lab var gsp_sic "Real GSP per capita by SIC"
lab var gsp_naics "Real GSP per capita by NAICS"

// mark regional data
gen b_state = !inlist(geoname, "United States", "Far West", "Great Lakes", "Mideast", "New England", "Plains", "Rocky Mountain", "Southeast", "Southwest")
lab var b_state "Is a state?"

encode geoname, gen(sid)
xtset sid year

gen g_gsp_sic = gsp_sic / L1.gsp_sic - 1
gen g_gsp_naics = gsp_naics / L1.gsp_naics - 1
lab var g_gsp_sic "Real GSP PC growth rate by SIC"
lab var g_gsp_naics "Real GSP PC growth rate by NAICS"

// recalculate GSP for SIC after 1997 and NAICS before 1997
so sid year
replace gsp_sic = L1.gsp_sic * ( g_gsp_naics + 1 ) if year > 1997
gsort sid -year
by sid: replace gsp_naics = gsp_naics[_n-1] / ( g_gsp_sic[_n-1] + 1 ) if year < 1997

so sid year

foreach gsp in "gsp_sic" "gsp_naics" {
	gen l_`gsp' = ln(`gsp')
	lab var l_`gsp' "Log of real GSP per capita"
	gen g5_`gsp' = F5.`gsp' / `gsp' - 1
	lab var g5_`gsp' "Cumulative real GSP per capita growth over next 5 years"
}


save usa_state_gsp_pc, replace
