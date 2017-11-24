Parameter tcWhere
* KOFS strateegia vorm, eelarvearuanne
If gVersia <> 'PG'
	select 0
	return .f.
endif

create cursor eelarve_report1 (kood1 c(20), kood2 c(20), kood3 c(20), eelarve c(20),nimetus c(254), summa1 n(14,2), summa2 n(14,2), summa3 n(14,2),;
	summa4 n(18,8), summa5 n(18,8))
*SET STEP on

	lcString = "select count(*) as count from pg_proc where proname = 'sp_eelarve_aruanne1'"
	lError = oDb.execsql(lcString, 'tmpProc')
	If !Empty (lError) And Used('tmpProc') And !empty(tmpProc.Count)
		* kas period on kinnitatud
		
		lcString = "select kinni from aasta where aasta = "+STR(YEAR(fltrAruanne.kpv2),4)+" and kuu = "+STR(MONTH(fltrAruanne.kpv2),2)+;
			" and rekvid = "+STR(gRekv)
			
		lError = odb.execsql(lcString,'tmpAasta')
		IF !USED('tmpAasta')
			RETURN .f.
		ENDIF
		IF tmpAasta.kinni = 0
			lnAnswer = MESSAGEBOX('Kas re-arvesta eelarve täitmine?',4+32+256,'Eelarve')
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
*		fltrAruanne.tunn
	
			wait window 'Serveri poolt funktsioon ...' nowait	
		lError = oDb.Exec("sp_eelarve_aruanne1 ", Str(grekv)+;
			", DATE("+Str(Year(fltrAruanne.kpv1),4)+","+STR(Month(fltrAruanne.kpv1),2)+","+Str(Day(fltrAruanne.kpv1),2)+"),"+;
			" DATE("+Str(Year(fltrAruanne.kpv2),4)+","+STR(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+"),"+;
			str(fltrAruanne.asutusid,9)+",'"+ltrim(rtrim(fltrAruanne.tunnus))+"','"+;
			ltrim(rtrim(fltrAruanne.kood2))+"','"+;
			ltrim(rtrim(fltrAruanne.kood1))+"','"+ltrim(rtrim(fltrAruanne.kood5))+"','"+;
			ltrim(rtrim(fltrAruanne.proj))+"',8,"+;
			Str(fltrAruanne.kond,9),"qryEelarve1")

		If Used('qryEelarve1')
			tcTimestamp = Alltrim(qryEelarve1.sp_eelarve_aruanne1)
			
			IF EMPTY(fltrAruanne.tunn) 
			
			lcString = "select kood1, kood2, kood3, kood5 as Eelarve, tmp_eelproj_aruanne1.Nimetus, summa6 as summa1, summa2, (summa1 - summa2) as  summa3, summa4, summa5 "+;
				"  from tmp_eelproj_aruanne1 where rekvid = "+str(gRekv)+;
			" and LTRIM(RTRIM(timestamp)) = '"+tcTimestamp +"' order by kood1, kood2, kood3, kood5"
			
			ELSE
			lcString = "select kood1, kood2, kood3, kood5 as Eelarve, tmp_eelproj_aruanne1.Nimetus, summa1, summa2, (summa1 - summa2) as  summa3, summa4, summa5 "+;
				"  from tmp_eelproj_aruanne1 where rekvid = "+str(gRekv)+;
			" and LTRIM(RTRIM(timestamp)) = '"+tcTimestamp +"' order by kood1, kood2, kood3, kood5"
			
			ENDIF
			
			
			lError = oDb.Execsql(lcString, 'eelarve_report_tmp')
		
			if empty(lError)
				return
			endif
			wait window 'Serveri poolt funktsioon ...tehtud' nowait	
			 
			select eelarve_report1 
			APPEND from DBF('eelarve_report_tmp')

			IF USED('eelarve_report_tmp')
				use in eelarve_report_tmp
			ENDIF
			IF USED('qryEelarve1')
				USE IN qryEelarve1
			ENDIF
			

			If !Empty (lError) And Used('eelarve_report1')
				Select eelarve_report1
				return .t.
			Endif

		Else
			Select 0
			Return .F.
		Endif
	Endif


