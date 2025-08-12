program mlogitgof, rclass
	version 11

	/* =============================== */
	/* Deal with arguments and options */
	/* =============================== */
	syntax [if] [in] [,group(integer 10) all outsample table]	
	if `group' < 2 {
		display as error "The number of groups must be at least 2"
		error 498
	}
	if "`all'" ~= "" & ("`if'" ~= "" | "`in'" ~= "") {
		display as error "all option not allowed with if or in"
		error 198
	}
	local numgroups = `group' 	/* group will be used as a variable name later */

	
	/* ============================================================= */
	/* Check that the last estimation command was mlogit or logistic */
	/* ============================================================= */
	if "`e(cmd)'" == "mlogit" {
		local modelused "multinomial logistic"
		local baseoutcome = e(baseout)  /* The baseline outcome value */
		local numoutcomes = e(k_out)	/* The number of outcome values */
		matrix outcomevalues = e(out)	/* Matrix containing the outcome values */
	}
	else if "`e(cmd)'" == "logistic" {
		local modelused "binary logistic"
		local baseoutcome = 0  			/* The baseline outcome value */
		local numoutcomes = 2			/* The number of outcome values */
		matrix outcomevalues = (0, 1)	/* Matrix containing the outcome values */
	}
	else {
		error 321
	}
	local outcome = e(depvar)			/* The dependent variable */
	
	
	/* ========================= */
	/* Display descriptive title */
	/* ========================= */
	display as text _newline "Goodness-of-fit test for a `modelused' regression model"
	display as text "Dependent variable: `outcome'" _newline

	
	/* ===================================================== */
	/* Estimate the probabilities of each possible outcome.  */
	/* Figure out which sample to use based on the if and in */
	/* arguments and the all option.                         */
	/* ===================================================== */
	if "`modelused'" == "multinomial logistic" {
		forvalues i = 1/`numoutcomes' {
			local y = outcomevalues[1,`i']
			tempvar p`y'
			if "`all'" == "all" {
				quietly predict `p`y'', outcome(`y')
			}
			else if "`if'" == "" & "`in'" == "" {
				quietly predict `p`y'' if e(sample), outcome(`y')
			}
			else {
				quietly predict `p`y'' `if' `in', outcome(`y')
			}
		}
	}
	else {
		tempvar p0 p1
		if "`all'" == "all" {
				quietly predict `p1'
			}
		else if "`if'" == "" & "`in'" == "" {
			quietly predict `p1' if e(sample)
		}
		else {
			quietly predict `p1' `if' `in'
		}
		quietly gen `p0' = 1 - `p1'
	}
	

	/* ========================================================================= */
	/* Sort according to p = 1 - the estimated probability of the base outcome.  */
	/* Create numgroups groups with approximately numobs/numgroups observations. */
	/* ========================================================================= */
	tempvar p percentiles group
	quietly gen `p' = 1 - `p`baseoutcome''
	pctile `percentiles' = `p', nquantiles(`numgroups')
	xtile `group' = `p', cutpoints(`percentiles')
	quietly summarize `p'
	local numobs = r(N)		/* The number of observations */
	local maxp = r(max)		/* The maximum probability of p (used in the table) */
	
	
	/* ======================================== */
	/* The number of observations in each group */
	/* ======================================== */
	forvalues g = 1/`numgroups' {
		tempname total_`g'
		quietly egen `total_`g'' = total(`group' == `g')
	}


	/* ================================================================ */
	/* Create temporary dummy variables to identify group- and outcome- */
	/* specific observed and expected frequencies						*/
	/* ================================================================ */
	forvalues g = 1/`numgroups' {
		forvalues i = 1/`numoutcomes' {
			local y = outcomevalues[1,`i']
			tempvar O`g'_`y' E`g'_`y'
			quietly gen `O`g'_`y'' = 1 if `group' == `g' & `outcome' == `y'
			quietly gen `E`g'_`y'' = `p`y'' if `group' == `g'		
		}
	}


	/* ======================================================================== */
	/* Sum the observed and expected frequencies in each group for each outcome */
	/* ======================================================================== */
	forvalues g = 1/`numgroups' {
		forvalues i = 1/`numoutcomes' {
			local y = outcomevalues[1,`i']
			tempname Obs`g'_`y' Est`g'_`y'
			quietly egen `Obs`g'_`y'' = total(`O`g'_`y'')		
			quietly egen `Est`g'_`y'' = total(`E`g'_`y'')
		}
	}


	/* ======================================================== */
	/* Display contingency table (if the table option is given) */
	/* ======================================================== */
	_pctile `p', nquantiles(`numgroups')
	if "`table'" == "table" {
		display as text "Table: observed and expected frequencies"
		display as result "{c TLC}{hline 6}{c TT}{hline 8}" /*
			*/ _dup(`numoutcomes') "{c TT}{hline 14}" /*
			*/ "{c TT}{hline 7}{c TRC}" _newline "{c |}Group {c |}   Prob " _continue
		forvalues i = `numoutcomes'(-1)1 {
			local y = outcomevalues[1,`i']
			display as result "{c |}{center 7:Obs_`y'}"  "{center 7:Exp_`y'}" _continue
		}
		display as result "{c |} {center 6:Total}{c |}" _newline /*
			*/ "{c LT}{hline 6}{c +}{hline 8}" _dup(`numoutcomes') "{c +}{hline 14}" /*
			*/ "{c +}{hline 7}{c RT}" _continue
		forvalues g = 1/`numgroups' {
			if mod(`g'-1,5) == 0 & `g' > 1 {
				display as result _newline "{c LT}{hline 6}{c +}{hline 8}" /*
					*/ _dup(`numoutcomes') "{c +}{hline 14}" /*
					*/ "{c +}{hline 7}{c RT}" _continue
			}
			display as result _newline "{c |}" %5.0g `g' _continue
			if `g' < `numgroups' {
				display as result " {c |}" %7.4f r(r`g') _continue
			}
			else {
				display as result " {c |}" %7.4f `maxp' _continue
			}
			forvalues i = `numoutcomes'(-1)1 {
				local y = outcomevalues[1,`i']
				display as result " {c |}" %6.0g `Obs`g'_`y'' %7.2f `Est`g'_`y'' _continue
			}
			display as result " {c |}" %6.0g `total_`g'' " {c |}" _continue
		}
		display as result _newline "{c BLC}{hline 6}{c BT}{hline 8}" /*
			*/ _dup(`numoutcomes') "{c BT}{hline 14}" /*
			*/ "{c BT}{hline 7}{c BRC}"
	}


	/* ================================================ */
	/* Calculate the Pearson's chi-square statistic (T) */
	/* ================================================ */
	local T = 0
	forvalues g = 1/`numgroups' {	
		forvalues i = 1/`numoutcomes' {
			local y = outcomevalues[1,`i']
			local T = `T' + ((`Obs`g'_`y'' - `Est`g'_`y'')^2)/`Est`g'_`y''
		}
	}
	
	
	/* ================================================= */
	/* Degress of freedom. If outsample option is given, */
	/* adjust for outside estimation sample.			 */
	/* ================================================= */
	if "`outsample'" == "outsample" {
		local dof = `numgroups'*(`numoutcomes' - 1)
	}
	else {
		local dof = (`numgroups' - 2)*(`numoutcomes' - 1)
	}


	/* ===================================================== */
	/* Two-tailed P-value using the chi-squared distribution */
	/* ===================================================== */
	local prob = chi2tail(`dof', `T')

														
	/* =============================================== */
	/* Display results and some descriptive statistics */
	/* =============================================== */
	display as text %27s "number of observations = " %6.0g as result `numobs'
	display as text %27s "number of outcome values = " %6.0g as result `numoutcomes'
	display as text %27s "base outcome value = " %6.0g as result `baseoutcome'
	display as text %27s "number of groups = " %6.0g as result `numgroups'
	display as text %27s "chi-squared statistic = " %10.3f as result `T'
	display as text %27s "degrees of freedom = " %6.0g as result `dof'
	display as text %27s "Prob > chi-squared = " %10.3f as result `prob'

	
	/* ===================== */
	/* Return results in r() */
	/* ===================== */
	return scalar N = `numobs'
	return scalar g = `numgroups'
	return scalar chi2 = `T'
	return scalar df = `dof'
	return scalar P = `prob'
	
end
