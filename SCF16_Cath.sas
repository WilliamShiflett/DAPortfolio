/********************************************************************************/
/* File Name: SCF16_Cath.sas      						*/
/* Created by: William Shiflett     						*/
/* Created on: 10/13/17               						*/
/* Purpose: Exploratory data analysis for 2016 SCF				*/
/* Last Run: 11/1/17               						*/
/********************************************************************************/


libname OUT 'V:\OED\OED_Public\PPI\William\exploratoryAnalysis';
filename IN16 'V:\OED\OED_Public\PPI\William\scfData\compressed\scf2016';

Proc CIMPORT DATA=OUT.fullSCF16 INFILE=IN16;
run;

proc format;
	value RACECL4_format  		1="White non-Hispanic" 
					   			2="Black/African-American non-Hispanic" 
					   			3="Hispanic or Latino"
      				   			4="Other or Multiple Race";
	value ageCat_format			1="Younger than 25"
								2="25-49"
								3="50-64"
								4="65-74"
								5="75 and Older";
	value incQuint_format		1="Less than $27999"
								2="$28000 to $47999"
								3="$48000 to $75999"
								4="$76000 to $122999"
								5="$123000 or more";
	value allBinaries_format	0="No"
								1="Yes";
	value oneFiveZero_format	0="Inappropriate"
								1="Yes"
								5="No";
	value fullOrPartTime_format	1="Respondent (or Spouse and Respondent both) work(s) full time"
								2="One partner works full time and the other works part time"
								3="Respondent (or Spouse and Respondent both) work(s) part-time "
								0="Inappropriate";
	value emerg_format			1="BORROW MONEY"
                     			2="SPEND OUT OF SAVINGS/INVESTMENTS"
                     			3="POSTPONE PAYMENTS"
                     			4="CUT BACK"
                    			low-<0="OTHER"
                     			0= "Inap. (spending exceeded income: X7510=1)";
	value emergSource_format	1="Savings account"
			                    2="Stocks, bonds, CDs, or other financial assets"
			                    3="Home Equity loan or line of credit"
			                    4="Pension or Retirement Accounts"
			                    5="Automobile"
			                    6="Real Estate"
			                    7="Durable goods"
			                    8="Other miscellaneous valuables"
			                    9="Business(es)"
			                    low-<0="OTHER"
			                    0="Inap. (spending exceeded income: X7510=1; would not spend out of
			                            savings/investments to make up difference: X7775^=2)";
	value liqAdeq400_format		0="Less than $400 in Liquid Savings"
								1="$400 or More in Liquid Savings";
	value liqAdeq2000_format	0="Less than $2,000 in Liquid Savings"
								1="$2,000 or More in Liquid Savings";
	value hliq_format			0="Does not have any liquid savings"
								1="Has some liquid savings";
run;

/*Use some summary variables created by the Federal Reserve (https://www.federalreserve.gov/econres/files/bulletin.macro.txt)*/

data out.SCF16;
	set OUT.fullscf16;
	WGT=X42001/5;

*	Calculate pre-tax, pre-deduction income from all sources;
	INCOME=MAX(0,X5729);
*	Create four race or ethnicity classes;	
	RACECL4=1*(X6809=1 & X6810=5)+2*(X6809=2 & X6810=5)+3*(X6809=3 & X6810=5)+4*(X6809=-7 | X6810=1);
*	Determine if head of household is in labor force, i.e., at least one person in PEU in labor force;
	IF ((X4100 >=50 & X4100 <= 80)| X4100=97) THEN LF=0;
      ELSE LF=1;
*   sum of all checking accounts other than money market;
    CHECKING=MAX(0,X3506)*(X3507=5)+MAX(0,X3510)*(X3511=5)
      +MAX(0,X3514)*(X3515=5)+MAX(0,X3518)*(X3519=5)
      +MAX(0,X3522)*(X3523=5)+MAX(0,X3526)*(X3527=5)
      +MAX(0,X3529)*(X3527=5);
*   frequency and combined balance of prepaid debit cards and prepaid government benefit cards);
    PREPAID=MAX(0,X7596);
    HPREPAID=(((X7594=1)+(X7648=1))>0);
	HPREPAIDDEB=((X7594=1)>0);
	HPREPAIDGOV=((X7648=1)>0);
*   savings accounts;
    SAVING=MAX(0,X3730*(X3732 NOT IN (4 30)))
      +MAX(0,X3736*(X3738 NOT IN (4 30)))
      +MAX(0,X3742*(X3744 NOT IN (4 30)))+MAX(0,X3748*(X3750 NOT IN (4 30)))
      +MAX(0,X3754*(X3756 NOT IN (4 30)))+MAX(0,X3760*(X3762 NOT IN (4 30)))
      +MAX(0,X3765);
*   have savings account: 1=yes, 0=no;
    HSAVING=(SAVING>0);
*   money market deposit accounts;
*   NOTE: includes money market accounts used for checking and other
    money market account held at commercial banks, savings and
    loans, savings banks, and credit unions;
    MMDA=MAX(0,X3506)*((X3507=1)*(11<=X9113<=13))
      +MAX(0,X3510)*((X3511=1)*(11<=X9114<=13))
      +MAX(0,X3514)*((X3515=1)*(11<=X9115<=13))
      +MAX(0,X3518)*((X3519=1)*(11<=X9116<=13))
      +MAX(0,X3522)*((X3523=1)*(11<=X9117<=13))
      +MAX(0,X3526)*((X3527=1)*(11<=X9118<=13))
      +MAX(0,X3529)*((X3527=1)*(11<=X9118<=13))
      +MAX(0,X3730*(X3732 IN (4 30))*(X9259>=11 & X9259<=13))
      +MAX(0,X3736*(X3738 IN (4 30))*(X9260>=11 & X9260<=13))
      +MAX(0,X3742*(X3744 IN (4 30))*(X9261>=11 & X9261<=13))
      +MAX(0,X3748*(X3750 IN (4 30))*(X9262>=11 & X9262<=13))
      +MAX(0,X3754*(X3756 IN (4 30))*(X9263>=11 & X9263<=13))
      +MAX(0,X3760*(X3762 IN (4 30))*(X9264>=11 & X9264<=13))
      +MAX(0,X3765*(X3762 IN (4 30))*(X9264>=11 & X9264<=13));
*   money market mutual funds;
*   NOTE: includes money market accounts used for checking and other
    money market account held at institutions other than commercial
    banks, savings and loans, savings banks, and credit unions;
    MMMF=MAX(0,X3506)*(X3507=1)*(X9113<11|X9113>13)
      +MAX(0,X3510)*(X3511=1)*(X9114<11|X9114>13)
      +MAX(0,X3514)*(X3515=1)*(X9115<11|X9115>13)
      +MAX(0,X3518)*(X3519=1)*(X9116<11|X9116>13)
      +MAX(0,X3522)*(X3523=1)*(X9117<11|X9117>13)
      +MAX(0,X3526)*(X3527=1)*(X9118<11|X9118>13)
      +MAX(0,X3529)*(X3527=1)*(X9118<11|X9118>13)
      +MAX(0,X3730*(X3732 IN (4 30))*(X9259<11|X9259>13))
      +MAX(0,X3736*(X3738 IN (4 30))*(X9260<11|X9260>13))
      +MAX(0,X3742*(X3744 IN (4 30))*(X9261<11|X9261>13))
      +MAX(0,X3748*(X3750 IN (4 30))*(X9262<11|X9262>13))
      +MAX(0,X3754*(X3756 IN (4 30))*(X9263<11|X9263>13))
      +MAX(0,X3760*(X3762 IN (4 30))*(X9264<11|X9264>13))
      +MAX(0,X3765*(X3762 IN (4 30))*(X9264<11|X9264>13));
*   all types of money market accounts;
    MMA=MMDA+MMMF;
*   have any type of money market account: 1=yes, 0=no;
    HMMA=(MMA>0);
*   call accounts at brokerages;
    CALL=MAX(0,X3930);
*   have call account: 1=yes, 0=no;
    HCALL=(CALL>0);
*   all types of transactions accounts (liquid assets);
    LIQ=CHECKING+SAVING+MMA+CALL+PREPAID;
*	have any types of transactions accounts: 1=yes, 0=no;
*   here include even accounts with zero reported balances;
	HLIQ=(LIQ>0 | X3501=1 | X3701=1 | X3801=1 | X3929=1);
	LIQ=MAX(HLIQ,LIQ);
*   Included in any pension through current or previous work - do not include pensions PEU is making withdrawls from;
	ANYPEN=(X4135=1|X4735=1|X5601=1);
	CURRPEN=X6462+X6467+X6472+X6477+X6957;
*   total quasi-liquid: sum of IRAs, thrift accounts, and future pensions; 
*   this version does not include currently received benefits;
    RETQLIQ=IRAKH+THRIFT+FUTPEN;
*   have quasi-liquid assets: 1=yes, 0=no;
    HRETQLIQ=(RETQLIQ>0);

*	Ownership of different types of IRAs - do not include Keoghs due to higher limit - at PEU level (i.e., respondent, spouse, other family member);
*	Included if at least one person in the PEU has a given type of IRA;
	PEUHROTHIRA=(X6444=1|X6448=1|X6452=1);
	PEUHROLLOVERIRA=(X6446=1|X6450=1|X6454=1);
	PEUHREGIRA=(X6447=1|X6451=1|X6455=1);
*	Did anyone in the PEU contribute to an IRA in 2015 (i.e., respondent, spouse, other family member)?;
	PEUIRACONTRFREQ2015=(X6791=1|X6793=1|X6795=1);

*	Total Contribution to IRA by all members of PEU in 2015;


*	Respondent IRA variables;
	RHROTHIRA=(X6444=1);
	RROTHIRABAL=MAX(0,X6551);
	RHROLLIRA=(X6446=1);
	RROLLIRABAL=MAX(0,X6552);
	RHREGIRA=(X6447=1);
	RREGIRABAL=MAX(0, X6553);


*	Spouse IRA variables;
	SHROTHIRA=(X6448=1);
	SROTHIRABAL=MAX(0,X6559);
	SHROLLIRA=(X6450=1);
	SROLLIRABAL=MAX(0,X6560);
	SHREGIRA=(X6451=1);
	SREGIRABAL=MAX(0,X6561);


*	Other PEU memebers IRA variables;
	OHROTHIRA=(X6452=1);
	OROTHIRABAL=MAX(0,X6567);
	OHROLLIRA=(X6454=1);
	OROLLIRABAL=MAX(0,X6568);
	OHREGIRA=(X6455=1);
	OREGIRABAL=MAX(0,X6569);

	IF (X8023 IN (1 2)) THEN MARRIED=1;
    ELSE MARRIED=2;

*	WSAVED: 1=spending exceeded income, 2=spending equaled income,
    3=spending less than income;
*	SAVED: 1=spent less than income, 0=all others;

	IF (X7508>0) THEN WSAVED=X7508;
      ELSE IF (X7510=2 & X7509=1) THEN WSAVED=3;
      ELSE WSAVED=X7510;
    SAVED=(WSAVED=3);

*   NOTE: multiple saving reasons may be reported: here choosing only
    first (most important) reason (X3006)
	The SCF calls this saving for "Liquidity / The Future"- 
	this includes   23.     Reserves in case of unemployment
                    24.     In case of illness- medical/dental expenses
                    25.     Emergencies- "rainy days"- other unexpected needs-
                            for "security" and independence
					32.     "For the future"
					92.     Liquidity- to have cash available/on hand
                    93.     "Wealth preservation"- maintain lifestyle;

*	Use most important saving reasons enumerated above and saving attitudinal variable (SAVED) 
	to create emergency saving binary variabl (EMSAVBIN);

	IF (SAVED = 1 & X3006  IN (23 24 25 32 92 93)) THEN EMSAVBIN = 1;
		ELSE EMSAVBIN = 0;

run;

proc univariate data=out.SCF16 noprint;
	where LF=1;	/*Building percentiles for head of household labor force participants only (i.e., at least one person in PEU in labor market)*/
	weight WGT;
	var Income;
	output pctlpre=P_ 					/*create percentile prefix*/
		   pctlpts=20,40, 50, 60,80  	/*specify percentile breaks*/;
run;

proc print data=WORK.DATA1;
run;

/*Resulting Income Quintiles (and Median) are: 28000 48000 60000 76000 123000*/

/*Build some user-defined variables*/

data out.SCF16_Cath;
	set OUT.SCF16;
	where LF = 1;
	sixtyTwoPlus=.;
	ageCat=.;
	incQuint=.;
	liqAdeq400=.;
	liqAdeq2000=.;
	rRothContrBin=0;
    rRothContrAmt2015=0;
    sRothContrBin=0;
    sRothContrAmt2015=0;
    oRothContrBin=0;
    oRothContrAmt2015=0;
    rRegContrBin=0;
    rRegContrAmt2015=0;
    sRegContrBin=0;
    sRegContrAmt2015=0;
    oRegContrBin=0;
    oRegContrAmt2015=0;
	PEUContrAnyIRA=0;
	if not missing(X14) then do;
		if (X14>=62) then sixtyTwoPlus=1;
		else sixtyTwoPlus=0;
		if (X14<25) then ageCat=1;
		else if (25<=X14<50) then ageCat=2;
		else if	(50<=X14<65) then ageCat=3;
		else if	(65<=X14<74) then ageCat=4;
		else ageCat=5;
	end;
	if not missing(Income) then do;
		if (INCOME<28000) then incQuint=1;
		else if (28000<=INCOME<48000) then incQuint=2;
		else if (48000<=INCOME<76000) then incQuint=3;
		else if (76000<=INCOME<123000) then incQuint=4;
		else incQuint=5;
	end;
	if LIQ<400								then liqAdeq400=0;
	else liqAdeq400=1;
	if LIQ<2000								then liqAdeq2000=0;
	else liqAdeq2000=1;
*	We are not interested in Keogh accounts, but we are interested in IRA contributions from any PEU member;
*	Create a binary variable indicating whether anyone in the PEU contributed to any kind of IRA in 2015;

	if (X3601=1) &											/*Has IRA or Keogh*/
	   (X3605 ne 1 & X3615 ne 1 & X3625 ne 1) &				/*Take out all Keoghs*/
	   	((X6444=1|X6446=1|X6447=1) or
		 (X6448=1|X6450=1|X6451=1) or
		 (X6452=1|X6454=1|X6455=1)) &						/*Include any type of IRA: Rraditional, Roth, Rollover*/	
	   (X6791=1|X6793=1|X6795=1) then PEUContrAnyIRABin=1;	/*Include any contributions by any PEU members*/
	else PEUContrAnyIRABin=0;

*	Pensions offered through employers may be restricted to part-time workers only.;
*	Create full-time, part-time, and mixed categories for PEUs;
	if MARRIED=1 then 
		do;
			if (X4511=1 & X5111=1) then fullOrPartTime=1;								/*Both respondent and spouse consider their work full-time*/
			else if ((X4511=1 & X5111=2) or (X4511=2 & X5111=1)) then fullOrPartTime=2;	/*One partner works part-time, the other works full-time*/
			else if (X4511=2 & X5111=2) then fullOrPartTime=3;							/*Both respondents consider their work to be part-time*/
			else fullOrPartTime=0;
		end;
	if MARRIED=2 then
		do;
		if (X4511=1) then fullOrPartTime=1;
		else if (X4511=2) then fullOrPartTime=3;
		else fullOrPartTime=0;
		end;

*	SCF questions about IRA ownership and contributions do not distinguish between different types of IRAs;	
*	Can't isolate contributions by IRA type if respondent, spouse, or other PEU has multiple IRAS (or Keoghs);
*	Can isolate contributions by IRA type if respondent, spouse, or other PEU has only one IRA;

	if (X6444=1 & X6446 ne 1 & X6447 ne 1 & X3605 ne 1) then do; *Isolate pure respondent Roth IRAs;
		rRothContrBin=(X6791=1);
		rRothContrAmt2015=max(0,X6792);
	end;
	if (X6448=1 & X6450 ne 1 & X6451 ne 1 & X3615 ne 1) then do; *Isolate pure spouse Roth IRAs;
		sRothContrBin=(X6793=1);
		sRothContrAmt2015=max(0,X6794);
	end;
	if (X6452=1 & X6454 ne 1 & X6455 ne 1 & X3625 ne 1) then do; *Isolate pure other PEU Roth IRAs;
		oRothContrBin=(X6795=1);
		oRothContrAmt2015=max(0,X6796);
	end;
	if (X6444 ne 1 & X6446 ne 1 & X6447=1 & X3605 ne 1) then do; *Isolate pure respondent Reg IRAs;
		rRegContrBin=(X6791=1);
		rRegContrAmt2015=max(0,X6792);
	end;
	if (X6448 ne 1 & X6450 ne 1 & X6451=1 & X3615 ne 1) then do; *Isolate pure spouse Reg IRAs;
		sRegContrBin=(X6793=1);
		sRegContrAmt2015=max(0,X6794);
	end;
	if (X6452 ne 1 & X6454 ne 1 & X6455=1 & X3625 ne 1) then do; *Isolate pure other PEU Reg IRAs;
		oRegContrBin=(X6795=1);
		oRegContrAmt2015=max(0,X6796);
	end;
	label rRothContrBin = "Did the Respondent Contribute to a Roth IRA in 2015?"
		  rRothContrAmt2015 = "Total Respondent Contribution to a Roth IRA in 2015?"
		  sRothContrBin = "Did the Spouse Contribute to a Roth IRA in 2015?"
		  sRothContrAmt2015 = "Total Spouse Contribution to a Roth IRA in 2015?"
		  oRothContrBin = "Did Another PEU member Contribute to a Roth IRA in 2015?"
		  oRothContrAmt2015 = "Other PEU member Contribution to a Roth IRA in 2015?"
		  rRegContrBin = "Did the Respondent Contribute to a Regular IRA in 2015?"
		  rRegContrAmt2015 = "Total Respondent Contribution to a Regular IRA in 2015?"
		  sRegContrBin = "Did the Spouse Contribute to a Regular IRA in 2015?"
		  sRegContrAmt2015 = "Total Spouse Contribution to a Regular IRA in 2015?"
		  oRegContrBin = "Did Another PEU member Contribute to a Regular IRA in 2015?"
		  oRegContrAmt2015 = "Other PEU member Contribution to a Regular IRA in 2015?"
		  X3601 = "Does anyone in the Family have an IRA or Keogh?"
		  PEUContrAnyIRABin = "Did anyone in the PEU Contribute to any kind of IRA in 2015?";
run;

/*Set up label formatting*/

proc template;
define crosstabs Base.Freq.CrossTabFreqs;
define header tableof;
text "Table of " _row_label_ " by " _col_label_;
end;
define header rowsheader;
text _row_label_ / _row_label_ ^= ' ';
text _row_name_;
end;
define header colsheader;
text _col_label_ / _col_label_ ^= ' ';
text _col_name_;
end;
cols_header=colsheader;
rows_header=rowsheader;
header tableof;
end;
run;

/*Check frequencies of SCF user-defined variables*/

proc freq data=out.SCF16_Cath;
	tables X7594 X7648 X7594*X7648 ;
run;


proc freq data=out.SCF16_Cath;
	weight WGT;
	tables RACECL4 incQuint ageCat PEUContrAnyIRABin;
run;


/*Check frequencies of how often employees contribute to employer-provided pension plan rate*/

proc freq data=out.SCF16_Cath;
	weight WGT;
	tables X11043 X11143 X11343 X11443;
	title "Test Contribution Period Frequency";
	format ANYPEN PEUContrAnyIRABin allBinaries_format.
			X3601 oneFiveZero_format.; 
run;

/************************************/
/* Specify Output Type and Location */
/************************************/

ods listing close;

options orientation=landscape;
ods tagsets.excelxp file='V:\OED\OED_Public\PPI\William\exploratoryAnalysis\SCF16LSoutput.xls' style=sasweb
    options(sheet_interval="none" embedded_titles='yes');
run;

/********************************************************************************************************************/
/* Note: to put different outputs in different worksheets within the same Excel Workbook, use this pattern:		    */
/* ods tagsets.excelxp options(sheet_interval="none"); 		<- puts all following output on current worksheet...	*/
/* ods tagsets.excelxp options(sheet_interval="table"); 	<- advances to next worksheet...					    */
/* ods tagsets.excelxp options(sheet_interval="none");		<- puts all following output on same worksheet...	    */
/********************************************************************************************************************/

/*Labor Force Tabulations*/

ods tagsets.ExcelXP options(sheet_interval='none'
	sheet_name="Labor Force Frequency");

proc freq data=out.SCF16_Cath;
		weight wgt;
		format 	ageCat ageCat_format.
			   	liqAdeq400 liqAdeq400_format.
				liqAdeq2000 liqAdeq2000_format. 
				incQuint incQuint_format.
				RACECL4 RACECL4_format.
				hliq hliq_format.
				HPREPAID SAVED EMSAVBIN allBinaries_format.;
		tables hliq HPREPAID SAVED EMSAVBIN liqAdeq400 liqAdeq2000;
		label hliq="Has Liquid Savings?"
			  HPREPAID="Did the PEU Have a Prepaid Card of Any Kind?"
			  SAVED="Did a PEU Spend Less Than Their Income?"
			  EMSAVBIN="If PEU Saved, Were They Saving for Emergencies?"
			  liqAdeq400="Did a PEU have at least $400 in liquid savings?"
			  liqAdeq2000="Did a PEU have at least $2000 in liquid savings?"; 
		title "PEU Frequencies: Labor Force";
run;

ods tagsets.excelxp options(sheet_interval="table");
ods tagsets.excelxp options(sheet_interval="none");

ods tagsets.ExcelXP options(sheet_interval='none'
	sheet_name="Labor Force Liquid Amount");

proc means data=out.SCF16_Cath
			MAXDEC=2 SUMWGT N MEAN P25 MEDIAN P75;
	weight wgt;
	var liq;
	title "Mean and Percentiles of Liquid Savings: Labor Force"; 
run;

ods tagsets.excelxp options(sheet_interval="table");
ods tagsets.excelxp options(sheet_interval="none");

ods tagsets.ExcelXP options(sheet_interval='none'
	sheet_name="Labor Force Prepaid Amount");

proc means data=out.SCF16_Cath
			MAXDEC=2 SUMWGT N MEAN P25 MEDIAN P75;
	where HPREPAID=1;
	weight wgt;
	var PREPAID;
	title "Mean and Percentiles of Prepaid Balances: Labor Force"; 
run;

/*Age Tabulations*/

proc sort data=out.SCF16_Cath;
	by ageCat;
run;

ods tagsets.excelxp options(sheet_interval="table");
ods tagsets.excelxp options(sheet_interval="none");

ods tagsets.ExcelXP options(sheet_interval='none'
	sheet_name="Age Frequency");

proc freq data=out.SCF16_Cath;
		by ageCat;
		weight wgt;
		format 	ageCat ageCat_format.
			   	liqAdeq400 liqAdeq400_format.
				liqAdeq2000 liqAdeq2000_format. 
				incQuint incQuint_format.
				RACECL4 RACECL4_format.
				hliq hliq_format.
				HPREPAID allBinaries_format.;
		tables hliq HPREPAID SAVED EMSAVBIN liqAdeq400 liqAdeq2000;
		label hliq="Has Liquid Savings?"
			  HPREPAID="Did the PEU Have a Prepaid Card of Any Kind?"
			  SAVED="Did a PEU Spend Less Than Their Income?"
			  EMSAVBIN="If PEU Saved, Were They Saving for Emergencies?"
			  liqAdeq400="Did a PEU have at least $400 in liquid savings?"
			  liqAdeq2000="Did a PEU have at least $2000 in liquid savings?";
		title "PEU Frequencies: By Age";
run;

ods tagsets.excelxp options(sheet_interval="table");
ods tagsets.excelxp options(sheet_interval="none");

ods tagsets.ExcelXP options(sheet_interval='none'
	sheet_name="Age Liquid Amount");

proc means data=out.SCF16_Cath
			MAXDEC=2 SUMWGT N MEAN P25 MEDIAN P75;
	by ageCat;
	weight wgt;
	var liq;
	format 	ageCat ageCat_format.;
	title "Mean and Percentiles of Liquid Savings: By Age"; 
run;

ods tagsets.excelxp options(sheet_interval="table");
ods tagsets.excelxp options(sheet_interval="none");

ods tagsets.ExcelXP options(sheet_interval='none'
	sheet_name="Age Prepaid Amount");

proc means data=out.SCF16_Cath
			MAXDEC=2 SUMWGT N MEAN P25 MEDIAN P75;
	where HPREPAID=1;
	by ageCat;
	weight wgt;
	var PREPAID;
	format 	ageCat ageCat_format.;
	title "Mean and Percentiles of Prepaid Balances: By Age"; 
run;

/*Income Tabulations*/

proc sort data=out.SCF16_Cath;
	by incQuint;
run;

ods tagsets.excelxp options(sheet_interval="table");
ods tagsets.excelxp options(sheet_interval="none");

ods tagsets.ExcelXP options(sheet_interval='none'
	sheet_name="Income Frequency");

proc freq data=out.SCF16_Cath;
		by incQuint;
		weight wgt;
		format 	ageCat ageCat_format.
			   	liqAdeq400 liqAdeq400_format.
				liqAdeq2000 liqAdeq2000_format. 
				incQuint incQuint_format.
				RACECL4 RACECL4_format.
				hliq hliq_format.
				HPREPAID allBinaries_format.;
		tables hliq HPREPAID SAVED EMSAVBIN liqAdeq400 liqAdeq2000;
		label hliq="Has Liquid Savings?"
			  HPREPAID="Did the PEU Have a Prepaid Card of Any Kind?"
			  SAVED="Did a PEU Spend Less Than Their Income?"
			  EMSAVBIN="If PEU Saved, Were They Saving for Emergencies?"
			  liqAdeq400="Did a PEU have at least $400 in liquid savings?"
			  liqAdeq2000="Did a PEU have at least $2000 in liquid savings?";
		title "PEU Frequencies: By Income";
run;

ods tagsets.excelxp options(sheet_interval="table");
ods tagsets.excelxp options(sheet_interval="none");

ods tagsets.ExcelXP options(sheet_interval='none'
	sheet_name="50-64: Income Frequency");

proc freq data=out.SCF16_Cath;
		where ageCat=3;
		by incQuint;
		weight wgt;
		format 	ageCat ageCat_format.
			   	liqAdeq400 liqAdeq400_format.
				liqAdeq2000 liqAdeq2000_format. 
				incQuint incQuint_format.
				RACECL4 RACECL4_format.
				hliq hliq_format.
				HPREPAID allBinaries_format.;
		tables hliq HPREPAID SAVED EMSAVBIN liqAdeq400 liqAdeq2000;
		label hliq="Has Liquid Savings?"
			  HPREPAID="Did the PEU Have a Prepaid Card of Any Kind?"
			  SAVED="Did a PEU Spend Less Than Their Income?"
			  EMSAVBIN="If PEU Saved, Were They Saving for Emergencies?"
			  liqAdeq400="Did a PEU have at least $400 in liquid savings?"
			  liqAdeq2000="Did a PEU have at least $2000 in liquid savings?"; 
		title "PEU Frequencies: 50-64, By Income";
run;

ods tagsets.excelxp options(sheet_interval="table");
ods tagsets.excelxp options(sheet_interval="none");

ods tagsets.ExcelXP options(sheet_interval='none'
	sheet_name="Income Liquid Amount");

proc means data=out.SCF16_Cath
			MAXDEC=2 SUMWGT N MEAN P25 MEDIAN P75;
	by incQuint;
	weight wgt;
	var liq;
	format 	incQuint incQuint_format.;
	title "Mean and Percentiles of Liquid Savings and Prepaid Cards: By Income"; 
run;

ods tagsets.excelxp options(sheet_interval="table");
ods tagsets.excelxp options(sheet_interval="none");

ods tagsets.ExcelXP options(sheet_interval='none'
	sheet_name="Income Prepaid Amount");

proc means data=out.SCF16_Cath
			MAXDEC=2 SUMWGT N MEAN P25 MEDIAN P75;
	where HPREPAID=1;
	by incQuint;
	weight wgt;
	var PREPAID;
	format 	incQuint incQuint_format.;
	title "Mean and Percentiles of Prepaid Balances: By Income"; 
run;

ods tagsets.excelxp options(sheet_interval="table");
ods tagsets.excelxp options(sheet_interval="none");

ods tagsets.ExcelXP options(sheet_interval='none'
	sheet_name="50-64: Income Liquid Amount");

proc means data=out.SCF16_Cath
			MAXDEC=2 SUMWGT N MEAN P25 MEDIAN P75;
	where ageCat=3;
	by incQuint;
	weight wgt;
	var liq;
	format 	incQuint incQuint_format.;
	title "Mean and Percentiles of Liquid Savings and Prepaid Cards: 50-64, By Income"; 
run;

ods tagsets.excelxp options(sheet_interval="table");
ods tagsets.excelxp options(sheet_interval="none");

ods tagsets.ExcelXP options(sheet_interval='none'
	sheet_name="50-64, Income Prepaid Amount");

proc means data=out.SCF16_Cath
			MAXDEC=2 SUMWGT N MEAN P25 MEDIAN P75;
	where HPREPAID=1 & ageCat=3;
	by incQuint;
	weight wgt;
	var PREPAID;
	format 	incQuint incQuint_format.;
	title "Mean and Percentiles of Prepaid Balances: 50-64, By Income"; 
run;

/*Race Tabulations*/

proc sort data=out.SCF16_Cath;
	by RACECL4;
run;

ods tagsets.excelxp options(sheet_interval="table");
ods tagsets.excelxp options(sheet_interval="none");

ods tagsets.ExcelXP options(sheet_interval='none'
	sheet_name="Race Frequency");

proc freq data=out.SCF16_Cath;
		by RACECL4;
		weight wgt;
		format 	ageCat ageCat_format.
			   	liqAdeq400 liqAdeq400_format.
				liqAdeq2000 liqAdeq2000_format. 
				incQuint incQuint_format.
				RACECL4 RACECL4_format.
				hliq hliq_format.
				HPREPAID allBinaries_format.;
		tables hliq HPREPAID SAVED EMSAVBIN liqAdeq400 liqAdeq2000;
		label hliq="Has Liquid Savings?"
			  HPREPAID="Did the PEU Have a Prepaid Card of Any Kind?"
			  SAVED="Did a PEU Spend Less Than Their Income?"
			  EMSAVBIN="If PEU Saved, Were They Saving for Emergencies?"
			  liqAdeq400="Did a PEU have at least $400 in liquid savings?"
			  liqAdeq2000="Did a PEU have at least $2000 in liquid savings?";
		title "PEU Frequencies: By Race";
run;

ods tagsets.excelxp options(sheet_interval="table");
ods tagsets.excelxp options(sheet_interval="none");

ods tagsets.ExcelXP options(sheet_interval='none'
	sheet_name="50-64: Race Frequency");

proc freq data=out.SCF16_Cath;
		where ageCat=3;
		by RACECL4;
		weight wgt;
		format 	ageCat ageCat_format.
			   	liqAdeq400 liqAdeq400_format.
				liqAdeq2000 liqAdeq2000_format. 
				incQuint incQuint_format.
				RACECL4 RACECL4_format.
				hliq hliq_format.
				HPREPAID allBinaries_format.;
		tables hliq HPREPAID SAVED EMSAVBIN liqAdeq400 liqAdeq2000;
		label hliq="Has Liquid Savings?"
			  HPREPAID="Did the PEU Have a Prepaid Card of Any Kind?"
			  SAVED="Did a PEU Spend Less Than Their Income?"
			  EMSAVBIN="If PEU Saved, Were They Saving for Emergencies?"
			  liqAdeq400="Did a PEU have at least $400 in liquid savings?"
			  liqAdeq2000="Did a PEU have at least $2000 in liquid savings?";
		title "PEU Frequencies: 50-64 By Race";
run;

ods tagsets.excelxp options(sheet_interval="table");
ods tagsets.excelxp options(sheet_interval="none");

ods tagsets.ExcelXP options(sheet_interval='none'
	sheet_name="Race Liquid Amount");

proc means data=out.SCF16_Cath
			MAXDEC=2 SUMWGT N MEAN P25 MEDIAN P75;
	by RACECL4;
	weight wgt;
	var liq;
	format 	RACECL4 RACECL4_format.;
	title "Mean and Percentiles of Liquid Savings: By Race"; 
run;

ods tagsets.excelxp options(sheet_interval="table");
ods tagsets.excelxp options(sheet_interval="none");

ods tagsets.ExcelXP options(sheet_interval='none'
	sheet_name="Race Prepaid Amount");

proc means data=out.SCF16_Cath
			MAXDEC=2 SUMWGT N MEAN P25 MEDIAN P75;
	where HPREPAID=1;
	by RACECL4;
	weight wgt;
	var PREPAID;
	format 	RACECL4 RACECL4_format.;
	title "Mean and Percentiles of Prepaid Balances: By Race"; 
run;


ods tagsets.excelxp options(sheet_interval="table");
ods tagsets.excelxp options(sheet_interval="none");

ods tagsets.ExcelXP options(sheet_interval='none'
	sheet_name="50-64: Race Liquid Amount");

proc means data=out.SCF16_Cath
			MAXDEC=2 SUMWGT N MEAN P25 MEDIAN P75;
	where ageCat=3;
	by RACECL4;
	weight wgt;
	var liq;
	format 	RACECL4 RACECL4_format.;
	title "Mean and Percentiles of Liquid Savings: 50-64, By Race";
run;

ods tagsets.excelxp options(sheet_interval="table");
ods tagsets.excelxp options(sheet_interval="none");

ods tagsets.ExcelXP options(sheet_interval='none'
	sheet_name="50-64, Race Prepaid Amount");

proc means data=out.SCF16_Cath
			MAXDEC=2 SUMWGT N MEAN P25 MEDIAN P75;
	where HPREPAID=1 & ageCat=3;
	by RACECL4;
	weight wgt;
	var PREPAID;
	format 	RACECL4 RACECL4_format.;
	title "Mean and Percentiles of Prepaid Balances: 50-64, By Race"; 
run;

/***********************************/
/*Shut down Output Delivery System */
/***********************************/
ods _all_ close;

















































ods tagsets.ExcelXP options(sheet_interval='none'
	sheet_name="IRA Analysis");

/*Starting broadly, which PEUs in the labor force had an IRA or Keogh account (IRA-SEP and IRA-SIMPLE not included)?*/


proc sort data=out.SCF16_Cath;
	by ANYPEN;
run;

proc freq data=out.SCF16_Cath;
	weight WGT;
	by ANYPEN;
	tables X3601;
	title "Did the PEU Have an IRA or Keogh?";
	format rRothContrBin allBinaries_format.
		   X3601 oneFiveZero_format.; 
run;

/*Filtering out Keoghs due to their higher contribution limits, which PEUs in the labor force had an IRA account (IRA-SEP and IRA-SIMPLE not included)?*/

proc freq data=out.SCF16_Cath;
	weight WGT;
	where (X3605 ne 1 & X3615 ne 1 & X3625 ne 1);
	by ANYPEN;
	tables X3601;
	title "Did the PEU Have any kind of IRA?";
	format ANYPEN allBinaries_format.
			X3601 oneFiveZero_format.; 
run;

/*Based on comparison of the two tables above, Keoghs appear to account for only a very small portion of retirement accounts.*/
/*Leaving them out will have minimal effect, but keeping them in might skew continuous variables like balances and contributions.*/
/*Also, PEUs with access to at least one pension through work (or those expecting a future pension) have more IRAs than PEUs that do not.*/

/*IRA ownership is not the same as contributing to an  IRA. 
/*How many PEUs owned and contributed to at least one of any kind of IRA in 2015?*/

proc freq data=out.SCF16_Cath;
	weight WGT;
	by ANYPEN;
	tables PEUContrAnyIRABin;
	title "Did any memeber of the PEU Have and Contribute to any kind of IRA?";
	format ANYPEN PEUContrAnyIRABin allBinaries_format.
			X3601 oneFiveZero_format.; 
run;

/*Same question, but now by income quintiles*/

proc freq data=out.SCF16_Cath;
	weight WGT;
	by ANYPEN;
	tables incQuint*PEUContrAnyIRABin;
	title "Did any memeber of the PEU Have and Contribute to any kind of IRA: By Income Quintile";
	format ANYPEN PEUContrAnyIRABin allBinaries_format.
			X3601 oneFiveZero_format.
			fullOrPartTime fullOrPartTime_format.; 
run;

/*What about PEUs that consider themselves to be working part-time versus working full-time?*/

proc freq data=out.SCF16_Cath;
	weight WGT;
	by ANYPEN;
	tables fullOrPartTime*PEUContrAnyIRABin;
	title "Did any memeber of the PEU Have and Contribute to any kind of IRA: By full-time and part-time";
	format ANYPEN PEUContrAnyIRABin allBinaries_format.
			X3601 oneFiveZero_format.
			fullOrPartTime fullOrPartTime_format.; 
run;



title;

/*Build a macro to loop through IRA ownership and contribution by type and owner*/

/*Create a table of variable names for IRA types and owners*/

data IRACats;
	infile datalines;
	length x $ 17;
	input x $;
	datalines;
rRothContrBin
sRothContrBin
oRothContrBin
rRegContrBin
sRegContrBin
oRegContrBin
	;


/*Convert table of strings into a macro variable, &IRACatsList */

proc sql noprint;
	select x into :IRACatsList separated by ' '
	from IRACats;
quit;
%put IRACatsList = &IRACatsList;


%macro iraCatFreq(stringList);
%local i next;
%let i=1;
%do i=1 %to %sysfunc(countw(&stringList));
	%let next=%scan(&stringList,&i);
	proc freq data=out.SCF16_Cath;
	weight WGT;
	by ANYPEN;
	tables &next;
	format &next allBinaries_format.; 
	run;
%end;
%mend iraCatFreq;
%iraCatFreq(rRothContrBin sRothContrBin oRothContrBin rRegContrBin sRegContrBin oRegContrBin );
%iraCatFreq(&IRACatsList);

/*
rRothContrAmt2015
sRothContrAmt2015
oRothContrAmt2015
rRegContrAmt2015
sRegContrAmt2015
oRegContrAmt2015
*/


/*Ad-hoc analysis for CH 1*/
proc freq data=out.SCF16_Cath;
	weight WGT;
	by ANYPEN;
	tables X7775;
	title "If you couldn't pay all of your bills, how would you handle such a financial emergency?";
	format X7775 emerg_format.; 
run;

/*Ad-hoc analysis for CH 2*/
proc freq data=out.SCF16_Cath;
	weight WGT;
	by ANYPEN;
	where X7775=2;
	tables X7778 X7779;
	title "If you would use savings and investments in a financial emergency, which would you use?";
	format X7775 emerg_format.
		   X7778 X7779 emergSource_format.; 
run;


/*Ad-hoc analysis for CH 1*/
proc freq data=out.SCF16_Cath;

	by ANYPEN;
	tables X7775;
	title "If you couldn't pay all of your bills, how would you handle such a financial emergency?";
	format X7775 emerg_format.; 
run;

/*Ad-hoc analysis for CH 2*/
proc freq data=out.SCF16_Cath;

	by ANYPEN;
	where X7775=2;
	tables X7778 X7779;
	title "If you would use savings and investments in a financial emergency, which would you use?";
	format X7775 emerg_format.
		   X7778 X7779 emergSource_format.; 
run;










proc freq data=out.SCF16_Cath;
	weight WGT;
	where X3601=1;
	by ANYPEN;
	tables rRothContrBin;
	title "Did the Respondent Contribute to a Roth IRA in 2015?";
	format rRothContrBin allBinaries_format.; 
run;

proc means data=out.SCF16_Cath
			MAXDEC=2 SUMWGT N MEAN q1 MEDIAN q3;
	weight wgt;
	where rRothContrBin = 1;
	by ANYPEN X3601;
	var rRothContrAmt2015;
	title "If Respondent Contribtued, Total Respondent Roth IRA Contribution in 2015";
run;

proc freq data=out.SCF16_Cath;
	weight WGT;
	where ANYPEN=1;
	tables sRothContrBin;
	title "Did the Spouse Contribute to a Roth IRA in 2015?";
	format sRothContrBin allBinaries_format.; 
run;

proc means data=out.SCF16_Cath
			MAXDEC=2 SUMWGT N MEAN MODE q1 MEDIAN q3;
	where sRothContrBin = 1 & ANYPEN=1;
	weight wgt;
	var sRothContrAmt2015;
	title "If Spouse Contribtued, Total Spouse Roth IRA Contribution in 2015";
run;

proc freq data=out.SCF16_Cath;
	weight WGT;
	where ANYPEN=1;
	tables oRothContrBin;
	title "Did Another PEU member Contribute to a Roth IRA in 2015?";
	format oRothContrBin allBinaries_format.; 
run;

proc means data=out.SCF16_Cath
			MAXDEC=2 SUMWGT N MEAN MODE q1 MEDIAN q3;
	where oRothContrBin = 1 &ANYPEN=1;
	weight wgt;
	var oRothContrAmt2015;
	title "If Another PEU Contribtued, Total PEU member Roth IRA Contribution in 2015";
run;

/*Regular*/

proc freq data=out.SCF16_Cath;
	weight WGT;
	where ANYPEN=1;
	tables rRegContrBin;
	title "Did the Respondent Contribute to a Regular IRA in 2015?";
	format rRegContrBin allBinaries_format.; 
run;

proc means data=out.SCF16_Cath
			MAXDEC=2 SUMWGT N MEAN MODE q1 MEDIAN q3;
	where rRegContrBin = 1 & ANYPEN=1;
	weight wgt;
	var rRegContrAmt2015;
	title "If Respondent Contribtued, Total Respondent Regular IRA Contribution in 2015";
run;

proc freq data=out.SCF16_Cath;
	weight WGT;
	where ANYPEN=1;
	tables sRegContrBin;
	title "Did the Spouse Contribute to a Regular IRA in 2015?";
	format sRegContrBin allBinaries_format.; 
run;

proc means data=out.SCF16_Cath
			MAXDEC=2 SUMWGT N MEAN MODE q1 MEDIAN q3;
	where sRegContrBin = 1 & ANYPEN=1;
	weight wgt;
	var sRegContrAmt2015;
	title "If Spouse Contribtued, Total Spouse Regular IRA Contribution in 2015";
run;

proc freq data=out.SCF16_Cath;
	weight WGT;
	where ANYPEN=1;
	tables oRegContrBin;
	title "Did Another PEU member Contribute to a Regular IRA in 2015?";
	format oRegContrBin allBinaries_format.; 
run;

proc means data=out.SCF16_Cath
			MAXDEC=2 SUMWGT N MEAN MODE q1 MEDIAN q3;
	where oRegContrBin = 1 & ANYPEN=1;
	weight wgt;
	var oRegContrAmt2015;
	title "If Another PEU Contribtued, Total PEU member Reg IRA Contribution in 2015";
run;


ods tagsets.excelxp options(sheet_interval="table");
ods tagsets.excelxp options(sheet_interval="none");


/***********************************/
/*Shut down Output Delivery System */
/***********************************/
ods _all_ close;




proc sort data=out.SCF16_Cath;
	by ageCat;
run;

proc freq data=out.SCF16_Cath;
	weight WGT;
	by ageCat;
	tables X6791;
	title "Did the respondent Contribute to an IRA in 2015? by Age Category";
	format ageCat ageCat_format.; 
run;

proc means data=out.SCF16_Cath
			MAXDEC=2 SUMWGT N MEAN q1 MEDIAN q3;
	where X6791 = 1;
	by ageCat;
	weight wgt;
	var X6792;
	title "If Respondent Contribtued, Respondent IRA Contribution in 2015 by Age Category";
	format ageCat ageCat_format.;
run;

proc freq data=out.SCF16_Cath;
	weight WGT;
	by ageCat;
	tables X7594;
	title "Did the respondent have a prepaid  card? by Age Category";
	format ageCat ageCat_format.; 
run;

proc means data=out.SCF16_Cath
			MAXDEC=2 SUMWGT N MEAN q1 MEDIAN q3;
	where X7594 = 1;
	by ageCat;
	weight wgt;
	var X7596;
	title "If Respondent Had Prepaid Card, total Prepaid Card balance in 2015 by Age Category";
	format ageCat ageCat_format.; 
run;

proc sort data=out.SCF16_Cath;
	by incQuint;
run;

proc freq data=out.SCF16_Cath;
	weight WGT;
	by incQuint;
	tables X6791;
	title "Did the respondent Contribute to an IRA in 2015? by Income";
	format incQuint incQuint_format.; 
run;

proc means data=out.SCF16_Cath
			MAXDEC=2 SUMWGT N MEAN MODE q1 MEDIAN q3;
	where X6791 = 1;
	by incQuint;
	weight wgt;
	var X6792;
	title "If Respondent Contribtued, Respondent IRA Contribution in 2015 by Income";
	format incQuint incQuint_format.;
run;

proc freq data=out.SCF16_Cath;
	weight WGT;
	by incQuint;
	tables X7594;
	title "Did the respondent have a prepaid  card? by Income";
	format incQuint incQuint_format.; 
run;

proc means data=out.SCF16_Cath
			MAXDEC=2 SUMWGT N MEAN q1 MEDIAN q3;
	where X7594 = 1;
	by incQuint;
	weight wgt;
	var X7596;
	title "If Respondent Had Prepaid Card, total Prepaid Card balance in 2015 by Income";
	format incQuint incQuint_format.; 
run;

proc sort data=out.SCF16_Cath;
	by RACECL4;
run;

proc freq data=out.SCF16_Cath;
	weight WGT;
	by RACECL4;
	tables X6791;
	title "Did the respondent Contribute to an IRA in 2015? by Race";
	format RACECL4 RACECL4_format.; 
run;

proc means data=out.SCF16_Cath
			MAXDEC=2 SUMWGT N MEAN q1 MEDIAN q3;
	where X6791 = 1;
	by RACECL4;
	weight wgt;
	var X6792;
	title "If Respondent Contribtued, Respondent IRA Contribution in 2015 by Race";
	format RACECL4 RACECL4_format.;
run;

proc freq data=out.SCF16_Cath;
	weight WGT;
	by RACECL4;
	tables X7594;
	title "Did the respondent have a prepaid  card? by Race";
	format RACECL4 RACECL4_format.; 
run;

proc means data=out.SCF16_Cath
			MAXDEC=2 SUMWGT N MEAN q1 MEDIAN q3;
	where X7594 = 1;
	by RACECL4;
	weight wgt;
	var X7596;
	title "If Respondent Had Prepaid Card, total Prepaid Card balance in 2015 by Race";
	format RACECL4 RACECL4_format.; 
run;



