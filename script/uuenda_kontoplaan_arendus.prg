Create Cursor results (Id Int, kood c(20), Library c(20))
* select * from kontoplaan, allikas, eelarve, tegev, rahavoog
lnHandle = SQLConnect('NarvaLvPg')
If lnHandle < 1
	Messagebox('Error in connect',0 + 48,'Error)
	Set Step On
	Return
Endif


TEXT TO lcSql TEXTMERGE noshow
	SELECT * from library WHERE LTRIM(RTRIM(library)) in ('KONTOD', 'ALLIKAD','TEGEV','TP','TULUDEALLIKAD', 'RAHA') AND NOT EMPTY(kood)
ENDTEXT

lError = SQLEXEC(lnHandle, lcSql, 'tmpLibs')

=SQLDISCONNECT(lnHandle)

If lError < 1
	Messagebox('Error in sql',0 + 48,'Error)
	Set Step On
	Return
Endif

* check if not exists

lnHandle = SQLConnect('arendus')
If lnHandle < 1
	Messagebox('Error in connect',0 + 48,'Error')
	Set Step On
	Return
Endif


Select tmpLibs
Scan
	Wait Window 'Checking :' + Alltrim(tmpLibs.kood) + '/' + Alltrim(tmpLibs.Library) + '...' Nowait

		TEXT TO lcSql TEXTMERGE noshow
				SELECT id FROM library WHERE LTRIM(RTRIM(kood)) = ?ALLTRIM(tmpLibs.kood) AND LTRIM(RTRIM(library)) = ?ALLTRIM(tmpLibs.library)	limit 1
		ENDTEXT

	lError = SQLEXEC(lnHandle, lcSql, 'tmpIds')

	If lError < 1
		Messagebox('Error in sql',0 + 48,'Error')
		Set Step On
		Exit
	Endif

	If Reccount('tmpIds') < 1
		* insert
		TEXT TO lcSql TEXTMERGE noshow
					INSERT INTO library (rekvid, kood, nimetus, library, tun1, tun2, tun3, tun4, tun5, muud)
						values (1, ?Alltrim(tmpLibs.kood), ?Alltrim(tmpLibs.nimetus), ?Alltrim(tmpLibs.library),
						?tmpLibs.tun1, ?tmpLibs.tun2, ?tmpLibs.tun3, ?tmpLibs.tun4, ?tmpLibs.tun5, 'Uuedatud 01.02.2018') returning id

		ENDTEXT

		lError = SQLEXEC(lnHandle, lcSql, 'tmpNewId')
		If lError < 1
			Messagebox('Error in sql',0 + 48,'Error')
			Set Step On
			Exit
		Else
			Insert Into results (Id, kood, Library) Values (tmpNewId.Id, tmpLibs.kood, tmpLibs.Library)

		Endif

		Wait Window 'New lib inserted ->' + Alltrim(tmpLibs.kood) + Alltrim(Str(tmpNewId.Id)) Timeout 1
	Endif

Endscan

SQLDISCONNECT(lnHandle)
SET STEP ON 
If lError > -1
	Select results
	Export To results.Xls Type Xls
	Messagebox('success, total inserted ' + Str(Reccount('results')), 0+ 48,'result')
Endif




