Parameter cWhere
CREATE CURSOR fltrPrint (cstring m)
APPEND blank
replace cstring WITH 'Kpv-st:'+DTOC(fltrReklDekl.kpv1)+'kpv-ni:'+DTOC(fltrReklDekl.kpv1)+;
	IIF(!EMPTY(fltrReklDekl.number),'Number:'+LTRIM(RTRIM(fltrReklDekl.number)),'')+;
	IIF(!EMPTY(fltrReklDekl.tyyp),'Tüüp:'+LTRIM(RTRIM(fltrReklDekl.tyyp)),'')+;
	IIF(!EMPTY(fltrReklDekl.staatus),'Status:'+LTRIM(RTRIM(fltrReklDekl.staatus)),'')+;
	IIF(!EMPTY(fltrReklDekl.summa1),'Summast:'+str(fltrReklDekl.summa1,2),'')+;
	IIF(!EMPTY(fltrReklDekl.summa2),'Summani:'+str(fltrReklDekl.summa2,2),'') IN fltrPrint

	

Select curreklDekl.*, comReklmaksud.nimetus, comReklmaksud.regkood, comReklmaksud.id ;
	from curReklDekl , comReklmaksud where comReklmaksud.ID =  oReklmaksud.lstAsutused.value INTO CURSOR printReklDekl
SELECT printReklDekl
