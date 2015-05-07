*use G:/stick/bern/taxdata_BE_12.dta, clear
*append using G:/stick/bern/taxdata_BE_10-11.dta
*append using G:/stick/bern/taxdata_BE_08-09.dta
*append using G:/stick/bern/taxdata_BE_06-07.dta
*append using G:/stick/bern/taxdata_BE_04-05.dta
*append using G:/stick/bern/taxdata_BE_02-03.dta

*keep stj - sex_ep ZIVILSTAND BFS GESCHLECHT_P1 GESCHLECHT_P2 ANZAHL_KINDER Nat tot_erwerbeink - Leibrent TOTVERM- VERM_betr

*merge 1:1 stj pid using G:/stick/bern/zusatzdaten/taxdata_BE_Zusatz.dta

*keep ERBTEIL_ERH SCHENK_ERH SCHENK_AUSG stj - sex_ep ZIVILSTAND BFS GESCHLECHT_P1 GESCHLECHT_P2 ANZAHL_KINDER Nat tot_erwerbeink - Leibrent TOTVERM- VERM_betr

*save "G:\stick\bern\merged_erben.dta"

use "G:\stick\bern\merged_erben.dta"

recode ERB (-1000000/100000=1) (100001/2000000=2) (2000001/.=3), gen(erbkat)

* Wieviel kann überhaupt eingenommen werden?
gen stb_ERBE =  cond(erbkat==3, ERB-2000000, 0)
gen einnahmen = stb_ERBE*0.2
graph bar (sum) einnahmen, over(stj)
graph export C:/Users/Hackstutz/Dropbox/Git/datenblog/abbildungen/einnahmen.png, replace
graph export C:/Users/Hackstutz/Dropbox/Git/datenblog/abbildungen/einnahmen.pdf, replace



**************************************************************************************************************
*** Verteilung vor/nach Umverteilung durch Erbschaftssteuer (2012 kumuliert) *********************************
**************************************************************************************************************

preserve
keep if stj==2012
qui: su ERB
local N = r(N)
capture drop TOTVERM_ex_ERBE lnTOTVERM*
gen TOTVERM_ex_ERBE = TOTVERM
replace TOTVERM_ex_ERBE = TOTVERM-0.2*(ERB-2000000) if erbkat==3
su ERB if erbkat==3
replace TOTVERM_ex_ERBE = TOTVERM_ex_ERBE + (r(mean)-2000000)/`N'

*gen lnTOTVERM = ln(TOTVERM+1)
*gen lnTOTVERM_ex_ERBE = ln(TOTVERM_ex_ERBE+1)
*replace lnTOTVERM_ex_ERBE = 0 if lnTOTVERM_ex_ERBE<0

recode TOTVERM (-100000000/100000=1)(100001/2000000=2)(2000001/.=3), gen(vermkat)
graph bar (sum) TOTVERM TOTVERM_ex_ERBE, over(vermkat)
*ALT: twoway (histogram lnTOTVERM_ex_ERBE , start(0) width(2) color(green))(histogram lnTOTVERM, start(0) width(2) fcolor(none) lcolor(black)), legend(order(1 "Total Vermögen nach Erbe" 2 "Total Vermögen original"))
graph export C:/Users/Hackstutz/Dropbox/Git/datenblog/abbildungen/umverteilung2012.png, replace
graph export C:/Users/Hackstutz/Dropbox/Git/datenblog/abbildungen/umverteilung2012.pdf, replace
* man sieht fast nichts

restore

**************************************************************************************************************
*** Verteilung vor/nach Umverteilung durch Erbschaftssteuer (2002-2012 kumuliert) ****************************
**************************************************************************************************************

* Steuern die pro Person weggehn:
bysort pid: egen stb_ERBE_kumuliert =  sum(stb_ERBE)

* für die Einnahmen müsste man überlegen ob man sie Jahr für Jahr den Leuten zufügt (weil manche Leute 2002 z.B. noch gar nicht in Bern waren). Auf der anderen Seite waren diese Leute vermutlich vorher woanders in der Schweiz und hätten auch von der bundesweiten Erbschaftssteuer profiziert (einen (kleineren) Fehler macht man bei aus dem Ausland Zugezogenen), daher fasse ich das hier auch zusammen

qui: su stb_ERBE
* kumulierte EInnahmen über die 11 Jahre
local gesamteinnahmen = r(mean)*r(N)

* diese werden zum Stichjahr 2012 erst auf die gegenwärtige Bevölkerung verteilt
su ERB
local N = r(N)
capture drop TOTVERM_ex_ERBE lnTOTVERM*
gen TOTVERM_ex_ERBE = TOTVERM
* Steuern von den Reichen abziehen
replace TOTVERM_ex_ERBE = TOTVERM-0.2*(stb_ERBE_kumuliert)
* und dann gleichmässig an alle verteilen
replace TOTVERM_ex_ERBE = TOTVERM_ex_ERBE + `gesamteinnahmen'/`N'

*gen lnTOTVERM = ln(TOTVERM+1)
*gen lnTOTVERM_ex_ERBE = ln(TOTVERM_ex_ERBE+1)
*replace lnTOTVERM_ex_ERBE = 0 if lnTOTVERM_ex_ERBE<0

recode TOTVERM (-100000000/100000=1)(100001/2000000=2)(2000001/.=3), gen(vermkat)
graph bar (sum) TOTVERM TOTVERM_ex_ERBE, over(vermkat)
*ALT: twoway (histogram lnTOTVERM_ex_ERBE , start(0) width(2) color(green))(histogram lnTOTVERM, start(0) width(2) fcolor(none) lcolor(black)), legend(order(1 "Total Vermögen nach Erbe" 2 "Total Vermögen original"))
graph export C:/Users/Hackstutz/Dropbox/Git/datenblog/abbildungen/umverteilung20022012.png, replace
graph export C:/Users/Hackstutz/Dropbox/Git/datenblog/abbildungen/umverteilung20022012.pdf, replace


