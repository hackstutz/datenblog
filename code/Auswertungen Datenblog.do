

***********************************************************************************
* Project: 	Ungleichheit der Einkommen und Vermögen	
* Task: 	Vermögensverteilung Kanton Bern
* Author: 	Oliver Hümbelin					
* Date: 	Mai 2015
************************************************************************************



**********************
* Wie verteilt sich das Vermögen auf verschiedene Vermögenskategorien (bis 100000, bis 2000000 oder über 2000000)
*********************

****
* Get matched data for Bern
clear
use "E:\Steuerdaten\Analysen zu Erben und Vermögen\workingdata.dta", replace
set more off

drop if TOTVERM==. /* Fälle aus den Zusatzdaten, die in den Originaldaten nicht existieren */
drop if stj==2002 /* Einschränkung auf 10 Jahre */



**
* Ungleichheit in Bern
recode TOTVERM (min/0=1)
recode TOTVERM (min/100000=1)(100000/2000000=2)(2000000/max=3), gen(vermkat)
fastgini TOTVERM if stj==2012
tab vermkat if stj==2012
recode VERM_lieg (min/100000=0)(100001/2000000=1)(2000001/max=2), gen(vermkatL)
tab vermkatL
recode VERM_betr (min/100000=0)(100001/2000000=1)(2000001/max=2), gen(vermkatB)
tab vermkatB
sum VERM_betr if vermkatB==2, d
display r(max)

* Vermögensquintile in Bern - 2012
_pctile TOTVERM if stj==2012, p(20,40,60,80)
return list
recode TOTVERM (min/1485=1)(1485/20787=2)(20788/122970=3)(122970/492088=4)(492089/max=5), gen(quint)
label define quintl 1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4"  5 "Q5"
label values quint quintl
sum TOTVERM if stj==2012, d /* mean=348'954, median=49'170 */

keep VERM_bew VERM_bew_Finanz VERM_lieg VERM_betr TOTVERM SCHULDEN quint stj pid ERBTEIL_ERH SCHENK_ERH SCHENK_AUSG STEUERJAHR

* Summen je Quintil
preserve
foreach var of varlist VERM_bew VERM_bew_Finanz VERM_lieg VERM_betr TOTVERM SCHULDEN {
replace `var'=`var'/1000000000
}
keep if stj==2012
collapse (sum) TOTVERM VERM_bew VERM_bew_Finanz VERM_lieg VERM_betr, by(quint)
label values quint quintl
graph bar  VERM_bew_Finanz VERM_lieg VERM_betr TOTVERM, over(quint) ///
title ("Vermögenssummen") ///
ytitle("Milliarden CHF") ///
legend(label(1 "Finanzkapital") label(2 "Liegenschaften") label(3 "Betriebsvermögen")label(4 "Gesamtvermögen")) ///
name(Quintile, replace)
* blabel(bar, position(outside) format(%9.1f) color(black))
*text(170 20 "Mittleres Vermögen: 348'954 CHF", size(small)) ///
*text(160 20 "Medianes Vermögen:  49'170 CHF", size(small)) ///
graph save Graph "E:\Steuerdaten\Analysen zu Erben und Vermögen\Graphs\Quintilsverteilung.gph", replace
restore

* Anteile je Quintil
preserve
keep if stj==2012
foreach var of varlist VERM_bew VERM_bew_Finanz VERM_lieg VERM_betr TOTVERM SCHULDEN {
replace `var'=`var'/1000000000
}
collapse (sum) TOTVERM VERM_bew_Finanz VERM_lieg VERM_betr SCHULDEN, by(quint)
label values quint quintl	
egen totK = sum(VERM_bew_Finanz)
egen totL = sum(VERM_lieg)
egen totB = sum(VERM_betr)
egen totalverm = sum(TOTVERM)
gen anteilK = 100*VERM_bew_Finanz/totK
gen anteilL = 100*VERM_lieg/totL
gen anteilB = 100*VERM_betr/totB
gen anteilverm 		= 100*TOTVERM/totalverm
graph bar anteilK anteilL anteilB anteilverm, over(quint) ///
title ("Anteile am Gesamtvermögen") ///
ytitle("Prozent") ///
legend(label(1 "Finanzkapital") label(2 "Liegenschaften") label(3 "Betriebsvermögen")label(4 "Gesamtvermögen")) ///
name(Totalvermögen, replace)
graph save "E:\Steuerdaten\Analysen zu Erben und Vermögen\Graphs\Anteil am TotalvermögenII", replace
restore

graph combine Quintile Totalvermögen, altshrink
grc1leg Quintile Totalvermögen /* Nur eine Legende */
 
univar TOTVERM if stj==2012, by(quint)
sum TOTVERM if stj==2012 & quint==4,d
sum TOTVERM if stj==2012 & quint==5,d

preserve
keep if stj==2012
collapse (sum) TOTVERM, by(vermkat)
replace TOTVERM=TOTVERM/1000000000
tab TOTVERM
restore


************
* Erbe, Schenkungen und Erbschafssteuer.

use "E:\Steuerdaten\Analysen zu Erben und Vermögen\workingdata", replace

preserve
foreach var of varlist ERBTEIL_ERH SCHENK_ERH {
replace `var'=`var'/1000000000
}
keep ERBTEIL_ERH SCHENK_ERH STEUERJAHR
collapse (sum) ERBTEIL_ERH SCHENK_ERH , by(STEUERJAHR)
graph bar ERBTEIL_ERH SCHENK_ERH, over(STEUERJAHR) ///
ytitle("Milliarden CHF") ///
legend(label(1 "Erhaltenes Erbe") label(2 "Schenkungen erhalten") label(3 "Schenkungen ausgerichtet"))
graph save Graph "E:\Steuerdaten\Analysen zu Erben und Vermögen\Graphs\Erben und Schenkungen.gph", replace
restore

* Erbschaftssteuer

recode ERB (-1000000/100000=1) (100001/2000000=2) (2000001/.=3), gen(erbkat)
gen stb_ERBE =  cond(erbkat==3, ERB-1000000, 0)
gen einnahmen = stb_ERBE*0.2
keep STEUERJAHR einnahmen
collapse (sum) einnahmen, by(STEUERJAHR)
foreach var of varlist einnahmen  {
replace `var'=`var'/1000000
}

su einnahmen, d

* Schenkungen

gen stb_SCHENK = cond(SCHENK_ERH>20000, SCHENK_ERH-20000,0)
gen einnahmenS = stb_SCHENK*0.2
su stb_SCHENK if stj==2011
keep STEUERJAHR einnahmenS stb_SCHENK
collapse (sum) stb_SCHENK einnahmenS, by(STEUERJAHR)
di r(N)*r(mean)*0.2
foreach var of varlist stb_SCHENK einnahmenS  {
replace `var'=`var'/1000000
}

su einnahmenS, d


* 4.741e+08

























