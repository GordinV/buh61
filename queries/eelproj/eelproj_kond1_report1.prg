Parameter tcWhere
* Linna kooneelarve eeln�u
If gVersia <> 'PG'
	select 0
	return .f.
endif

create cursor eelarve_report1 (eelarve c(20), nimetus c(254), summa1 n(18,6), summa2 n(18,6), summa3 n(18,6), summa4 n(18,6), summa5 n(18,6), ;
	summa6 n(18,6), summa16 n(18,6)) 

*set step on
	lcString = "select count(*) as count from pg_proc where proname = 'sp_eelarve_aruanne1'"
	lError = oDb.execsql(lcString, 'tmpProc')
	If !Empty (lError) And Used('tmpProc') And !empty(tmpProc.Count)
	*		wait window 'Serveri poolt funktsioon ...' nowait
	
		lcString = "select kinni from aasta where aasta = "+STR(YEAR(fltrAruanne.kpv2),4)+" and kuu = "+STR(MONTH(fltrAruanne.kpv2),2)+;
			" and rekvid = "+STR(gRekv)
			
		lError = odb.execsql(lcString,'tmpAasta')
		IF !USED('tmpAasta')
			RETURN .f.
		ENDIF
		IF tmpAasta.kinni = 0
			lnAnswer = MESSAGEBOX('Kas re-arvesta eelarve t�itmine?',4+32+256,'Eelarve')
			IF lnAnswer = 6
				SELECT comRekvRemote
				SCAN FOR ID >= IIF(fltrAruanne.kond = 1,0,gRekv) AND id <= IIF(fltrAruanne.kond = 1,999,gRekv) AND parentid < 999
					WAIT WINDOW 'oodake, arvestan kassakulud.. '+ALLTRIM(comRekvRemote.nimetus) nowait
					lcString = " select sp_koosta_kassakulud ("+STR(gRekv)+","+;
						" DATE("+Str(Year(fltrAruanne.kpv2),4)+","+STR(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+"),"+;
						STR(Year(fltrAruanne.kpv2),4)+",1)"

					lError = oDb.Execsql(lcString, 'eelarve_report_tmp')
				ENDSCAN
			
				if empty(lError)
					return
				endif
				WAIT WINDOW 'oodake, arvestan kassakulud..tehtud ' nowait

			ENDIF
			 
		ENDIF
	
	
		lError = oDb.Exec("sp_eelarve_aruanne1 ", Str(grekv)+;
			", DATE("+Str(Year(fltrAruanne.kpv1),4)+","+STR(Month(fltrAruanne.kpv1),2)+","+Str(Day(fltrAruanne.kpv1),2)+"),"+;
			" DATE("+Str(Year(fltrAruanne.kpv2),4)+","+STR(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+"),"+;
			str(fltrAruanne.asutusid,9)+",'"+ltrim(rtrim(fltrAruanne.tunnus))+"','"+;
			ltrim(rtrim(fltrAruanne.kood2))+"','"+;
			ltrim(rtrim(fltrAruanne.kood1))+"','"+ltrim(rtrim(fltrAruanne.kood5))+"','"+;
			ltrim(rtrim(fltrAruanne.proj))+"',2,"+;
			Str(fltrAruanne.kond,9),"qryEelarve1")

		If Used('qryEelarve1')
			tcTimestamp = Alltrim(qryEelarve1.sp_eelarve_aruanne1)
			lcString = "select distinct Eelarve, Nimetus, summa1, summa2, summa3, summa4, summa5, summa6, summa16"+;
				"  from tmp_eelproj_aruanne1 where rekvid = "+str(gRekv)+;
			" and timestamp = '"+tcTimestamp +"' order by eelarve"
			lError = oDb.Execsql(lcString, 'eelarve_report_tmp')

		insert into eelarve_report1 (eelarve, nimetus, summa1, summa2, summa3, summa4, summa5, summa6, summa16);
		select eelarve, nimetus, summa1, summa2, summa3, summa4, summa5, summa6, summa16 from eelarve_report_tmp order by eelarve


*!*	* kondsummad1

*!*			select left(eelarve,1) as eelarve,  sum(summa1) as summa1, sum(summa2) as summa2, sum(summa3) as summa3, sum(summa4) as summa4,;
*!*				 sum(summa5) as summa5, sum(summa6) as summa6 ;
*!*				 from eelarve_report_tmp;
*!*				group by left(eelarve,1);
*!*				where left(eelarve,1) in ('5','6','4');
*!*				into cursor eelarve_report_kond1	 

*!*			insert into eelarve_report1 (eelarve, nimetus, summa1, summa2, summa3, summa4, summa5, summa6);
*!*			select eelarve, comEelarveRemote.nimetus, summa1, summa2, summa3, summa4, summa5, summa6; 
*!*			from eelarve_report_kond1 left outer join comEelarveRemote on comEelarveRemote.kood = eelarve_report_kond1.eelarve;

*!*	* kondsummad2
*!*			
*!*			select left(eelarve,2) as eelarve,  sum(summa1) as summa1, sum(summa2) as summa2, sum(summa3) as summa3, sum(summa4) as summa4,;
*!*				 sum(summa5) as summa5, sum(summa6) as summa6 ;
*!*				 from eelarve_report_tmp;
*!*				group by left(eelarve_report_tmp.eelarve,2);
*!*				where left(eelarve_report_tmp.eelarve,1) in (select eelarve from eelarve_report_kond1) ;
*!*				and left(eelarve_report_tmp.eelarve,2) in ('15','20') ;
*!*				into cursor eelarve_report_kond2	 

*!*			insert into eelarve_report1 (eelarve, nimetus, summa1, summa2, summa3, summa4, summa5, summa6);
*!*			select eelarve, comEelarveRemote.nimetus, summa1, summa2, summa3, summa4, summa5, summa6; 
*!*			from eelarve_report_kond2 left outer join comEelarveRemote on comEelarveRemote.kood = eelarve_report_kond2.eelarve;

*!*	* kondsummad3
*!*			
*!*			select left(eelarve,3) as eelarve,  sum(summa1) as summa1, sum(summa2) as summa2, sum(summa3) as summa3, sum(summa4) as summa4,;
*!*				 sum(summa5) as summa5, sum(summa6) as summa6 ;
*!*				 from eelarve_report_tmp;
*!*				group by left(eelarve_report_tmp.eelarve,3);
*!*				where left(eelarve_report_tmp.eelarve,2) in (select eelarve from eelarve_report_kond2) ;
*!*				into cursor eelarve_report_kond3	 

*!*			insert into eelarve_report1 (eelarve, nimetus, summa1, summa2, summa3, summa4, summa5, summa6);
*!*			select eelarve, comEelarveRemote.nimetus, summa1, summa2, summa3, summa4, summa5, summa6; 
*!*			from eelarve_report_kond3 left outer join comEelarveRemote on comEelarveRemote.kood = eelarve_report_kond3.eelarve;
*!*			
*!*	* kondsummad4
*!*			
*!*			select left(eelarve,4) as eelarve,  sum(summa1) as summa1, sum(summa2) as summa2, sum(summa3) as summa3, sum(summa4) as summa4,;
*!*				 sum(summa5) as summa5, sum(summa6) as summa6 ;
*!*				 from eelarve_report_tmp;
*!*				group by left(eelarve_report_tmp.eelarve,4);
*!*				where left(eelarve_report_tmp.eelarve,2) in (select eelarve from eelarve_report_kond2) ;
*!*				into cursor eelarve_report_kond4	 

*!*			insert into eelarve_report1 (eelarve, nimetus, summa1, summa2, summa3, summa4, summa5, summa6);
*!*			select eelarve, comEelarveRemote.nimetus, summa1, summa2, summa3, summa4, summa5, summa6; 
*!*			from eelarve_report_kond4 left outer join comEelarveRemote on comEelarveRemote.kood = eelarve_report_kond4.eelarve;
*!*		

*!*	if used('eelarve_report_kond1')
*!*		use in eelarve_report_kond1
*!*	endif
*!*	if used('eelarve_report_kond2')
*!*		use in eelarve_report_kond2
*!*	endif
*!*	if used('eelarve_report_kond3')
*!*		use in eelarve_report_kond3
*!*	endif
*!*	if used('eelarve_report_kond4')
*!*		use in eelarve_report_kond4
*!*	endif
*!*	if used('eelarve_report_tmp')
*!*		use in eelarve_report_tmp
*!*	endif


			If !Empty (lError) And Used('eelarve_report1')
				Select eelarve_report1
				return .t.
			Endif

		Else
			Select 0
			Return .F.
		Endif
	Endif


