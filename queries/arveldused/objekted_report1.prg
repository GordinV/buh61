Parameter cWhere

tcKood = ltrim(rtrim(fltrObjekt.kood))+'%'
tcNimetus = '%'+ltrim(rtrim(fltrObjekt.nimetus))+'%'
tcAsutus = '%'+ltrim(rtrim(fltrObjekt.asutus))+'%'

lcString = " select library.id,library.kood, library.nimetus, library.muud, "+;
	" ifnull(asutus.nimetus,'') as asutus, objekt.parentid, objekt.nait01, objekt.nait02, objekt.nait03, objekt.nait04, objekt.nait05, objekt.nait06, "+;
	" objekt.nait07, objekt.nait08, objekt.nait09, objekt.nait10, objekt.nait11, objekt.nait12, objekt.nait13, objekt.nait14, objekt.nait15, "+;
	" ifnull(maja.nimetus, SPACE(20)) as maja "+;
	" FROM library inner join objekt on library.id = objekt.libid left outer join asutus on objekt.asutusId = asutus.id "+;
	" left outer join library maja on maja.id = objekt.parentid "+;
	" WHERE Library.rekvid = " + STR(gRekv)+"   AND upper(Library.kood) LIKE UPPER ('" + tcKood + "')   AND upper(Library.nimetus) LIKE upper('"+;
	tcNimetus + "') and upper(ifnull(asutus.nimetus,'%')) like upper( '"+ tcAsutus + "') ORDER BY left(Library.nimetus,5),objekt.nait14, objekt.nait15 "
	
lError = SQLEXEC(gnHandle, lcString, 'objekt_report1')

IF lError < 0 
	_cliptext = lcString
	MESSAGEBOX('Viga')
	SELECT 0
	RETURN .f.
ENDIF
	
SELECT 	objekt_report1