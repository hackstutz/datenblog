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

use "G:\stick\bern\merged_erben.dta", clear
gen rein_verm=TOTVERM+SCHULDEN

recode ERB (-1000000/100000=1) (100001/2000000=2) (2000001/.=3), gen(erbkat)

* Wieviel kann überhaupt eingenommen werden?
gen stb_ERBE =  cond(erbkat==3, ERB-1000000, 0)
gen stb_schenkung = cond(SCHENK_AUSG>20000, SCHENK_AUSG-20000, 0)
gen einnahmen = stb_ERBE*0.2+stb_schenkung*0.2
graph bar (sum) einnahmen, over(stj)
graph export C:/Users/Hackstutz/Dropbox/Git/datenblog/abbildungen/einnahmen.png, replace
graph export C:/Users/Hackstutz/Dropbox/Git/datenblog/abbildungen/einnahmen.pdf, replace

* Wieviel wurde 2011 verschenkt?

su einnahmen if stj!=2011


*    Variable |       Obs        Mean    Std. Dev.       Min        Max
*-------------+--------------------------------------------------------
*   einnahmen |   5946773    378.8909    59218.72          0   1.02e+08


. di r(N)*r(mean)/10
*2.253e+08 225 Mio

* durchschnittlich (exkl. 2011) hätten pro Jahr 225Mio CHF erhoben werden können (Erbe plus Schenkungen)

su stb_schenkung if stj!=2011
* soviel wird üblicherweise verschenkt
local meanschenk = r(N)*r(mean)*0.2/10

su stb_schenkung if stj==2011
di r(N)*r(mean)*0.2 - `meanschenk'
* 7.921e+08

* 792 Mio CHF potentielle Einnahmen wurden 2011 verschenkt. Den Einnahmendurchschnitt zugrunde gelegt entspricht das 3.5 Jahre entgangene Steuereinnahmen
di 7.921e+08/2.253e+08

**************************************************************************************************************
*** Verteilung vor/nach Umverteilung durch Erbschaftssteuer (2012 kumuliert) *********************************
**************************************************************************************************************

preserve
keep if stj==2012
qui: su ERB
local N = r(N)
capture drop rein_verm_ex_ERBE lnrein_verm*
gen rein_verm_ex_ERBE = rein_verm
replace rein_verm_ex_ERBE = rein_verm-0.2*(ERB-2000000) if erbkat==3
su ERB if erbkat==3
replace rein_verm_ex_ERBE = rein_verm_ex_ERBE + (r(mean)-2000000)/`N'

*gen lnrein_verm = ln(rein_verm+1)
*gen lnrein_verm_ex_ERBE = ln(rein_verm_ex_ERBE+1)
*replace lnrein_verm_ex_ERBE = 0 if lnrein_verm_ex_ERBE<0

recode rein_verm (-100000000/100000=1)(100001/2000000=2)(2000001/.=3), gen(vermkat)
graph bar (sum) rein_verm rein_verm_ex_ERBE, over(vermkat)
*ALT: twoway (histogram lnrein_verm_ex_ERBE , start(0) width(2) color(green))(histogram lnrein_verm, start(0) width(2) fcolor(none) lcolor(black)), legend(order(1 "Total Vermögen nach Erbe" 2 "Total Vermögen original"))
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
capture drop rein_verm_ex_ERBE lnrein_verm*
gen rein_verm_ex_ERBE = rein_verm
* Steuern von den Reichen abziehen
replace rein_verm_ex_ERBE = rein_verm-0.2*(stb_ERBE_kumuliert)
* und dann gleichmässig an alle verteilen
replace rein_verm_ex_ERBE = rein_verm_ex_ERBE + `gesamteinnahmen'/`N'

*gen lnrein_verm = ln(rein_verm+1)
*gen lnrein_verm_ex_ERBE = ln(rein_verm_ex_ERBE+1)
*replace lnrein_verm_ex_ERBE = 0 if lnrein_verm_ex_ERBE<0

recode rein_verm (-100000000/100000=1)(100001/2000000=2)(2000001/.=3), gen(vermkat)
graph bar (sum) rein_verm rein_verm_ex_ERBE, over(vermkat)
*ALT: twoway (histogram lnrein_verm_ex_ERBE , start(0) width(2) color(green))(histogram lnrein_verm, start(0) width(2) fcolor(none) lcolor(black)), legend(order(1 "Total Vermögen nach Erbe" 2 "Total Vermögen original"))
graph export C:/Users/Hackstutz/Dropbox/Git/datenblog/abbildungen/umverteilung20022012.png, replace
graph export C:/Users/Hackstutz/Dropbox/Git/datenblog/abbildungen/umverteilung20022012.pdf, replace



**************************************************************************************************************
*** Simulation Datenbasis ************************************************************************************
**************************************************************************************************************


* nehmen wir 2012
preserve
keep if stj==2012
* quintile bilden
xtile quintile=rein_verm, nq(5)

* wieviel vermögen ist in den quintilen?
table quintile, c(sum rein_verm)

* wie hoch ist die steuerbare masse? für 2M Freibetrag? 
qui su rein_verm if rein_verm>2000000
local stb_masse2M = (r(mean)-2000000)*r(N)
di `stb_masse2M'

* und für andere szenarien?
qui su rein_verm if rein_verm>1000000
local stb_masse1M = (r(mean)-1000000)*r(N)
di `stb_masse1M'

qui su rein_verm if rein_verm>10000000	
local stb_masse10M = (r(mean)-10000000)*r(N)
di `stb_masse10M'

qui su rein_verm if rein_verm>500000
local stb_masse500K = (r(mean)-500000)*r(N)
di `stb_masse500K'

* Umlaufgeschwindigkeit 
* (vereinfacht, alle Schenkungen+Erben durch alle Vermögen)
* evtl. werden hohe Vermögen schneller oder langsamer vererbt als niedrige Vermögen. 
su rein_verm
local rv = r(mean)*r(N)
gen erbschenk = ERB+SCHENK_AUSG
su erbschenk if rein_verm!=.
local erbschenk = r(mean)*r(N)
di `erbschenk'/`rv'
* 62 Jahre

restore
