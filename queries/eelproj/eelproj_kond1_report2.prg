Parameter tcWhere
* asutuse koondeelarve eelnõu
If gVersia <> 'PG'
	select 0
	return .f.
endif
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
	
	
		lError = oDb.Exec("sp_eelarve_aruanne1 ", Str(grekv)+;
			", DATE("+Str(Year(fltrAruanne.kpv1),4)+","+STR(Month(fltrAruanne.kpv1),2)+","+Str(Day(fltrAruanne.kpv1),2)+"),"+;
			" DATE("+Str(Year(fltrAruanne.kpv2),4)+","+STR(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+"),"+;
			str(fltrAruanne.asutusid,9)+",'"+ltrim(rtrim(fltrAruanne.tunnus))+"','"+;
			ltrim(rtrim(fltrAruanne.kood2))+"','"+;
			ltrim(rtrim(fltrAruanne.kood1))+"','"+ltrim(rtrim(fltrAruanne.kood5))+"','"+;
			ltrim(rtrim(fltrAruanne.proj))+"',3,"+;
			Str(fltrAruanne.kond,9),"qryEelarve1")

		If Used('qryEelarve1')
			tcTimestamp = Alltrim(qryEelarve1.sp_eelarve_aruanne1)
			lcString = "select distinct RekvIdSub, rekv.nimetus as asutus, tmp_eelproj_aruanne1.Eelarve, tmp_eelproj_aruanne1.Nimetus,"+;
			"  summa1, summa2, summa3, summa4, summa5, summa6, summa16 "+;
				"  from tmp_eelproj_aruanne1 inner join rekv on tmp_eelproj_aruanne1.RekvIdSub = rekv.id  where  rekvid = "+str(gRekv)+;
				" and (summa1 <> 0 or summa2 <> 0 or summa3 <> 0 summa4 or summa5 <> 0 or summa6 <> 0 or summa16 <> 0)"+;
			" and timestamp = '"+tcTimestamp +"' order by RekvIdSub,eelarve"
			lError = oDb.Execsql(lcString, 'eelarve_report1')

			If !Empty (lError) And Used('eelarve_report1')
				Select eelarve_report1
				return .t.
			Endif

		Else
			Select 0
			Return .F.
		Endif
	Endif


