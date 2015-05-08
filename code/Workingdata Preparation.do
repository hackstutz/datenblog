

***********************************************************************************
* Project: 	Ungleichheit der Einkommen und Vermögen	
* Task: 	Daten für Analyen zu Erben und Vermögen vorbereiten
* Author: 	Oliver Hümbelin 						
* Date: 	Mai 2015
************************************************************************************



**********************
* Wie verteilen sich Vermögenskomponenten auf bewegliches Vermögen, Liegenschaftsvermögen und Betriebsvermögen
*********************

**********
* Prepare Data
********


****
* Get matched data for Bern
*clear
use "E:\Steuerdaten\Bern Steuerdaten\Aufbereitete Datensätze\taxdata_BE.dta", replace
set more off

* Get Zusatz data (Erben und Vorsorgedaten)
*clear
use "E:\Steuerdaten\Bern Steuerdaten\Aufbereitete Datensätze\taxdata_BE_Zusatz.dta", replace
set more off

* Match datasets
qui cd "E:\Steuerdaten\Bern Steuerdaten\Aufbereitete Datensätze\"

clear
use "taxdata_BE", replace
set more off
merge 1:1 pid stj using taxdata_BE_Zusatz.dta


****
* Prepare Data
drop if TOTVERM==.
recode TOTVERM (min/100000=1)(100000/2000000=2)(2000000/max=3), gen(vermkat)
bysort pid (stj): g wealthchange=TOTVERM-TOTVERM[_n-1]
bysort pid (stj): gen erbe=1 if ERBTEIL_ERH>0
recode erbe (.=0)
bysort pid (stj): gen schenk=1 if SCHENK_ERH>0
recode schenk (.=0)
recode wealthchange (min/-3000=1)(-3001/10000=2)(10001/max=3),gen(wckat)
label define wckatl 1 "<p25" 2 "mittlere 50%" 3 "p75<", modify
label values wckat wckatl
bysort pid: g panel= _N
keep STEUERJAHR TOTVERM SCHULDEN VERM_bew VERM_bew_Finanz VERM_bew_U VERM_lieg VERM_betr ERBTEIL_ERH SCHENK_ERH SCHENK_AUSG ///
wealthchange vermkat wckat erbe schenk pid panel

save "E:\Steuerdaten\Analysen zu Erben und Vermögen\workingdata.dta"
use "E:\Steuerdaten\Analysen zu Erben und Vermögen\workingdata", replace



*****
* Was ist wenn Erbe an den Partner geht?

tab ZIVILSTAND, nol
tab pid if ZIVILSTAND==4 & ERB>0 & stj==2010

egen check = anymatch(pid), values(10093631 10112332 10121374 10156826 10190197 10202471 10251312)
keep if check
sort pid stj
