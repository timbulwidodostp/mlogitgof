{smcl}
{* *! version 0.0.2 9May2011}{...}
{cmd:help mlogitgof}{right: ({browse "http://www.stata-journal.com/article.html?article=st0269":SJ12-3: st0269})}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:mlogitgof} {hline 2}}Goodness-of-fit test for multinomial logistic regression models


{title:Syntax}

{p 8 17 2}{cmdab:mlogitgof} {ifin} [{cmd:,} {it:options}]

{synoptset 12}{...}
{synopthdr}
{synoptline}
{synopt:{opt group(#)}}group the observations using {it:#} quantiles; default is {cmd:group(10)}{p_end}
{synopt:{opt all}}execute test for all observations in the data{p_end}
{synopt:{opt outsample}}adjust degrees of freedom for samples outside estimation sample{p_end}
{synopt:{opt table}}display table of observed and expected frequencies {p_end}
{synoptline}


{title:Description}

{pstd}{cmd:mlogitgof} is a goodness-of-fit test for multinomial logistic
regression models (see {helpb mlogit}).  It can also be used for ordinary
(binary) logistic regression models (see {helpb logistic}) to produce the
same results as the Hosmer-Lemeshow goodness-of-fit test (see 
{helpb logistic postestimation##estatgof:estat gof}).


{title:Options}

{phang}{opt group(#)} specifies the number of quantiles to be used to
group the observations.  The default is {cmd:group(10)}.

{phang}{opt all} requests that the goodness-of-fit test be computed for
all observations in the data, ignoring any {cmd:if} or {cmd:in} 
qualifiers specified with {cmd:mlogit} or {cmd:logistic}.

{phang}{opt outsample} adjusts the degrees of freedom for the
goodness-of-fit test for samples outside the estimation sample.

{phang}{opt table} displays a table of the groups used for the
goodness-of-fit test that lists the predicted probabilities, observed
and expected counts for all outcomes, and totals for each group.


{title:Remarks}

{pstd}{cmd:mlogitgof} computes a goodness-of-fit test for multinomial
(or polytomous) logistic regression models (Fagerland, Hosmer, and Bofin
2008).  The command can be used after estimating a multinomial logistic
regression model with {cmd:mlogit} or a (binary) logistic regression
model with {cmd:logistic}.  The syntax, options, and output of the
command are similar to that of the postestimation command 
{cmd:estat gof}.

{pstd}The test is based on a strategy of sorting the observations
according to the complement of the estimated probability of the
reference outcome.  We then form g groups, each containing approximately
n/g observations, where n is the total number of
observations.  For each group, we calculate the sums of the observed and
estimated frequencies for each outcome category.  The observed and
estimated frequencies can be tabulated using groups as rows and outcome
categories as columns.  The multinomial goodness-of-fit test statistic
is the Pearson's chi-squared statistic from this g x c contingency
table.


{title:Examples}

{phang}{cmd: . mlogitgof}

{phang}{cmd: . mlogitgof, group(8) table}

{phang}{cmd: . mlogitgof if age < 40, table}


{title:Saved results}

{pstd}
{cmd:mlogitgof} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(g)}}number of groups{p_end}
{synopt:{cmd:r(chi2)}}chi-squared{p_end}
{synopt:{cmd:r(df)}}degrees of freedom{p_end}
{synopt:{cmd:r(P)}}probability greater than chi-squared{p_end}


{title:Reference}

{phang}Fagerland, M. W., D. W. Hosmer, and A. M. Bofin. 2008.  Multinomial
goodness-of-fit tests for logistic regression models.
{it:Statistics in Medicine} 27: 4238-4253.


{title:Authors}

{pstd}Morten W. Fagerland{p_end}
{pstd}Unit of Biostatistics and Epidemiology{p_end}
{pstd}Oslo University Hospital{p_end}
{pstd}Oslo, Norway{p_end}
{pstd}morten.fagerland@medisin.uio.no

{pstd}David W. Hosmer{p_end}
{pstd}Department of Public Health{p_end}
{pstd}University of Massachusetts-Amherst{p_end}
{pstd}Amherst, MA


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 12, number 3: {browse "http://www.stata-journal.com/article.html?article=st0269":st0269}

{p 4 14 2}{space 1}Manual:  {manlink R mlogit}{break}
{bf:{mansection R logisticpostestimationSyntaxforestatgof:[R] logistic postestimation}}

{p 4 14 2}{space 3}Help:  {helpb mlogit}, {helpb logistic postestimation##estatgof:estat gof} {p_end}
