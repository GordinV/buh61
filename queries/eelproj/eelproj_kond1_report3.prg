Parameter tcWhere
* asutuse eelarve eelnõu koos hal
If gVersia <> 'PG'
	select 0
	return .f.
endif

create cursor eelarve_report1 (rekvid int, subrekvid int, asutus c(254), subasutus c(254), eelarve c(20),; 
	nimetus c(254), summa1 n(18,6), summa2 n(18,6), summa3 n(18,6), summa4 n(18,6), summa5 n(18,6), summa6 n(18,6), summa16 n(18,6))

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
			ltrim(rtrim(fltrAruanne.proj))+"',4,"+;
			Str(fltrAruanne.kond,9),"qryEelarve1")

		If Used('qryEelarve1')
			tcTimestamp = Alltrim(qryEelarve1.sp_eelarve_aruanne1)
			lcString = "select RekvIdSub as rekvid, rekv.nimetus as asutus, tmp_eelproj_aruanne1.Eelarve, tmp_eelproj_aruanne1.Nimetus, "+;
			" summa1, summa2, summa3, summa4, summa5, summa6, summa16 "+;
				"  from tmp_eelproj_aruanne1 inner join rekv on tmp_eelproj_aruanne1.RekvIdSub = rekv.id  where rekvid = "+str(gRekv)+;
			" and timestamp = '"+tcTimestamp +"' order by RekvIdSub,eelarve"
			lError = oDb.Execsql(lcString, 'eelarve_report_tmp')
			
			if empty(lError)
				return
			endif
			 
			select eelarve_report_tmp
			scan
				select comRekvRemote
				locate for comRekvRemote.id = eelarve_report_tmp.rekvid
				if 	comRekvRemote.parentid = 63 or comRekvRemote.parentid = 0 
					lnrekvid = comRekvRemote.id
					lcRekvNimi = comRekvRemote.nimetus
					lnrekvidSub = 0
					lcRekvSubNimi = ''				
				else
					lnrekvId = comRekvRemote.parentid				
					lnrekvidSub = comrekvRemote.id
					lcRekvSubNimi = comRekvRemote.nimetus				
					select comrekvRemote
					locate for id = lnrekvid
					lcRekvNimi = comRekvRemote.nimetus
				endif
							
			
				insert into eelarve_report1 (rekvid, subrekvid, asutus, subasutus, eelarve,	nimetus, summa1, summa2, summa3, summa4, summa5, summa6, summa16);
					values (lnrekvid, lnRekvidSub, lcRekvNimi, lcRekvSubNimi, eelarve_report_tmp.eelarve,	eelarve_report_tmp.nimetus, ;
					eelarve_report_tmp.summa1, eelarve_report_tmp.summa2, eelarve_report_tmp.summa3, eelarve_report_tmp.summa4,;
					eelarve_report_tmp.summa5, eelarve_report_tmp.summa6, eelarve_report_tmp.summa16)

			endscan
						
			use in eelarve_report_tmp


			If !Empty (lError) And Used('eelarve_report1')
				Select eelarve_report1
				return .t.
			Endif

		Else
			Select 0
			Return .F.
		Endif
	Endif


