/* Convert data from http://www.start.umd.edu/gtd/ to .csv */
import delimited "gtd.csv", colrange(2) clear
g n = 1
collapse (count) n (sum) nkill, by(country_txt iyear)
lab var iyear "Year"
lab var country_txt "Country"
lab var n "Total terrorist acts"
lab var nkill "Death toll"
encode(country_txt), g(cid)
destring iyear, force replace
tsset cid iyear

tsline nkill if inlist(country_txt, "Afghanistan", "Pakistan", "Iraq", "Somalia", "Yemen"), name("wot_targets", replace) by(country_txt, title("Victims of terrorism in countries targeted by the War on Terror")) tli(2001)
tsline nkill if inlist(country_txt, "United States", "Great Britain", "Spain", "Italy"), name("wot_members", replace) by(country_txt, title("Victims of terrorism in countries participated in the War on Terror")) tli(2001)
tsline nkill if inlist(country_txt, "Egypt", "Libya", "Syria", "Tunisia", "Yemen", "Bahrain"), name("arab_spring", replace) by(country_txt, title("Victims of terrorism in the Arab Spring countries")) tli(2010)
graph bar (sum) nkill, name("total_deathtoll", replace) title("Victims of terrorism by year") over(iyear, label(angle(vertical)))
