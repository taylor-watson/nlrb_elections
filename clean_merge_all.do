// ------------------------------------------------
/* 
Project: NLRB Elections Archive

Goal: Share the NLRB elections data on GitHub

This Do File: Clean and merge the election data from 1977-2022. 
The 1977-1999 file is a bit of a mess, so there's a lot of cleaning needed before it can reasonably be merged with the following years.
The 2000-2010 file is nicely formatted, so it doesn't take much cleaning.
The 2011-2022 files are a bit trickier, as they separately archive elections with one, two, or three unions. Elections with more than one union are a small minority, so for the purposes of this cleaning & merging I'm going to leave them out for simplicity.
*/
// -------------------------------------------------


********************************
**Table Setting*
*******************************
clear
set more off
cd "/Users/taylorwatson/Documents/GitHub/nlrb_elections"
//Don't forget to chnage your directory in the above line! You'll also need to download the folders on GitHub into that directory (raw_files, helper_files). This do-file will then call files and do-files from those folders.

capture mkdir "cleaned_files"
//This creates a local folder for storing the cleaned files, but please note that this is also available on GitHub


********************************
**Import & clean raw file for years 1977-1999*
*******************************
use "raw_files/nlrb7799_raw.dta", clear

//We are only interested in certification elections, which is case type "5"
rename TYPE case_type
drop if case_type != "5"
//Drop inconclusive elections (which are rerun for conclusion and stored separately)
drop if RECTYPE != "0"

//We're going to use two-letter state coding, like normal people, instead of the NLRB's bizzare choice of mixed 2-and-3-letter abbreviations 
rename STATE1 state_of_plant
replace state_of_plant = "CT" if state_of_plant == "CON"
replace state_of_plant = "MA" if state_of_plant == "MAS"
replace state_of_plant = "VT" if state_of_plant == "VER"
replace state_of_plant = "DE" if state_of_plant == "DEL"
replace state_of_plant = "TN" if state_of_plant == "TEN"
replace state_of_plant = "WV" if state_of_plant == "WVA"
replace state_of_plant = "MI" if state_of_plant == "MIC"
replace state_of_plant = "OH" if state_of_plant == "OHI"
replace state_of_plant = "IN" if state_of_plant == "IND"
replace state_of_plant = "AL" if state_of_plant == "ALA"
replace state_of_plant = "FL" if state_of_plant == "FLA"
replace state_of_plant = "IL" if state_of_plant == "ILL"
replace state_of_plant = "ID" if state_of_plant == "IDO" | state_of_plant == "IDA"
replace state_of_plant = "TX" if state_of_plant == "TEX"
replace state_of_plant = "OK" if state_of_plant == "OKL"
replace state_of_plant = "NE" if state_of_plant == "NEB"
replace state_of_plant = "KS" if state_of_plant == "KAN"
replace state_of_plant = "MN" if state_of_plant == "MIN"
replace state_of_plant = "IA" if state_of_plant == "IOW"
replace state_of_plant = "WA" if state_of_plant == "WAS"
replace state_of_plant = "AK" if state_of_plant == "ALK"
replace state_of_plant = "MT" if state_of_plant == "MON"
replace state_of_plant = "CA" if state_of_plant == "CAL"
replace state_of_plant = "NV" if state_of_plant == "NEV"
replace state_of_plant = "AR" if state_of_plant == "ARK"
replace state_of_plant = "MS" if state_of_plant == "MIS"
replace state_of_plant = "MA" if state_of_plant == "MAS"
replace state_of_plant = "OR" if state_of_plant == "ORE"
replace state_of_plant = "UT" if state_of_plant == "UTA"
replace state_of_plant = "CO" if state_of_plant == "COL"
replace state_of_plant = "WY" if state_of_plant == "WYO"
replace state_of_plant = "AZ" if state_of_plant == "ARI"
replace state_of_plant = "WI" if state_of_plant == "WIS"
replace state_of_plant = "HI" if state_of_plant == "HAW"

rename STATE2 state
replace state = "CT" if state == "CON"
replace state = "MA" if state == "MAS"
replace state = "VT" if state == "VER"
replace state = "DE" if state == "DEL"
replace state = "TN" if state == "TEN"
replace state = "WV" if state == "WVA"
replace state = "MI" if state == "MIC"
replace state = "OH" if state == "OHI" | state == "0HI"
replace state = "IN" if state == "IND"
replace state = "AL" if state == "ALA"
replace state = "FL" if state == "FLA"
replace state = "IL" if state == "ILL"
replace state = "ID" if state == "IDO" | state == "IDA"
replace state = "TX" if state == "TEX"
replace state = "OK" if state == "OKL"
replace state = "NE" if state == "NEB"
replace state = "KS" if state == "KAN"
replace state = "MN" if state == "MIN"
replace state = "IA" if state == "IOW"
replace state = "WA" if state == "WAS"
replace state = "AK" if state == "ALK"
replace state = "MT" if state == "MON"
replace state = "CA" if state == "CAL"
replace state = "NV" if state == "NEV"
replace state = "AR" if state == "ARK"
replace state = "MS" if state == "MIS"
replace state = "MA" if state == "MAS"
replace state = "OR" if state == "ORE"
replace state = "UT" if state == "UTA"
replace state = "CO" if state == "COL"
replace state = "WY" if state == "WYO"
replace state = "AZ" if state == "ARI"
replace state = "WI" if state == "WIS"
replace state = "HI" if state == "HAW"

//Drop some of the messy / non-target sample elections
drop if cntycode == "-97"
drop if cntycode == "-89"
drop if cntycode == "11B"
drop if state == "VI"
drop if state == "PR"
drop if state == "DC"

//Lowercase variable names for simplicity
rename UNIT unit
rename SIZE_cat size_cat
rename EMPLOYER employer
rename CITY city
rename UNIONname union_name
rename cntytext county_text_original
rename VNOUNION votes_against
rename vote_win votes_for

//The data is coded oddly so that "for" votes are the winning outcome, rather than for the union - so we have to standardize accordingly, such that we have a consistent measure of union votes and anti-union votes
replace votes_for = vote_lose1 if votes_for == 0 & vote_lose1 != 0

//The NLRB in its infinite wisdom uses its own bespoke set of geographic codings. The following code should standardize these to things other datasets might reasonably expect to use. Note that this involves use of a couple of crosswalk helper files, stored also on Github, but that you will need to adjust your code to reference them however you end up organizing things.
destring cntycode, generate(countycode)

replace countycode = 86 if countycode == 25 & state == "FL"

replace county_text_original = subinstr(county_text_original, "*", "",.)

sort state_of_plant countycode
replace county_text_original = county_text_original[_n+1] if county_text_original == "" & state_of_plant == state_of_plant[_n+1] & countycode == countycode[_n+1]
replace county_text_original = county_text_original[_n-1] if county_text_original == "" & state_of_plant == state_of_plant[_n-1] & countycode == countycode[_n-1]

replace county_text_original = "MIAMI-DADE" if county_text_original == "DADE"
replace county_text_original = "DEKALB" if county_text_original == "DE KALB"
replace county_text_original = "SUFFOLK" if county_text_original == "SUFFLOK"

rename countycode cocode

rename stcode nlrbcode

merge m:1 nlrbcode using "helper_files/state_nlrbcode_to_ab.dta"
drop _merge

statastates, name(StateName)
drop _merge 

countyfips, name(county_text_original) statefips(state_fips)
drop _merge

//Reformat the dates for consistency across sources
replace dateclose = (dateclose+"01") if length(dateclose)<7
replace dateclose = "19"+dateclose
gen dateclose_h = date(dateclose,"YMD")
format dateclose_h %td
drop dateelec
drop datefile
rename fiscalyear year
destring year, gen(year_num)
drop year
rename year_num year
replace year = year(dateclose_h) if year == .
drop if year == . 

//Generate a few outcome variables of interest for consistency with other years
gen won = inlist(outcome,"WON","1")
gen lost = inlist(outcome,"LOST")
gen win_margin = votes_for - votes_against

//There's a lot of weird variables in this dataset that I cannot find meaning in, so I'm dropping them. If you care about them - please feel free to adjust the code accordingly!
drop var19 duplic var21 var22 var23 var24 var25 var26 var27 var28 var53 var59 D E F dateclose

//We can now save the first sample, 1977-1999, for later merging.
save "cleaned_files/nlrb7799_clean.dta", replace


********************************/
**Import & clean 2000-2010*
*******************************
//2000-2010
qui forvalues y = 2000(1)2010 {
import excel "raw_files/nlrb0010_raw.xlsx", sheet("FY`y'") firstrow clear

//Drop unidentified geographic elections
drop if UnitLocCounty == ""

rename UnitLocCounty county_text_original
rename ElectionState StateAbbreviation

merge m:1 StateAbbreviation using "helper_files/state_ab_to_fips.dta"
drop if _merge != 3
drop _merge

countyfips, name(county_text_original) statefips(FIPSCode)
drop if _merge != 3
drop _merge
gen year = `y'

gen won = inlist(ElectionResult,"WIN")
gen lost = inlist(ElectionResult,"LOST")
gen win_margin = VotesFor - VotesAgainst

rename VotesFor votes_for
rename VotesAgainst votes_against
rename DateClosed dateclose_h

save "cleaned_files/nlrb`y'_clean.dta", replace

}

use "cleaned_files/nlrb2000_clean.dta", replace
forvalues y = 2001(1)2010{
	append using "cleaned_files/nlrb`y'_clean.dta"
}

drop V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ BA BB BC BD BE BF BG BH BI BJ BK BL BM BN BO BP BQ BR BS BT BU BV BW BX BY BZ CA CB CC CD CE CF CG CH CI CJ CK CL CM CN CO CP CQ CR CS CT CU CV CW CX CY CZ DA DB DC DD DE DF DG DH DI DJ DK DL DM DN DO DP DQ DR DS DT DU DV DW DX DY DZ EA EB EC ED EE EF EG EH EI EJ EK EL EM EN EO EP EQ ER ES ET EU EV EW EX EY EZ FA FB FC FD FE FF FG FH FI FJ FK FL FM FN FO FP FQ FR FS FT FU FV FW FX FY FZ GA GB GC GD GE GF GG GH GI GJ GK GL GM GN GO GP GQ GR GS GT GU GV GW GX GY GZ HA HB HC HD HE HF HG HH HI HJ HK HL HM HN HO HP HQ HR HS HT HU HV HW HX HY HZ IA IB IC ID IE IF IG IH II IJ IK IL IM IN IO IP IQ IR IS IT IU IV

//Rename variables to match the 1977-1999 file and minimize variables post-merge
rename UnitLocState state_of_plant
rename UnionName union_name
rename ElectionResult outcome
rename BargUnit unit
rename NumEligEmployees eligible

save "cleaned_files/nlrb0010_clean.dta", replace


********************************/
**Merge the 1977-1999 with the 2000-2010 files*
*******************************
use "cleaned_files/nlrb0010_clean.dta", replace

append using "cleaned_files/nlrb7799_clean.dta"

save "cleaned_files/nlrb7710_clean.dta", replace


********************************/
**Import & clean 2011-2022*
*Sadly, we lose the county of the election in these files; they contain only the city and state.
*******************************
//2011-2019
qui forvalues y = 11(1)19 {
import excel "raw_files/nlrb`y'_raw.xlsx", sheet("FY20`y'-1 Labor Org") firstrow clear

rename VotesforLaborOrg1 votes_for
rename ValidVotesAgainst votes_against
rename ClosedDate dateclose_h

gen won = inlist(CertofRepWin,"WON")
gen lost = inlist(CertofResultsLoss,"LOSS")
gen win_margin = votes_for - votes_against

//Rename variables to match the 1977-2010 file and minimize variables post-merge
rename DisputeUnitState state_of_plant
rename LaborOrg1Name union_name
rename NumEligibleVoters eligible

gen year = 2000+`y'

save "cleaned_files/nlrb20`y'_clean.dta", replace

}

//2020-2022
qui forvalues y = 20(1)22 {
import excel "raw_files/nlrb`y'_raw.xlsx", sheet("NLRB Elections") firstrow clear

gen dateclose_h = date(ClosedDate, "DMY")
format dateclose_h %td
drop ClosedDate
gen dateheld_h = date(ElectionHeldDate, "DMY")
format dateheld_h %td
drop ElectionHeldDate

drop if NumEligibleVoters == ""
drop if NumEligibleVoters == "Num Eligible Voters"

foreach var in NumEligibleVoters ValidVotesAgainst VotesforLaborOrg1 {
	destring `var', replace
}

rename VotesforLaborOrg1 votes_for
rename ValidVotesAgainst votes_against

gen won = inlist(CertofRepWin,"WON")
gen lost = inlist(CertofResultsLoss,"LOSS")
gen win_margin = votes_for - votes_against

//Rename variables to match the 1977-2010 file and minimize variables post-merge
rename DisputeUnitState state_of_plant
rename LaborOrg1Name union_name
rename NumEligibleVoters eligible

gen year = 2000+`y'

save "cleaned_files/nlrb20`y'_clean.dta", replace

}

use "cleaned_files/nlrb2011_clean.dta", replace
forvalues y = 2012(1)2022{
	append using "cleaned_files/nlrb`y'_clean.dta"
}

drop R S T U V

save "cleaned_files/nlrb1122_clean.dta", replace


********************************/
**Merge the 1977-2010 with the 2011-2022 files*
*******************************
use "cleaned_files/nlrb1122_clean.dta", replace

append using "cleaned_files/nlrb7710_clean.dta"

//Clean up some of the redundant variables
drop StateAb FIPSCode StateName state_abb state_code state sttext stcodetext state1fix state2fix state_abbrev state_fips

statastates, abbreviation(state_of_plant)

save "cleaned_files/nlrb7722_clean.dta", replace



