Parameter tcWhere

*SET STEP ON

lcString = "select aasta, kuu, konto, tp, tegev, allikas, rahavoo, db, kr, saldoandmik.nimetus, rekv.nimetus as asutus "+;
	" from saldoandmik inner join rekv on saldoandmik.rekvid = rekv.id where "+;
			" konto like '"+alltrim(fltrAruanne.konto)+'%'+"'"+;
			" and aasta = "+STR(YEAR(fltrAruanne.kpv2),4) +" and kuu = "+STR(MONTH(fltrAruanne.kpv2),2)+;
			" and tp like '"+alltrim(fltrAruanne.tp)+'%'+"'"+;
			" and tegev like '"+alltrim(fltrAruanne.tegev)+'%'+"'"+;
			" and allikas like '"+alltrim(fltrAruanne.allikas)+'%'+"'"+;
			" and rahavoo like '"+alltrim(fltrAruanne.rahavoog)+'%'+"'"+;
			IIF( fltrAruanne.asutusId > 0," and rekvId = "+STR(fltrAruanne.asutusId),"")+; 
			" order by konto, tp, tegev, allikas, rahavoo  "
			
		lError = oDb.execsql(lcString, 'saldoaruanne_report1')

		If !Empty (lError) And Used('saldoaruanne_report1')
			Select saldoaruanne_report1
			Return
		Endif
