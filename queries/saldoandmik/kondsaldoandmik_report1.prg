Parameter tcWhere

CREATE CURSOR saldoaruanne_report1 (konto c(20), tp c(20), tegev c(20), allikas c(20), rahavoo c(20), db n(18,6), kr n(18,6), nimetus c(254),;
	dbKokku n(18,6), krKokku n(18,6))


lcString = "select count(*) as count from pg_proc where proname = 'sp_saldoandmik_aruanned'"
lError = oDb.execsql(lcString, 'tmpProc')
If !Empty (lError) And Used('tmpProc') And !Empty(tmpProc.Count)
	Wait Window 'Serveri poolt funktsioon ...' Nowait
*	SET STEP ON 

	lError = oDb.Exec("sp_saldoandmik_aruanned ", Str(grekv)+", DATE("+Str(Year(fltrAruanne.kpv2),4)+","+;
		STR(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+"),"+str(year(fltrAruanne.kpv2))+",2,"+Str(fltrAruanne.arvestus,9)+","+Str(fltrAruanne.kond,9),"qrySaldoandmik")
	
*	lError = oDb.Exec("sp_saldoandmik_aruanned ", Str(grekv)+", DATE("+Str(Year(fltrAruanne.kpv2),4)+","+;
*		STR(Month(fltrAruanne.kpv2),2)+","+Str(Day(fltrAruanne.kpv2),2)+"),"+str(year(fltrAruanne.kpv2))+",2,"+Str(fltrAruanne.kond,9),"qrySaldoandmik")

	If Used('qrySaldoandmik')
		tcTimestamp = Alltrim(qrySaldoandmik.sp_saldoandmik_aruanned)
		lcString = "select konto, tp, tegev, allikas, rahavoo, sum(db) as db, sum(kr) as kr, ifnull(library.nimetus,SPACE(254)) as nimetus "+;
		"  from tmp_saldoandmik left outer join library ON(tmp_saldoandmik.konto = library.kood and library.library = 'KONTOD') "+;
			" where tmp_saldoandmik.rekvid = "+Str(grekv)+;
			" and tmp_saldoandmik.timestamp = '"+tcTimestamp +"'"+;
			" and tmp_saldoandmik.konto like '"+alltrim(fltrAruanne.konto)+'%'+"'"+;
			" and tmp_saldoandmik.tp like '"+alltrim(fltrAruanne.tp)+'%'+"'"+;
			" and tmp_saldoandmik.tegev like '"+alltrim(fltrAruanne.tegev)+'%'+"'"+;
			" and tmp_saldoandmik.allikas like '"+alltrim(fltrAruanne.allikas)+'%'+"'"+;
			" and tmp_saldoandmik.rahavoo like '"+alltrim(fltrAruanne.rahavoog)+'%'+"'"+;
			" group by konto, tp, tegev, allikas, rahavoo, library.nimetus "+;
			" order by konto, tp, tegev, allikas, rahavoo  "
			
		lError = oDb.execsql(lcString, 'saldoaruanne_report')

		If !Empty (lError) And Used('saldoaruanne_report')
			Select saldoaruanne_report
			scan
               INSERT INTO saldoaruanne_report1 (konto, tp, tegev, allikas, rahavoo, db, kr, nimetus);
                     	VALUES (saldoaruanne_report.konto, saldoaruanne_report.tp, saldoaruanne_report.tegev, ;
                     		saldoaruanne_report.allikas, saldoaruanne_report.rahavoo, saldoaruanne_report.db,;
                     		saldoaruanne_report.kr, saldoaruanne_report.nimetus)
			endscan
            SELECT sum(db) as dbkokku, sum(kr) as krkokku FROM saldoaruanne_report1 WHERE LEFT(konto,1) NOT in  ('8','9') into cursor tmpSKokku
            UPDATE saldoaruanne_report1 SET dbKokku = tmpSKokku.dbKokku, krKokku = tmpSKokku.krkokku 
             USE IN tmpSKokku
                     SELECT saldoaruanne_report1
                     GO top


			Return
		Endif

	Else
		Select 0
		Return .F.
	Endif
Endif
