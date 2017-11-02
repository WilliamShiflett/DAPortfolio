/**********************************************************************************/
/* File Name: Wshiflett_HW7.sas												  */
/* Created by: William Shiflett 												  */
/* Created on: 6/26/16															  */
/* Purpose: Complete Assignment 7							 					  */
/* Last Run: 6/26/16 															  */
/**********************************************************************************/

/**********************************/
/*2: write libname for folder*/
/**********************************/
libname schools 'C:\Users\wshiflett\Desktop\STAT604\HW7' access=readonly;

/********************************/
/*3: create folder for data sets*/
/********************************/
libname HW7data 'C:\Users\wshiflett\Desktop\Stat604\HW7\HW7datasets';

/********************************/
/*4: create fileref for output  */
/********************************/
filename output 'C:\Users\wshiflett\Desktop\STAT604\HW7\HW7datasets\WShiflett_HW07_output.pdf';
ods pdf file=output bookmarkgen=yes bookmarklist=hide;
run;

/********************************/
/*5: create revised data set    */
/********************************/
data HW7data.output;
	set schools.tx_schools(drop=state type level F16 F17);
	where sr>=1 or
		  jr>=1 or
		  so>=1 or
		  fr>=1;
	Total=sum(fr, so, jr, sr);
	Load=today();
	format Load mmddyy10.;
	label fte_teachers="Teachers(FTE)" 
		  ptr="Student/Teacher Ratio"
		  control="School Type"
		  gr8="Eighth Graders"
		  fr="Freshmen"
		  so="Sophmores"
		  jr="Juniors"
		  sr="Seniors"
		  Total="HS Enrollment"
		  Load="Load Date";
run;

/********************************/
/*6: print descriptor portion   */
/********************************/
proc contents data=HW7data.output;
run;

/********************************/
/*7: print first 9 observations */
/********************************/
proc print data=HW7data.output (obs=9) label;
run;

/********************************/
/*8: create temporary data sets */
/********************************/
data tempdata;
	set HW7data.output(keep=School Total County Control);
	where school like '%ACADEMY%' and
		  school ne 'ACADEMY H S';
run;

/********************************/
/*9: print academies' data	    */
/********************************/
proc print data=tempdata label;
	var School Total Control County;
run;

/**********************************/
/*10: create senior focus data set*/
/**********************************/
data tempdata2;
	set HW7data.output(keep=School County gr8 fr so jr sr Total);
	where sum(jr,so,fr)>0 and
		sr>(.25*Total);
run;

/**********************************/
/*11: print seniors data          */
/**********************************/
proc print data=tempdata2 label noobs;
	var School Total  sr jr so fr gr8 County;
run;

/**********************************/
/*12: create three data sets      */
/**********************************/
data OneA (drop=Division control fte_teachers ptr) 
	 TAPS1 (drop=Division control fte_teachers ptr)
	 Align16 (drop=control fte_teachers ptr);
	length Division $ 12;
	set HW7data.output;
	where sr>0 and
		  jr>0 and
		  so>0 and
		  fr>0;
	if control='Public' then do;
		if Total<105 then Division='1A';
		if Total>=105 and Total<220 then Division='2A';
		if Total>=220 and Total<465 then Division='3A';
		if Total>=465 and Total<1060 then Division='4A';
		if Total>=1060 and Total<2100 then Division='5A';
		if Total>=2100 then Division='6A';
	end;
	else if control='Private' then do;
		if Total<56 then Division='TAPS1';
		if Total>=56 and Total<111  then Division='TAPS2';
		if Total>=111 then Division='TAPS3';
	end;
	select (Division);
		when ('TAPS1') output TAPS1 Align16;
		when ('1A') output OneA Align16;
		otherwise output Align16;
	end;	
run;

/**********************************/
/*13: create grade count data set */
/**********************************/
data GradeCount;
	length Grade $ 12;
	set Align16;
	if (gr8 ne . and gr8>0)  then do;
		Grade='Eighth';
		Students=gr8;
		output;
	end;
	if (fr ne . and fr>0) then do;
		Grade='Freshmen';
		Students=fr;
		output;
	end;
	if (so ne . and so>0) then do;
		Grade='Sophomore';
		Students=so;
		output;
	end;
	if (jr ne . and jr>0) then do;
		Grade='Junior';
		Students=jr;
		output;
	end;
	if (sr ne . and sr>0) then do;
		Grade='Senior';
		Students=sr;
		output;
	end;
	keep School Division Grade Students;
run;
/*******************************************/
/*14: proc contents step without descriptor*/
/*******************************************/
proc contents data=work._ALL_ nods;
run;

/*******************************************/
/*15: print 50 observations   			   */
/*******************************************/
proc print data=Align16(firstobs=96 obs=145) noobs;	
run;

/*******************************************/
/*16: print last 30 observations 		   */
/*******************************************/
proc print data=OneA(firstobs=454 obs=483);	
run;

/*******************************************/
/*17: print TAPS1 Data Set                 */
/*******************************************/
proc print data=Taps1(drop=County) label;
run;

/*******************************************/
/*18: print 38 obs from GradeCount         */
/*******************************************/
proc print data=GradeCount(obs=38) label;
var School Division Grade Students;
run;

/*******************************************/
/*19: cut and paste				           */
/*******************************************/
proc tabulate data=gradecount;
	class division grade;
	var students;
	table grade='Grade', division*students=' '*sum=' '*f=comma7.;
run;

ods pdf close;
