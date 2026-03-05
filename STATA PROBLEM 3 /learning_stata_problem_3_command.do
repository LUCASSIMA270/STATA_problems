cd "C:\Users\lucas\OneDrive\Desktop\S2\Statistical software for empirical projects\learning_stata_problem_3"

clear
set more off

//////////////////////////////////////////////////////////////////////////////////////////
*PROBLEM_SET_3*
//////////////////////////////////////////////////////////////////////////////////////////

******************************************************************************************
*Question 3*
******************************************************************************************

* Load the WVS6 dataset and prepare the data

use "Data\Sources\WVS6.dta", clear

* Keep only relevant variables

keep V262 V2 B_COUNTRY_ALPHA V24 V109 V113 V114 V248

* Rename variables for better readability

rename V262 year
rename V2 country
rename B_COUNTRY_ALPHA cow_code
rename V24 trust_people
rename V109 trust_army
rename V113 trust_police
rename V114 trust_courts
rename V248 education_level

* Create a unique identifier: combination of country code and year

gen unique_id = cow_code + "_" + string(year, "%4.0f")

* Save the cleaned data

save "Data\Temp\1_WVS6_cleaned.dta", replace

* Load the WVS7 dataset and prepare the data

use "Data\Sources\WVS7.dta", clear

* Keep only relevant variables

keep A_YEAR B_COUNTRY B_COUNTRY_ALPHA Q57 Q69 Q70 Q71 Q275

* Rename variables to match WVS6

rename A_YEAR year
rename B_COUNTRY country
rename B_COUNTRY_ALPHA cow_code
rename Q57 trust_people
rename Q69 trust_army
rename Q70 trust_police
rename Q71 trust_courts
rename Q275 education_score

* Convert education score into an integer

gen int education_level = floor(education_score)

* Create a unique identifier: combination of country code and year

gen unique_id = cow_code + "_" + string(year, "%4.0f")

* Save the cleaned data

save "Data\Temp\2_WVS7_cleaned.dta", replace

* Identify common countries between WVS6 and WVS7

use "Data\Temp\1_WVS6_cleaned.dta", clear
keep cow_code
gen wave = 6
duplicates drop  

save "Data\Temp\3_WVS6_with_countries.dta", replace

use "Data\Temp\2_WVS7_cleaned.dta", clear
keep cow_code
gen wave = 7
duplicates drop  
save "Data\Temp\4_WVS7_with_countries.dta", replace

* Merge country lists to identify common countries

merge 1:1 cow_code using "Data\Temp\3_WVS6_with_countries.dta"
keep if _merge == 3  
drop _merge wave
save "Data\Temp\5_merge_countries.dta", replace

* Filter WVS6 and WVS7 to keep only common countries

use "Data\Temp\1_WVS6_cleaned.dta", clear
merge m:1 cow_code using "Data\Temp\5_merge_countries.dta"
keep if _merge == 3  
drop _merge
save "Data\Temp\6_WVS6_filtered.dta", replace

use "Data\Temp\2_WVS7_cleaned.dta", clear
merge m:1 cow_code using "Data\Temp\5_merge_countries.dta"
keep if _merge == 3  
drop _merge
save "Data\Temp\7_WVS7_filtered.dta", replace

* Convert the country variable to a string

decode country, gen(country_str)
drop country
rename country_str country

* Merge WVS6 and WVS7 data

use "Data\Temp\6_WVS6_filtered.dta", clear
append using "Data\Temp\7_WVS7_filtered.dta"

* Sort data by country code and year

sort cow_code year

* Aggregate data by country and year (mean of variables)

collapse (mean) trust_people trust_army trust_police trust_courts education_level, by(country year cow_code)

* Recreate unique identifier after aggregation

gen unique_id = cow_code + "_" + string(year)

* Save the merged file

save "Data\Temp\8_WVS_6_and_7_merged.dta", replace

* Load and prepare GDP data (World Bank)

import excel "Data\Sources\world_bank.xlsx", sheet("Data") firstrow clear

save "Data\Temp\World_bank_données_brutes.dta", replace

* Rename variables for better readability

rename GDPpercapitaconstant2015US GDP
rename CountryName country
rename CountryCode cow_code
rename Time year

* Convert year to string to create unique identifier

tostring year, replace

* Create a unique identifier: combination of country code and year

gen unique_id = cow_code + "_" + year

* Encode categorical variables for tsset usage

encode country, generate(country_numeric)
encode GDP, gen(GDP1)

* Convert year to numeric for calculations

destring year, replace

* Remove years 2000-2009 (if necessary)

drop if year >= 2000 & year <= 2009

* Sort data by country

sort country

* Convert GDP to numeric

destring GDP, replace

* Set panel structure for growth calculations

tsset country_numeric year

* Compute annual GDP growth rate

gen GDP_growth = 100 * (GDP1 - L.GDP1) / L.GDP1

* Create a variable for GDP in 5 years

by country_numeric: gen GDP5 = GDP1[_n+5]

* Compute the 5-year average annual GDP growth rate

gen gdp_5yearsgrowth_rate = ((GDP5 / GDP1)^(1/5) - 1) * 100

* Remove temporary GDP5 variable

drop GDP5

* Save cleaned GDP data

save "Data\Temp\9_Gdp_cleaned.dta", replace

* Merge WVS and GDP data

use "Data\Temp\8_WVS_6_and_7_merged.dta", clear

* Convert the country variable to a string

decode country, gen(country_str)
drop country
rename country_str country

* Merge with GDP data using unique identifier

merge m:m unique_id using "Data\Temp\9_Gdp_cleaned.dta"

* Remove unmatched observations

drop if _merge != 3
drop _merge

* Save the final file

save "Data\Temp\10_merge_WVS_and_world_bank.dta", replace
save "Data\Final\Final_merge_world_bank_and_WVS_6", replace

******************************************************************************************
* Question 4 *
******************************************************************************************

* A]

use "Data\Temp\10_merge_WVS_and_world_bank.dta", clear

* OLS Estimation

regress GDP_growth trust_people trust_army trust_police trust_courts

save "Data\Temp\11_question_4_a.dta", replace

* B]

* Estimation with fixed effects by country

xtset country_numeric  
xtreg GDP_growth trust_people trust_army trust_police trust_courts, fe

save "Data\Temp\12_question_4_b.dta", replace

* C]

* Fixed effects model estimation and storing results

xtreg GDP_growth trust_people trust_army trust_police trust_courts, fe
estimates store fe

* Fixed-effects regression results: 
*  None of the trust variables (trust_people, trust_army, trust_police, trust_courts) ///
*   significantly affect GDP growth (all p-values > 0.2). 
*  The model explains only about 5% of the within-country variation (within R² = 0.05). ///
*  Low observations per country may affect the reliability of these estimates. /// 

* Random effects model estimation and storing results

xtreg GDP_growth trust_people trust_army trust_police trust_courts, re
estimates store re

* Random-effects GLS regression summary:
*  None of the trust variables (trust_people, trust_army, trust_police, trust_courts) ///
*   significantly affect GDP_growth (all p-values > 0.32). ///
*  The model has very low explanatory power (within R² = 0.0105, overall R² = 0.0214). /// 
*  Random effects are assumed uncorrelated with the regressors (rho = 0). ///

* Hausman test to compare fixed and random effects models

hausman fe re

* ------------------------------------------------
* FE coefficients:
*   trust_people = 176.63, trust_army = 64.85, trust_police = 312.37, trust_courts = -1630.97
*
* RE coefficients:
*   trust_people = 934.20, trust_army = 699.15, trust_police = -283.24, trust_courts = -411.78
*
* Difference (FE - RE) is not systematic:
*   chi2(4) = 2.65, p = 0.619
*
* We fail to reject the null hypothesis, indicating that the RE estimates are consistent.

save "Data\Temp\13_question_4_c.dta", replace

* D]

* OLS with education

regress GDP_growth trust_people trust_army trust_police trust_courts education_level

* Fixed effects with education

xtreg GDP_growth trust_people trust_army trust_police trust_courts education_level, fe

save "Data\Temp\14_question_4_d.dta", replace

* -------------------------------------------------
*  None of the predictors (trust_people, trust_army, trust_police, trust_courts, education_level)
*   significantly affect GDP_growth (all p-values >> 0.05).
*  The within R² is only 0.0512, indicating that about 5% of the variation in GDP_growth 
*   within countries is explained by the model.
*  The overall model F-test (F(5,33)=0.36, p=0.8743) is not significant.
*  The F-test for fixed effects (F(40,33)=0.82, p=0.7239) shows that country-specific effects 
*   are not statistically significant.
*  Very low average observations per group (avg = 1.9) may limit the reliability of these estimates.

* E]

* Check and install `estout` if necessary

cap which esttab
if _rc != 0 {
    ssc install estout
}

* Create the "Results" folder if it does not exist

cap mkdir Results

* Export results to LaTeX

esttab using "Results/regression_results.tex", replace ///
    title("Regression Results") ///
    label se ar2 star(* 0.10 ** 0.05 *** 0.01)

* Export results to Excel

esttab using "Results/regression_results.xls", replace ///
    title("Regression Results") ///
    label se ar2 star(* 0.10 ** 0.05 *** 0.01)

save "Data/Temp/15_question_4_e.dta", replace

******************************************************************************************
* Question 5 *
******************************************************************************************

use "Data\Temp\10_merge_WVS_and_world_bank", clear

drop if year => 2014

merge 1:1 _n using "Data\Temp\Gdp_cleaned.dta"

* Convert GDP from string to numeric

destring GDP, replace

* Create quartiles of the institutional trust index

xtile trust_quartile = trust_people, nq(4)

* Compute the average GDP for each country and each year, based on the trust quartile

collapse (mean) GDP trust_people, by(country year trust_quartile)

* Sort the data for better visualization

sort trust_quartile year country

* Plot GDP trends for each quartile

twoway (line GDP year if trust_quartile == 1, lcolor(blue) lwidth(medium)) ///
       (line GDP year if trust_quartile == 2, lcolor(green) lwidth(medium)) ///
       (line GDP year if trust_quartile == 3, lcolor(orange) lwidth(medium)) ///
       (line GDP year if trust_quartile == 4, lcolor(red) lwidth(medium)), ///
       legend(order(1 "Quartile 1 (faible confiance)" 2 "Quartile 2" 3 "Quartile 3" 4 "Quartile 4 (forte confiance)")) ///
       title("Évolution du PIB par quartile de confiance dans les institutions") ///
       xlabel(, grid) ylabel(, grid) ///
       xtitle("Année") ytitle("PIB moyen par pays")

* Save the graph in .gph and .png format

graph save "Results\gdp_trust_quartiles.gph", replace
graph export "Results\gdp_trust_quartiles.png", replace

* Save the dataset

save "Data\Temp\16_question_5.dta", replace

******************************************************************************************
*Bonus BY CHAT*
******************************************************************************************

* Estimation de la relation entre confiance envers les autres et revenu individuel

regress trust_people income

* Tracer la relation entre la confiance envers les autres et le revenu

twoway (scatter trust_people income, mcolor(blue)) 
       (lfit trust_people income, lcolor(red)), 
       title("Confiance envers les autres vs Revenu individuel") 
       xlabel(, grid) ylabel(, grid)

save "Data\Temp\17_question_bonus"

//////////////////////////////////////////////////////////////////////////////////////////













