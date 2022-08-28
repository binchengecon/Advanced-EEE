/* Information*/

* Author: Bin CHENG
* Date: 2022/02/24
* Supervisor: Christina Brown

* Notice1 No Change Needed: 
*     there is no need to change working directory if you directly
*     open the do file by double cliking, or if you open the do file by
*     right click with edit.


/* Environment Setting */

clear all
set more off
capture log close


/* Log File */

global logdate: display %tdCCYYNNDD date("$S_DATE","DMY")
log using "..\Logfile\Solution_BinCHENG_$logdate", replace

/* Part 1: Variable Creation */

* 1): merge main dataset with additional questionaire table

* 1.1) about i.dta

use ..\Data\i_RH13,clear

duplicates report
duplicates drop

save  ..\Data\i_RH13,replace


use ..\Data\i, clear

*		generate unique tag

gen id13 = substr(iid,1,2)
gen id59 = substr(iid,5,4)
gen rar00 = substr(iid,10,2)

d rar00,s
destring rar00,replace

order iid id13 id59 rar00


duplicates report
		//No dup
*			merge with RH13 date of birth and sex for children died

merge iid using "..\Data\i_RH13",_merge(merge13)
*			here we can only keep the parents with lost children. 
*			but since inclusion doesn't affect final result
*			we don't drop and keep all.
tab merge13
		// 15,584 both in R and Rh13. 21,966 R only

*			keep the result 

save ..\Data\samplei,replace

* 1.2) about r.dta
use ..\Data\R_AR_01,clear

duplicates report
duplicates drop

save  ..\Data\R_AR_01,replace

use ..\Data\r,clear

*		generate unique tag

gen id13 = substr(rid,1,2)
gen id59 = substr(rid,5,4)

order rid id13 id59

duplicates report
		//No dup

*			merge with AR01 rar00 for merging with samplei.dta

joinby rid using ..\Data\R_AR_01,_merge(merge01)


order rid id13 id59 rar00

save ..\Data\sampler,replace

* 1.3) merge i and r dataset

use ..\Data\samplei,clear

joinby id13 id59 rar00 using ..\Data\sampler,_merge(mergeir)

tab mergeir
		// all obs in both i and r, sample is perfectly balanced
*		save the result
save ..\Data\samplefull,replace



* 2): Variable Creation

use ..\Data\samplefull,clear

* typo of variable name

rename ibh15_n irh15_n

order irh15* irh12*, after(rar00)

* 2.1) 0-28 die and born 1-12 months ago

*		create born 1-12 months ago baed on : irh13_mm month irh13_yy year & rivw_*

tab irh13_mm,mi
tab irh13_yy,mi

		// need to get rid of .* as .
		
replace 	irh13_mm =. if irh13_mm==.y|irh13_mm==.z
replace     irh13_yy =. if irh13_yy ==.y 	

tab irh13_mm,mi
tab irh13_yy,mi

gen irh13_mm_m = missing(irh13_mm)
gen irh13_yy_m = missing(irh13_yy)

tab irh13_mm_m irh13_yy_m
		// a bit of problem we have month . but year not .
		// my resort: focus on group1
		// group1: month year not missing 83,961
tab irh13_yy if irh13_mm_m==0&  irh13_yy_m==0 
*		we also give a view on group2 where only month missing
		// group2: month missing and year not missing 51,704
tab irh13_yy if irh13_mm_m==1&  irh13_yy_m==0 

* define for those unfortunate parents with credible record of year and month
* 1 means with 1-12 months ago
gen temp_month = 0 if irh11==1 & irh13_mm_m==0&  irh13_yy_m==0 

replace temp_month = 1 if 12*(rivw_yy_1-irh13_yy)+rivw_mm_1- irh13_mm>=1 & 12*(rivw_yy_1-irh13_yy)+rivw_mm_1- irh13_mm<=12 & irh11==1 & irh13_mm_m==0&  irh13_yy_m==0 

* InfantMortality0_28_days take value 1 if die in 28 and 0 if not for those 1-12 months ago born
gen InfantMortality0_28_days =.

replace InfantMortality0_28_days=0 if temp_month ==1

replace InfantMortality0_28_days=1 if irh15_u==1 & temp_month ==1

replace InfantMortality0_28_days=1 if irh15_u==2 & temp_month ==1

replace InfantMortality0_28_days=1 if irh15_u==3& irh15_n<=28 & temp_month ==1


* 2.2) 1 year die and born 12-24 months ago

* define for those unfortunate parents with credible record of year and month
* 1 means with 12-24 months ago

gen temp_month2 = 0 if irh11==1& irh13_mm_m==0&  irh13_yy_m==0 

replace temp_month2 = 1 if 12*(rivw_yy_1-irh13_yy)+rivw_mm_1- irh13_mm<=24 & 12*(rivw_yy_1-irh13_yy)+rivw_mm_1- irh13_mm>=12 & irh13_mm_m==0&  irh13_yy_m==0 & irh11==1 


* InfantMortality0_1_year take value 1 if die in 1st year and 0 if not for those 12-24 months ago born

gen InfantMortality0_1_year = .

replace InfantMortality0_1_year=0 if   temp_month ==1

replace InfantMortality0_1_year=1 if irh15_u==1 & temp_month2 ==1
				
replace InfantMortality0_1_year=1 if irh15_u==2 |irh15_u==3 & temp_month2 ==1

* sum irh15_n if irh15_u==3
* we find days are maximum at 60 therefore safe
// 
replace InfantMortality0_1_year=1 if irh15_u==4 & irh15_n<=12 & temp_month2 ==1

replace InfantMortality0_1_year=1 if (irh15_u==5 & irh15_n<=1)& temp_month2 ==1
	
	
* 2.3) female

gen female = 0

replace female =1 if irh14==3


/* Part 2: Summarize and Regression*/

tab  InfantMortality0_28_days  female
tab  InfantMortality0_1_year female


reg InfantMortality0_28_days female,robust
est sto est1

reg InfantMortality0_1_year female,robust
est sto est2

esttab est1 est2 using ..\Output\regression.tex, tex replace

save ..\Output\final,replace


log close
