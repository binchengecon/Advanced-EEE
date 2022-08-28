	// Environment
    clear all
	cd "C:\Users\33678\Desktop\Deeqa_EEE\Advanced econometrics and empirical economics\Part 1\Assisgnment\Solution"
	use "data_assignment.dta", clear

	log using "Log_BinCHENG",replace


	// Question 1

	***************Period 1******************
		sum male ability_math ability_language parentcollege school degree  if period==1
		eststo sum_period1: quietly estpost summarize male ability_math ability_language parentcollege school degree  if period==1
		
		
		corr male ability_math ability_language parentcollege school degree if period==1
		eststo corr_period1: quietly estpost corr male ability_math ability_language parentcollege school degree  if period==1,matrix 
		
		reg school male ability_math ability_language parentcollege if period==1
		eststo reg_period1_HS: quietly regress  school male ability_math ability_language parentcollege if period==1
		
		reg degree male ability_math ability_language parentcollege if period==1 & school==1
		eststo reg_period1_De: quietly regress  degree male ability_math ability_language parentcollege if period==1 & school==1

	***************Period 2****************** add dist

		sum male ability_math ability_language parentcollege school degree 	dist	if period==2
		eststo sum_period2: quietly estpost summarize male ability_math ability_language parentcollege school degree dist if period==2
		
		corr male ability_math ability_language parentcollege school degree  dist if period==2
		eststo corr_period2: quietly estpost correlate  male ability_math ability_language parentcollege school degree dist if period==2,matrix 

		reg school male ability_math ability_language parentcollege dist if period==2 & degree==1 
		eststo reg_period2_Col: quietly regress  school male ability_math ability_language parentcollege dist if period==2 & degree==1 

		
		**************Latex Table Produce
		
		esttab sum_period1 sum_period2  using "Part1_SumTable.tex" , cells(mean(fmt(6)) ) replace mtitle("t=1""t=2")  nonumbers collabels(none)
		esttab reg_period1_HS reg_period1_De reg_period2_Col using "Part1_RegTable.tex", replace mtitle("HighSchool""HighSchoolDegree""College") collabels(none) nonumbers se
		esttab corr_period1 using corr_period1.tex, replace unstack not noobs nonote b(3) nostar mtitle("t=1")  nonumbers 
		esttab corr_period2 using corr_period2.tex, replace unstack not noobs nonote b(3) nostar mtitle("t=2")  nonumbers 
		
		
	// Question 2
	
	// Question 2.c
	***************Period 1******************
	
	***************HighSchool Decision********
	capture drop ST_HS_Prob
	logit school male ability_math ability_language parentcollege if period==1
	est sto ST_HS
	predict ST_HS_Prob  
	
	eststo logit_period1_HS: quietly logit  school male ability_math ability_language parentcollege if period==1

	***************HighSchoolDegree Probability**
	capture drop ST_HSDegree_Prob
	logit degree male ability_math ability_language parentcollege if period==1 & school==1
	est sto ST_HSDegree
	predict ST_HSDegree_Prob 
			
	eststo logit_period1_HSDe: quietly logit degree male ability_math ability_language parentcollege if period==1 & school==1
	***************Period 2******************
	
	***************College Decision********
	capture drop ST_Col_Prob
	logit school male ability_math ability_language parentcollege dist if period==2 & degree==1
	est sto ST_Col
	predict ST_Col_Prob  
	
	eststo logit_period2_Col: quietly logit school male ability_math ability_language parentcollege dist if period==2 & degree==1
	
	esttab logit_period1_HS logit_period1_HSDe logit_period2_Col using "Part2_logitTable.tex", replace mtitle("HighSchool""HighSchoolDegree""College") collabels(none) nonumbers se noomitted 

	// Question 2.d 
	
		display -_b[parentcollege]/_b[dist]
		
	// Question 2.e and f

	
	
	***************Benchmark***************
	
	* College Enrollement Benchmark: presented in probability of going to college
	
	gen ST_ColEnr_BM =(ST_HS_Prob)*(ST_HSDegree_Prob)*(ST_Col_Prob)
	
	***************Counterfactual 1********
	*** dist*0=0
		estimates restore ST_Col
			
		gen ST_Col_Prob_CF1=invlogit(_b[_cons]+_b[male]*male+_b[ability_math]*ability_math+_b[ability_language]*ability_language+_b[parentcollege]*parentcollege +_b[dist]*0) 						
	
		gen ST_ColEnr_CF1 =(ST_HS_Prob)*(ST_HSDegree_Prob)*(ST_Col_Prob_CF1)
							  
	**************Counterfactual 2****
		gen ST_ColEnr_CF2 =(ST_HS_Prob)*(ST_HSDegree_Prob)*(ST_Col_Prob)*0.5

		************Latex table output
		
		gen ST_ColEnr_Diff_BM_CF1 = ST_ColEnr_CF1- ST_ColEnr_BM
		gen ST_ColEnr_DiffRatio_BM_CF1 = ( ST_ColEnr_CF1- ST_ColEnr_BM)/ST_ColEnr_BM	
		gen ST_ColEnr_Diff_BM_CF2 = ST_ColEnr_CF2- ST_ColEnr_BM
		gen ST_ColEnr_DiffRatio_BM_CF2 = ( ST_ColEnr_CF2- ST_ColEnr_BM)/ST_ColEnr_BM			

		gen ST_HS_BM = ST_HS_Prob
		gen ST_HS_CF1 = ST_HS_BM
		gen ST_HS_CF2 = ST_HS_BM
		gen ST_HS_Diff_BM_CF1 = ST_HS_BM- ST_HS_CF1
		gen ST_HS_Diff_BM_CF2 = ST_HS_BM- ST_HS_CF2
		
		gen ST_ColEnr_DiffRatio_BM_CF2 = ( ST_ColEnr_CF2- ST_ColEnr_BM)/ST_ColEnr_BM	
		eststo sum_ColEnr_period1: quietly estpost summarize ST_ColEnr_BM ST_ColEnr_CF1 ST_ColEnr_CF2 ST_ColEnr_Diff_BM_CF1 ST_ColEnr_Diff_BM_CF2   if period==1
		eststo sum_HS_period1: quietly estpost summarize ST_HS_BM ST_HS_CF1 ST_HS_CF2 ST_HS_Diff_BM_CF1 ST_HS_Diff_BM_CF2   if period==1

		// 		eststo sum_ColEnr_period2: quietly estpost summarize ST_ColEnr_BM ST_ColEnr_Diff_BM_CF1 ST_ColEnr_Diff_BM_CF2 if period==2
		esttab sum_ColEnr_period1   using "Part2_SumColEnrTable.tex" , cells(mean(fmt(6)) ) replace mtitle("t=1")  nonumbers collabels(none)
		esttab sum_HS_period1   using "Part2_SumHSTable.tex" , cells(mean(fmt(6)) ) replace mtitle("t=1")  nonumbers collabels(none)

	
	    // Question 3
	
	    // Question 3.c
		
		gen eulerC = -digamma(1)
		
		estimates restore ST_Col 
		
		gen v_i12_De= (_b[_cons]+_b[male]*male+_b[ability_math]*ability_math+_b[ability_language]*ability_language +_b[parentcollege]*parentcollege +_b[dist]*dist)
		gen v_i02_De=0
		gen v_i2_NonDe =0
		
		gen Exp_V2_d1_HS= (ST_HSDegree_Prob)*(eulerC+ln(exp(v_i12_De)+exp(v_i02_De))) 	+(1-ST_HSDegree_Prob)*(eulerC+ln(exp(v_i2_NonDe)) )

		
	
		constraint 1 Exp_V2_d1_HS=0.95
		logit school male ability_math ability_language parentcollege Exp_V2_d1_HS if period==1, constraint(1) 
		est sto DY_HS
		predict DY_HS_Prob
	
		gen DY_ColEnr_BM =(DY_HS_Prob)*(ST_HSDegree_Prob)*(ST_Col_Prob) 
		sum school DY_ColEnr_BM  if period==2
	
	
	
	
		/// Question 3.e and f
		
		**************Counterfactual 1*********
		est restore ST_Col
		
		gen v_i12_De_CF1= _b[_cons]+_b[male]*male	+_b[ability_math]*ability_math+_b[ability_language]*ability_language +_b[parentcollege]*parentcollege +_b[dist]*0
		gen v_i02_De_CF1=0
		gen v_i2_NonDe_CF1 =0
		
		gen Exp_V2_d1_HS_CF1= ST_HSDegree_Prob*(eulerC+ln(exp(v_i12_De_CF1)+exp(v_i02_De_CF1))) +(1-ST_HSDegree_Prob)*(eulerC+ln(exp(v_i2_NonDe_CF1)) )
		gen DY_Col_Prob_CF1 = invlogit(v_i12_De_CF1) 
		
		est restore DY_HS
		
		gen DY_HS_Prob_CF1 = _b[_cons]+_b[male]*male	+_b[ability_math]*ability_math+_b[ability_language]*ability_language +_b[parentcollege]*parentcollege + _b[Exp_V2_d1_HS]*Exp_V2_d1_HS_CF1
		replace DY_HS_Prob_CF1 = invlogit(DY_HS_Prob_CF1)
		
		gen DY_ColEnr_CF1 =(DY_HS_Prob_CF1)*(ST_HSDegree_Prob)*(DY_Col_Prob_CF1) 
		
		//Note that degree obtaining is invariant to distance change so we keep using degree obtaining probability in static case
		
		************Counterfactual 2************
		
		// Note that degree obtaining is again unaffected
		
		est restore ST_Col

		gen v_i12_De_CF2= _b[_cons]+_b[male]*male	+_b[ability_math]*ability_math+_b[ability_language]*ability_language +_b[parentcollege]*parentcollege +_b[dist]*dist
		gen v_i02_De_CF2=0
		gen v_i2_NonDe_CF2 =0		
		gen Exp_V2_d1_HS_CF2= 1/2*ST_HSDegree_Prob*(eulerC+ln(exp(v_i12_De_CF2)+exp(v_i02_De_CF2))) +(1-1/2*ST_HSDegree_Prob)*(eulerC+ln(exp(v_i2_NonDe_CF2)) )
		gen DY_Col_Prob_CF2 = invlogit(v_i12_De_CF2)*1/2 		
		
		est restore DY_HS
		
		gen DY_HS_Prob_CF2 = _b[_cons]+_b[male]*male	+_b[ability_math]*ability_math+_b[ability_language]*ability_language +_b[parentcollege]*parentcollege + _b[Exp_V2_d1_HS]*Exp_V2_d1_HS_CF2
		replace DY_HS_Prob_CF2 = invlogit(DY_HS_Prob_CF2)
		
		gen DY_ColEnr_CF2 =(DY_HS_Prob_CF2)*(ST_HSDegree_Prob)*(DY_Col_Prob_CF2) 		
		
		gen DY_ColEnr_Diff_BM_CF1 = DY_ColEnr_CF1 - DY_ColEnr_BM
		gen DY_ColEnr_Diff_BM_CF2 = DY_ColEnr_CF2 - DY_ColEnr_BM
		gen DY_ColEnr_DiffRatio_BM_CF1 = DY_ColEnr_Diff_BM_CF1/DY_ColEnr_BM
		gen DY_ColEnr_DiffRatio_BM_CF2 = DY_ColEnr_Diff_BM_CF2/DY_ColEnr_BM

		eststo sum_DY_ColEnr: quietly estpost summarize DY_ColEnr_BM DY_ColEnr_CF1 DY_ColEnr_CF2 DY_ColEnr_Diff_BM_CF1 DY_ColEnr_Diff_BM_CF2   if period==1
		
		esttab sum_DY_ColEnr   using "Part3_SumColEnrTable.tex" , cells(mean(fmt(6)) ) replace mtitle("t=1")  nonumbers collabels(none)
		
		gen DY_HS_BM = DY_HS_Prob
		gen DY_HS_CF1 = DY_HS_Prob_CF1
		gen DY_HS_CF2 = DY_HS_Prob_CF2
		gen DY_HS_Diff_BM_CF1 = DY_HS_CF1-DY_HS_BM
		gen DY_HS_Diff_BM_CF2 = DY_HS_CF2-DY_HS_BM
		

		eststo sum_DY_HS: quietly estpost summarize DY_HS_BM DY_HS_CF1 DY_HS_CF2 DY_HS_Diff_BM_CF1 DY_HS_Diff_BM_CF2   if period==1

		// 		eststo sum_ColEnr_period2: quietly estpost summarize ST_ColEnr_BM ST_ColEnr_Diff_BM_CF1 ST_ColEnr_Diff_BM_CF2 if period==2
		esttab sum_DY_HS   using "Part3_SumHSTable.tex" , cells(mean(fmt(6)) ) replace mtitle("t=1")  nonumbers collabels(none)

		
		// Question 4
		
		gen v_i2_NonDe_CCP = 0 // If non-degreed, no chance to make any choice, j'=j
		gen v_i02_De_CCP       =0 
		gen Exp_V2_d1_HS_CCP = (ST_HSDegree_Prob)*(eulerC+v_i02_De_CCP-ln(1-ST_Col_Prob)) 	+(1-ST_HSDegree_Prob)*(eulerC+v_i2_NonDe_CCP-ln(exp(v_i2_NonDe_CCP)/exp(v_i2_NonDe_CCP)) )
		
		constraint 2 Exp_V2_d1_HS_CCP=0.95
		logit school male ability_math ability_language parentcollege Exp_V2_d1_HS_CCP if period==1 , constraint(2)
		est sto DY_HS_CCP
		
		esttab DY_HS DY_HS_CCP using "Part4_logitTable.tex", replace mtitle("Structural Estimation""CCP Estimation") collabels(none) nonumbers se noomitted 

log close