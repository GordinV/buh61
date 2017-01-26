Parameters tcFail
Local lnReturn, lnKogusumma
lnKogusumma = 0
lnReturn = 0
If Empty(tcFail) Or !File(tcFail)
	Return lnReturn
Endif


Create Cursor tmp_vanemtasu4 (nimi c(254),isikukood c(20), selg c(254), viitenumber c(20), Summa Y, arhiiv c(20) )


Create Cursor TMP_vv_IMPORT (aa c(20), doknum c(20), kpv d, konto c(20), nimi c(254),;
	pank c(3), tuhi c(1), db c(1), Summa N(14,2), viitenumber c(20), arhiiv c(20),;
	selgitus c(254), teenustasu N(12,2), valuuta c(3),regkood c(20) )

Append From (tcFail) Type Delimited With Character ';'

Select TMP_vv_IMPORT
Scan
	If Used('v_vanemtasu3')
* vanematetasu modul
* otsime isikud

		lcString = "select vanemtasu2.id, vanemtasu2.isikId, vanemtasu1.isikkood, vanemtasu.nimi, vanemtasu2.tunnus from vanemtasu2 "+;
			" INNER JOIN vanemtasu1 ON vanemtasu1.id = vanemtasu2.parentid "+;
			" WHERE LTRIM(RTRIM(vanemtasu2.number)) = '"+ Alltrim(TMP_vv_IMPORT.viitenumber)+"'" +;
			" and vanemtasu2.rekvid = " + Str(grekv)

		If gVersia = "VFP"
			lcString = lcString + " into cursor tmp_VV_isik"
			lnError = oDb.execsql(lcString,'tmp_vanemtasu')
		Else
			lnError = oDb.execsql(lcString,'tmp_vanemtasu')
		Endif
		If lnError < 1
			Exit
		Endif

		If Reccount('tmp_vanemtasu') > 0
* leidnud, salvestame

			If Reccount('tmp_vanemtasu') > 1
				Select tmp_vanemtasu
				Scan
					If Right(tmp_vanemtasu.tunnus,2) = Substr(lcViitenumber,12,2)
						lcTunnus = tmp_vanemtasu.tunnus
					Endif
				Endscan
				If Empty(lcTunnus)
					Go Top
					lcTunnus = tmp_vanemtasu.tunnus
				Endif

			Else
				lcTunnus = tmp_vanemtasu.tunnus
			Endif
			Use In tmp_vanemtasu
			Insert Into v_vanemtasu4 ( isikid, maksjakood , maksjanimi , Summa , konto, tp ,kood1, kood2,;
				kood3, kood4,kood5,Number, muud);
				VALUES (tmp_vanemtasu.isikid,TMP_vv_IMPORT.regkood, TMP_vv_IMPORT.nimi,TMP_vv_IMPORT.Summa,;
				'203900','800699','','','','','3220',TMP_vv_IMPORT.arhiiv,TMP_vv_IMPORT.selgitus )

		Else
* ei leidnud, salvestame aruandluseks
			Insert Into tmp_vanemtasu4 (nimi,isikukood, selg, viitenumber, Summa, arhiiv) Values ;
				(TMP_vv_IMPORT.nimi, TMP_vv_IMPORT.regkood, TMP_vv_IMPORT.selgitus,TMP_vv_IMPORT.viitenumber,;
				TMP_vv_IMPORT.Summa, TMP_vv_IMPORT.arhiiv)

		Endif
		lnKogusumma = lnKogusumma + TMP_vv_IMPORT.Summa


	Endif

Endscan
Use In TMP_vv_IMPORT

Return lnReturn
