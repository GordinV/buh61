Set step on
On error do err
cSource = 'VFP'
gRekvSource = 1
gUserSource = 1
gVersiaSource = 'VFP'
&&cDataSource = 'c:\files\buh52\dbase\buhdata5.dbc'
cDataSource = 'c:\buh50\dbavpsoft\buhdata5.dbc'
gnhandleSource = 1
Open data (cDataSource)

cDest = 'MSSQL'
gRekvDest = 4
gUserDest = 4
gVersiaDest = 'MSSQL'
cDataDest = 'MSSQLAVPSOFT'
gnhandleDest = sqlconnect (cDataDest)
If gnhandleDest < 1
	Messagebox('Viga: uhendus')
	Return .f.
Endif
lnError=sqlexec (gnhandleDest,'BEGIN TRANSACTION')
*!*	If !file ('buh50trans.dbf')
	Create table buh50trans free (idDest int, idSource int, tbl c(60))
*!*	Endif
Create cursor transtest (tblNimi c(60), KiriSource int, KiriDest int)
If !used ('buh50trans')
	Use buh50trans in 0
Endif

*!*	lerror = get_tbls_list ()
*!*	if lError = .f. or !used ('qryObjekt')
*!*		return .f.
*!*	endif
*!*	select qryObjekt
*!*	scan
*!*	endscan
lnvalidateId = 0
lError = .t.
*!*	lError = transmit_table('REKV')
*!*	If lError = .t.
*!*		lError = transmit_table('USERID')
*!*	Endif

If lError = .t.
	lError = transmit_table('AA')
Endif
If lError = .t.
	lError = transmit_table('AASTA')
Endif
If lError = .t.
	lError = transmit_table('ASUTUS')
Endif
If lError = .t.
	lError = transmit_table('LIBRARY')
Endif
If lError = .t.
	lError = transmit_table('LAUSEND')
Endif
If lError = .t.
	lError = transmit_table('DOKPROP')
Endif
If lError = .t.
	=clean_ref_integrity('KONTOINF')
	lError = transmit_table('LAUSDOK')
Endif
If lError = .t.
	lError = transmit_table('NOMENKLATUUR')
Endif
If lError = .t.
	=clean_ref_integrity('KONTOINF')
	lError = transmit_table('KONTOINF')
Endif
If lError = .t.
	lError = transmit_table('LADU_CONFIG')
Endif
If lError = .t.
	lError = transmit_table('LADU_OPER')
Endif
If lError = .t.
	=clean_ref_integrity('LADU_GRUPP')
	lError = transmit_table('LADU_GRUPP')
Endif
If lError = .t.
	=clean_ref_integrity('LADU_JAAK')
	lError = transmit_table('LADU_JAAK')
Endif
If lError = .t.
	=clean_ref_integrity('LADU_MINKOGUS')
	lError = transmit_table('LADU_MINKOGUS')
Endif
If lError = .t.
	=clean_ref_integrity('LADU_ULEHIND')
	lError = transmit_table('LADU_ULEHIND')
Endif
If lError = .t.
	lError = transmit_table('LEPING1')
Endif
If lError = .t.
	=clean_ref_integrity('LEPING2')
	lError = transmit_table('LEPING2')
Endif
If lError = .t.
	=clean_ref_integrity('LEPING3')
	lError = transmit_table('LEPING3')
Endif
If lError = .t.
	=clean_ref_integrity('GRUPPOMANDUS')
	lError = transmit_table('GRUPPOMANDUS')
Endif
If lError = .t.
	lError = transmit_table('HOLIDAYS')
Endif
If lError = .t.
	lError = transmit_table('EELARVE')
Endif
If lError = .t.
	lError = transmit_table('EEL_CONFIG')
Endif
If lError = .t.
	lError = transmit_table('JOURNAL')
Endif
If lError = .t.
	=clean_ref_integrity('JOURNAL1')
	lError = transmit_table('JOURNAL1')
Endif
If lError = .t.
	=clean_ref_integrity('JOURNALID')
	lError = transmit_table('JOURNALID')
Endif
If lError = .t.
	lError = transmit_table('ARV')
Endif
If lError = .t.
	=clean_ref_integrity('ARV1')
	lError = transmit_table('ARV1')
Endif
If lError = .t.
	lError = transmit_table('SORDER1')
Endif
If lError = .t.
	=clean_ref_integrity('SORDER2')
	lError = transmit_table('SORDER2')
Endif
If lError = .t.
	lError = transmit_table('VORDER1')
Endif
If lError = .t.
	=clean_ref_integrity('VORDER2')
	lError = transmit_table('VORDER2')
Endif
If lError = .t.
	lError = transmit_table('PALK_CONFIG')
Endif
If lError = .t.
	lError = transmit_table('PALK_ASUTUS')
Endif
If lError = .t.
	lError = transmit_table('TOOLEPING')
Endif
If lError = .t.
	lError = transmit_table('PALK_LIB')
Endif
If lError = .t.
	lError = transmit_table('PALK_KAART')
Endif
If lError = .t.
	lError = transmit_table('PALK_OPER')
Endif
If lError = .t.
	lError = transmit_table('PALK_JAAK')
Endif
If lError = .t.
	lError = transmit_table('PALK_TAABEL1')
Endif
If lError = .t.
&&	=clean_ref_integrity('PALK_TAABEL2')
	lError = transmit_table('PALK_TAABEL2')
Endif
If lError = .t.
	lError = transmit_table('PUUDUMINE')
Endif
If lError = .t.
	lError = transmit_table('TOOGRAF')
Endif
If lError = .t.
	lError = transmit_table('PV_KAART')
Endif
If lError = .t.
	lError = transmit_table('PV_OPER')
Endif
If lError = .t.
	lError = transmit_table('SALDO')
Endif
If lError = .t.
	lError = transmit_table('SALDO1')
Endif
If lError = .t.
	lError = transmit_table('TEENUSED')
Endif
If lError = .t.
	lError = transmit_table('TULUDKULUD')
Endif
If lError = .t.
	=clean_ref_integrity('KLASSIFLIB')
	lError = transmit_table('KLASSIFLIB')
Endif
If lError = .t.
	=clean_ref_integrity('SUBKONTO')
	lError = transmit_table('SUBKONTO')
Endif
If lError = .t.
	lError = transmit_table('ARVTASU')
Endif
If lError = .t.
	lError = transmit_table('DOKLAUSHEADER')
Endif
If lError = .t.
	lError = transmit_table('DOKLAUSEND')
Endif
If lError = .t.
	lError = transmit_table('MK')
Endif
If lError = .t.
	=clean_ref_integrity('MK1')
	lError = transmit_table('MK1')
Endif
If lError = .t.
	=sqlexec (gnhandleDest,'COMMIT')
	Messagebox ('Ok','Kontrol')
Else
	=sqlexec (gnhandleDest,'ROLLBACK')
	Messagebox ('Viga','Kontrol')
Endif

On error
Select transtest
Browse
If used ('qryDeleted')
	Copy memo qryDeleted.rec to c:\temp\report.prn
	Messagebox('Отчет скопирован в файл c:\temp\report.prn')
	Use in qryDeleted
Endif

Procedure chkdouble
	Parameter tctable
	Local lused, lcstring
	
gRekvDest = 27
gUserDest = 66
gVersiaDest = 'MSSQL'
cDataDest = 'RUGODIV'
gnhandleDest = sqlconnect (cDataDest)
If gnhandleDest < 1
	Messagebox('Viga: uhendus')
	Return .f.
Endif
tctable = 'KONTOINF'	
	Create cursor qryidx_ (id int, inx c(20), algsaldo y)
	Index on inx + str (algsaldo,12,2) desc tag inx
	Do case
		Case tctable = 'KONTOINF'
			lcstring = 'select id, ltrim(rtrim(str (parentid))) as inx, algsaldo from kontoinf where rekvid = '+str (gRekvDest)
		Case tctable = 'SUBKONTO'
			lcstring = 'select id, ltrim(rtrim(str (kontoid)))+'-'+ltrim(rtrim(str(asutusId))) as inx, algsaldo from subkonto where rekvid = '+str (gRekvDest)
	Endcase
	Do case
		Case gVersiaDest = 'MSSQL'
			=sqlexec (gnhandleDest,lcstring,'qryIdx')
		Case gVersiaDest = 'VFP'
			lcstring = lcstring + ' into cursor qryIdx'
			&lcstring
	Endcase
	If !used ('qryIdx')
		Return .f.
	Endif
	Select qryidx_
	If reccount () > 0
		Zap
	Endif
	Append from dbf ('qryIdx')
	Use in qryIdx
	lcVanaIdx = ''
	lused = .f.
	Scan
		wait window str (recno('qryIdx_'))+'/'+str(reccount('qryIdx_')) nowait
		If lcVanaIdx <> qryidx_.inx
&& первая запись
			lcVanaIdx = qryidx_.inx
		Else
			lcstring = 'delete from '+tctable+ ' where id = '+str (qryidx_.id)
		Endif
		Do case
			Case gVersiaDest = 'MSSQL'
				=sqlexec (gnhandleDest,lcstring)
			Case gVersiaDest = 'VFP'
				&lcstring
		Endcase

	Endscan
Endproc

Procedure err
	lnErr = aerror(err)
	If lnErr > 0 and err(1,1) <> 1463  and !isnull(err(1,2))
		Messagebox('Viga'+err(1,2))
		Set step on
	Endif
Endproc

Function transmit_table
	Parameter tctable
	Local lError
	lResult = get_table_data ()
	Insert into transtest (tblNimi, KiriSource, KiriDest) values (tctable,reccount ('sqlResult'),0)
	lError = .t.
	If cDest = 'VFP'
		Begin transaction
	Else
		=sqlexec(gnhandleDest,'begin transaction')
	Endif
	lnId = 0
	If lResult = .t. and used ('sqlresult')
		Select sqlresult
		Scan
			Wait window tctable + ':'+str(recno('sqlResult'))+'/'+str(reccount ('sqlresult')) nowait
			Do case
				Case alltrim(upper(tctable)) = 'USERID'
					Select buh50trans
					Replace sqlresult.rekvid with gRekvDest  in sqlresult

				Case alltrim(upper(tctable)) = 'MK1'
					Select buh50trans
					If !empty (sqlresult.Parentid)
						Locate for upper(alltrim(tbl)) = 'MK' and;
							idSource = sqlresult.Parentid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.Parentid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					Select buh50trans
					If !empty (sqlresult.nomid)
						Locate for upper(alltrim(tbl)) = 'NOMENKLATUUR' and;
							idSource = sqlresult.nomid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.nomid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					Select buh50trans
					If !empty (sqlresult.Journalid)
						Locate for upper(alltrim(tbl)) = 'JOURNAL' and;
							idSource = sqlresult.Journalid
						If !found()
							Replace sqlresult.Journalid with 0  in sqlresult
						Else
							Replace sqlresult.Journalid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					Select buh50trans
					If !empty (sqlresult.asutusid)
						Locate for upper(alltrim(tbl)) = 'ASUTUS' and;
							idSource = sqlresult.asutusid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.asutusid with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'MK'
					Replace rekvid with gRekvDest in sqlresult
					Select buh50trans
					If !empty (sqlresult.aaid)
						Locate for upper(alltrim(tbl)) = 'AA' and;
							idSource = sqlresult.aaid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.aaid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.Doklausid)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'DOKPROP' and;
							idSource = sqlresult.Doklausid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.Doklausid with buh50trans.idDest  in sqlresult
						Endif
					Endif

				Case alltrim(upper(tctable)) = 'DOKLAUSEND'
					Select buh50trans
					If !empty (sqlresult.Parentid)
						Locate for upper(alltrim(tbl)) = 'DOKLAUSHEADER' and;
							idSource = sqlresult.Parentid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.Parentid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.kood1)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.kood1
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.kood1 with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.kood2)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.kood2
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.kood2 with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.kood3)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.kood3
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.kood3 with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.kood4)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.kood4
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.kood4 with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.kood5)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.kood5
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.kood5 with buh50trans.idDest  in sqlresult
						Endif
					Endif

				Case alltrim(upper(tctable)) = 'DOKLAUSHEADER'
					Replace rekvid with gRekvDest  in sqlresult
				Case alltrim(upper(tctable)) = 'ARVTASU'
					Replace rekvid with gRekvDest  in sqlresult
					Select buh50trans
					If !empty (sqlresult.ArvId)
						Locate for upper(alltrim(tbl)) = 'ARV' and;
							idSource = sqlresult.ArvId
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.ArvId with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.nomid)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'NOMENKLATUUR' and;
							idSource = sqlresult.nomid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.nomid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.Journalid)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'JOURNAL' and;
							idSource = sqlresult.Journalid
						If !found()
							Replace sqlresult.Journalid with 0  in sqlresult
						Else
							Replace sqlresult.Journalid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.SorderId)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'SORDER1' and;
							idSource = sqlresult.SorderId
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.SorderId with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'SUBKONTO'
					Replace rekvid with gRekvDest  in sqlresult
					Select buh50trans
					If !empty (sqlresult.KontoId)
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.KontoId
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.KontoId with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.asutusid)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'ASUTUS' and;
							idSource = sqlresult.asutusid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.asutusid with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'KLASSIFLIB'
					Select buh50trans
					If !empty (sqlresult.lausendId)
						Locate for upper(alltrim(tbl)) = 'LAUSEND' and;
							idSource = sqlresult.lausendId
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.lausendId with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.PalkLibId)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.PalkLibId
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.PalkLibId with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.LibId)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.LibId
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.LibId with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.kood1)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.kood1
						If !found()
							Select sqlresult
							Delete next 1
						Else

							Replace sqlresult.kood1 with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.kood2)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.kood2
						If !found()
							Select sqlresult
							Delete next 1
						Else

							Replace sqlresult.kood2 with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.kood3)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.kood3
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.kood3 with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.kood4)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.kood4
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.kood4 with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.kood5)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.kood5
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.kood5 with buh50trans.idDest  in sqlresult
						Endif
					Endif

				Case alltrim(upper(tctable)) = 'TULUDKULUD'
					Replace rekvid with gRekvDest  in sqlresult
					Select buh50trans
					If !empty (sqlresult.lausendId)
						Locate for upper(alltrim(tbl)) = 'LAUSEND' and;
							idSource = sqlresult.lausendId
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.lausendId with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'TEENUSED'
					Replace rekvid with gRekvDest  in sqlresult
					Select buh50trans
					If !empty (sqlresult.asutusid)
						Locate for upper(alltrim(tbl)) = 'ASUTUS' and;
							idSource = sqlresult.asutusid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.asutusid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.isikId)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'ASUTUS' and;
							idSource = sqlresult.isikId
						If !found()
							Select sqlresult
							Delete next 1
						Else

							Replace sqlresult.isikId with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.nomid)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'NOMENKLATUUR' and;
							idSource = sqlresult.nomid
						If !found()
							Select sqlresult
							Delete next 1
						Else

							Replace sqlresult.nomid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.ArvId)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'ARV' and;
							idSource = sqlresult.ArvId
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.ArvId with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'SALDO1'
					Replace rekvid with gRekvDest  in sqlresult
					Select buh50trans
					If !empty (sqlresult.asutusid)
						Locate for upper(alltrim(tbl)) = 'ASUTUS' and;
							idSource = sqlresult.asutusid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.asutusid with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'SALDO'
					Replace rekvid with gRekvDest  in sqlresult
				Case alltrim(upper(tctable)) = 'PV_OPER'
					Select buh50trans
					If !empty (sqlresult.Parentid)
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.Parentid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.Parentid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.nomid)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'NOMENKLATUUR' and;
							idSource = sqlresult.nomid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.nomid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.Doklausid)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'DOKPROP' and;
							idSource = sqlresult.Doklausid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.Doklausid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.lausendId)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LAUSEND' and;
							idSource = sqlresult.lausendId
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.lausendId with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.Journalid)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'JOURNAL' and;
							idSource = sqlresult.Journalid
						If !found()
							Replace sqlresult.Journalid with 0  in sqlresult
						Else
							Replace sqlresult.Journalid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.Journal1Id)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'JOURNAL1' and;
							idSource = sqlresult.Journal1Id
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.Journal1Id with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'PV_KAART'
					Select buh50trans
					If !empty (sqlresult.Parentid)
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.Parentid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.Parentid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.VastIsikId)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'ASUTUS' and;
							idSource = sqlresult.VastIsikId
						Replace sqlresult.VastIsikId with buh50trans.idDest  in sqlresult
					Endif
					If !empty (sqlresult.gruppId)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.gruppId
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.gruppId with buh50trans.idDest  in sqlresult
						Endif
					Endif

				Case alltrim(upper(tctable)) = 'TOOGRAF'
					Select buh50trans
					If !empty (sqlresult.LepingId)
						Locate for upper(alltrim(tbl)) = 'TOOLEPING' and;
							idSource = sqlresult.LepingId
						If !found()
							Select sqlresult
							Delete next 1
						Else

							Replace sqlresult.LepingId with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'PUUDUMINE'
					Select buh50trans
					If !empty (sqlresult.LepingId)
						Locate for upper(alltrim(tbl)) = 'TOOLEPING' and;
							idSource = sqlresult.LepingId
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.LepingId with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'PALK_TAABEL2'
					Select buh50trans
					If !empty (sqlresult.Parentid)
						Locate for upper(alltrim(tbl)) = 'PALK_TAABEL1' and;
							idSource = sqlresult.Parentid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.Parentid with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'PALK_TAABEL1'
					Select buh50trans
					If !empty (sqlresult.TooLepingId)
						Locate for upper(alltrim(tbl)) = 'TOOLEPING' and;
							idSource = sqlresult.TooLepingId
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.TooLepingId with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'PALK_JAAK'
					Select buh50trans
					If !empty (sqlresult.LepingId)
						Locate for upper(alltrim(tbl)) = 'TOOLEPING' and;
							idSource = sqlresult.LepingId
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.LepingId with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'PALK_OPER'
					Replace rekvid with gRekvDest  in sqlresult
					Select buh50trans
					If !empty (sqlresult.LepingId)
						Locate for upper(alltrim(tbl)) = 'TOOLEPING' and;
							idSource = sqlresult.LepingId
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.LepingId with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.LibId)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.LibId
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.LibId with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.Doklausid)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'DOKPROP' and;
							idSource = sqlresult.Doklausid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.Doklausid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.Journalid)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'JOURNAL' and;
							idSource = sqlresult.Journalid
						If !found()
							Replace sqlresult.Journalid with 0  in sqlresult
						Else
							Replace sqlresult.Journalid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.Journal1Id)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'JOURNAL1' and;
							idSource = sqlresult.Journal1Id
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.Journal1Id with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'PALK_KAART'
					Select buh50trans
					If !empty (sqlresult.Parentid)
						Locate for upper(alltrim(tbl)) = 'ASUTUS' and;
							idSource = sqlresult.Parentid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.Parentid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.LepingId)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'TOOLEPING' and;
							idSource = sqlresult.LepingId
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.LepingId with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.LibId)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.LibId
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.LibId with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'TOOLEPING'
					Select buh50trans
					If !empty (sqlresult.Parentid)
						Locate for upper(alltrim(tbl)) = 'ASUTUS' and;
							idSource = sqlresult.Parentid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.Parentid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.OsakondId)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.OsakondId
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.OsakondId with buh50trans.idDest  in sqlresult
						Endif
					Endif

					If !empty (sqlresult.AmetId)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.AmetId
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.AmetId with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'PALK_LIB'
					Select buh50trans
					If !empty (sqlresult.Parentid)
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.Parentid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.Parentid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.lausendId)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LAUSEND' and;
							idSource = sqlresult.Parentid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.Parentid with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'PALK_CONFIG'
					Replace rekvid with gRekvDest  in sqlresult
				Case alltrim(upper(tctable)) = 'PALK_ASUTUS'
					Replace rekvid with gRekvDest  in sqlresult
					Select buh50trans
					If !empty (sqlresult.OsakondId)
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.OsakondId
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.OsakondId with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.AmetId)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.AmetId
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.AmetId with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'LEPING3'
					Select buh50trans
					If !empty (sqlresult.Parentid)
						Locate for upper(alltrim(tbl)) = 'LEPING2' and;
							idSource = sqlresult.Parentid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.Parentid with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'LEPING2'
					Select buh50trans
					If !empty (sqlresult.Parentid)
						Locate for upper(alltrim(tbl)) = 'LEPING1' and;
							idSource = sqlresult.Parentid
						If !found()
							Select sqlresult
							Delete next 1
						Else

							Replace sqlresult.Parentid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					Select buh50trans
					If !empty (sqlresult.nomid)
						Locate for upper(alltrim(tbl)) = 'NOMENKLATUUR' and;
							idSource = sqlresult.nomid
						If !found()
							Select sqlresult
							Delete next 1
						Else

							Replace sqlresult.nomid with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'LEPING1'
					Replace rekvid with gRekvDest  in sqlresult
					Select buh50trans
					If !empty (sqlresult.asutusid)
						Locate for upper(alltrim(tbl)) = 'ASUTUS' and;
							idSource = sqlresult.asutusid
						If !found()
							Select sqlresult
							Delete next 1
						Else

							Replace sqlresult.asutusid with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'LADU_ULEHIND'
					Select buh50trans
					If !empty (sqlresult.Parentid)
						Locate for upper(alltrim(tbl)) = 'NOMENKLATUUR' and;
							idSource = sqlresult.Parentid
						If !found()
							Select sqlresult
							Delete next 1
						Else

							Replace sqlresult.Parentid with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'LADU_MINKOGUS'
					Select buh50trans
					If !empty (sqlresult.Parentid)
						Locate for upper(alltrim(tbl)) = 'NOMENKLATUUR' and;
							idSource = sqlresult.Parentid
						If !found()
							Select sqlresult
							Delete next 1
						Else

							Replace sqlresult.Parentid with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'LADU_JAAK'
					Replace rekvid with gRekvDest,;
						userid with gUserDest in sqlresult
					Select buh50trans
					If !empty (sqlresult.dokItemId)
						Locate for upper(alltrim(tbl)) = 'ARV1' and;
							idSource = sqlresult.dokItemId
						If !found()
							Select sqlresult
							Delete next 1
						Else

							Replace sqlresult.dokItemId with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.nomid)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'NOMENKLATUUR' and;
							idSource = sqlresult.nomid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.nomid with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'LADU_GRUPP'
					Select buh50trans
					If !empty (sqlresult.Parentid)
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.Parentid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.Parentid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					Select buh50trans
					If !empty (sqlresult.nomid)
						Locate for upper(alltrim(tbl)) = 'NOMENKLATUUR' and;
							idSource = sqlresult.nomid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.nomid with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'VORDER2'
					Select buh50trans
					If !empty (sqlresult.Parentid)
						Locate for upper(alltrim(tbl)) = 'VORDER1' and;
							idSource = sqlresult.Parentid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.Parentid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.nomid)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'NOMENKLATUUR' and;
							idSource = sqlresult.nomid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.nomid with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'VORDER1'
					Replace rekvid with gRekvDest,;
						userid with gUserDest in sqlresult
					Select buh50trans
					If !empty (sqlresult.Kassaid)
						Locate for upper(alltrim(tbl)) = 'AA' and;
							idSource = sqlresult.Kassaid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.Kassaid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.Journalid)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'JOURNAL' and;
							idSource = sqlresult.Journalid
						If !found()
							Replace sqlresult.Journalid with 0  in sqlresult
						Else
							Replace sqlresult.Journalid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.Doklausid)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'DOKPROP' and;
							idSource = sqlresult.Doklausid
						If !found()
							Select sqlresult
							Delete next 1
						Else
							Replace sqlresult.Doklausid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.asutusid)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'ASUTUS' and;
							idSource = sqlresult.asutusid
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.asutusid with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'SORDER2'
					Select buh50trans
					If !empty (sqlresult.Parentid)
						Locate for upper(alltrim(tbl)) = 'SORDER1' and;
							idSource = sqlresult.Parentid
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.Parentid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.nomid)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'NOMENKLATUUR' and;
							idSource = sqlresult.nomid
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.nomid with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'SORDER1'
					Replace rekvid with gRekvDest,;
						userid with gUserDest in sqlresult
					Select buh50trans
					If !empty (sqlresult.Kassaid)
						Locate for upper(alltrim(tbl)) = 'AA' and;
							idSource = sqlresult.Kassaid
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.Kassaid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.Journalid)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'JOURNAL' and;
							idSource = sqlresult.Journalid
						If found()
							Replace sqlresult.Journalid with buh50trans.idDest  in sqlresult
						Else
							Replace sqlresult.Journalid with 0  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.Doklausid)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'DOKPROP' and;
							idSource = sqlresult.Doklausid
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.Doklausid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.asutusid)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'ASUTUS' and;
							idSource = sqlresult.asutusid
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.asutusid with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'ARV1'
					Select buh50trans
					If !empty (sqlresult.Parentid)
						Locate for upper(alltrim(tbl)) = 'ARV' and;
							idSource = sqlresult.Parentid
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.Parentid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.nomid)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'NOMENKLATUUR' and;
							idSource = sqlresult.nomid
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.nomid with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'ARV'
					Replace rekvid with gRekvDest,;
						userid with gUserDest in sqlresult
					Select buh50trans
					If !empty (sqlresult.Journalid)
						Locate for upper(alltrim(tbl)) = 'JOURNAL' and;
							idSource = sqlresult.Journalid
						If !found()
							Replace sqlresult.Journalid with 0  in sqlresult
						Else
							Replace sqlresult.Journalid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.Doklausid)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'DOKPROP' and;
							idSource = sqlresult.Doklausid
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.Doklausid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.asutusid)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'ASUTUS' and;
							idSource = sqlresult.asutusid
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.asutusid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.ArvId)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'AA' and;
							idSource = sqlresult.ArvId
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.ArvId with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.Operid)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LADU_OPER' and;
							idSource = sqlresult.Operid
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.Operid with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'JOURNALID'
					Replace rekvid with gRekvDest in sqlresult
					Select buh50trans
					If !empty (sqlresult.Journalid)
						Locate for upper(alltrim(tbl)) = 'JOURNAL' and;
							idSource = sqlresult.Journalid
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.Journalid with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'JOURNAL1'
					Select buh50trans
					If !empty (sqlresult.Parentid)
						Locate for upper(alltrim(tbl)) = 'JOURNAL' and;
							idSource = sqlresult.Parentid
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.Parentid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.lausendId)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LAUSEND' and;
							idSource = sqlresult.lausendId
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.lausendId with buh50trans.idDest  in sqlresult
						Endif
					Endif


					If !empty (sqlresult.kood1)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.kood1
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.kood1 with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.kood2)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.kood2
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else

							Replace sqlresult.kood2 with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.kood3)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.kood3
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.kood3 with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.kood4)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.kood4
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else

							Replace sqlresult.kood4 with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.kood5)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.kood5
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.kood5 with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'JOURNAL'
					Select buh50trans
					Replace rekvid with gRekvDest ,;
						userid with gUserDest in sqlresult
					If !empty (sqlresult.dokid)
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.dokid
						If !found ()
							Replace dokid with 0 in sqlresult
						Else
							Replace sqlresult.dokid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.asutusid)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'ASUTUS' and;
							idSource = sqlresult.asutusid
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.asutusid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.TunnusId)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.TunnusId
						If !found ()
							Replace TunnusId WITH 0 IN sqlresult
						Else
							Replace sqlresult.TunnusId with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'EEL_CONFIG'
					Select buh50trans
					Replace rekvid with gRekvDest  in sqlresult
				Case alltrim(upper(tctable)) = 'EELARVE'
					Select buh50trans
					Replace rekvid with gRekvDest  in sqlresult
					If !empty (sqlresult.allikasid)
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.allikasid
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.allikasid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.TunnusId)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.TunnusId
						If !found ()
							Replace TunnusId with 0 in sqlresult
						Else
							Replace sqlresult.TunnusId with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.kood1)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.kood1
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.kood1 with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.kood2)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.kood2
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.kood2 with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.kood3)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.kood3
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.kood3 with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.kood4)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.kood4
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.kood4 with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'HOLIDAYS'
					Select buh50trans
					Replace rekvid with gRekvDest  in sqlresult
				Case alltrim(upper(tctable)) = 'GRUPPOMANDUS'
					If !empty (sqlresult.Parentid)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.Parentid
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.Parentid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.lausendId)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LAUSEND' and;
							idSource = sqlresult.lausendId
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.lausendId with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.Operid)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LADU_OPER' and;
							idSource = sqlresult.Operid
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.Operid with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.kood1) and !deleted()
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.kood1
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.kood1 with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.kood2) and !deleted()
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.kood2
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.kood2 with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.kood3) and !deleted()
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.kood3
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.kood3 with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.kood4) and !deleted()
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.kood4
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.kood4 with buh50trans.idDest  in sqlresult
						Endif
					Endif
					If !empty (sqlresult.kood5) and !deleted()
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.kood5
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.kood5 with buh50trans.idDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'LADU_OPER'
					Select buh50trans
					Replace rekvid with gRekvDest  in sqlresult
				Case alltrim(upper(tctable)) = 'LADU_CONFIG'
					Select buh50trans
					Replace rekvid with gRekvDest  in sqlresult
				Case alltrim(upper(tctable)) = 'KONTOINF'
					Select buh50trans
					If !empty (sqlresult.Parentid)
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.Parentid
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.Parentid with buh50trans.idDest,;
								rekvid with gRekvDest  in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'NOMENKLATUUR'
					Select buh50trans
					Replace sqlresult.rekvid with gRekvDest in sqlresult
				Case alltrim(upper(tctable)) = 'LAUSDOK'
					Select buh50trans
					If !empty (sqlresult.dokid)
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.dokid
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else

							Replace sqlresult.dokid with buh50trans.idDest in sqlresult
						Endif
					Endif
					Select buh50trans
					If !empty (sqlresult.lausendId)
						Locate for upper(alltrim(tbl)) = 'LAUSEND' and;
							idSource = sqlresult.lausendId
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.lausendId with buh50trans.idDest in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'DOKPROP'
					Select buh50trans
					If !empty (sqlresult.Parentid)
						Locate for upper(alltrim(tbl)) = 'LIBRARY' and;
							idSource = sqlresult.Parentid
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.Parentid with buh50trans.idDest in sqlresult
						Endif
					Endif
					If !empty (sqlresult.KBMLAUSENDID)
						Select buh50trans
						Locate for upper(alltrim(tbl)) = 'LAUSEND' and;
							idSource = sqlresult.KBMLAUSENDID
						If !found()
							Select sqlresult
							Delete next 1
							 
						Else
							Replace sqlresult.KBMLAUSENDID with buh50trans.idDest in sqlresult
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'LAUSEND'
&&						lError = validate_field(tctable,'NIMETUS')
					Select buh50trans
*!*							locate for upper(alltrim(tbl)) = 'REKV' and;
*!*								idsource = sqlresult.rekvid
					Replace sqlresult.rekvid with gRekvDest in sqlresult
				Case alltrim(upper(tctable)) = 'ASUTUS'
					lnvalidateId = validate_field(tctable,'REGKOOD')
					Select buh50trans
*!*							locate for upper(alltrim(tbl)) = 'REKV' and;
*!*								idsource = sqlresult.rekvid
					Replace sqlresult.rekvid with gRekvDest in sqlresult
				Case alltrim(upper(tctable)) = 'AASTA'
					Select buh50trans
*!*							locate for upper(alltrim(tbl)) = 'REKV' and;
*!*								idsource = sqlresult.rekvid
					Replace sqlresult.rekvid with gRekvDest in sqlresult
				Case alltrim(upper(tctable)) = 'AA'
					Select buh50trans
*!*							locate for upper(alltrim(tbl)) = 'REKV' and;
*!*								idsource = sqlresult.parentid
					Replace sqlresult.Parentid with gRekvDest in sqlresult
*!*					Case alltrim(upper(tctable)) = 'REKV'
*!*						lError = validate_field(tctable,'REGKOOD')
*!*						if sqlresult.parentid > 0
*!*							&& определение вышестоящей организации
*!*							select buh50trans
*!*							locate for upper(alltrim(tbl)) = 'REKV' and;
*!*								idsource = sqlresult.parentid
*!*							if found ()
*!*								lnParentRekvId = buh50trans.idDest
*!*							else
*!*								lnParentRekvId = 0
*!*							endif
*!*							replace sqlresult.parentId with iif (found (),buh50trans.idDest,0) in sqlresult
*!*						endif
				Case alltrim(upper(tctable)) = 'LIBRARY'
					lnvalidateId = validate_field(tctable,'KOOD')
					Replace sqlresult.rekvid with gRekvDest in sqlresult
			Endcase
			Select sqlresult
			Set delete off
			If deleted()
				If !used ('qryDeleted')
					Create cursor qryDeleted (rec m)
					Append blank
				Endif
				Replace qryDeleted.rec with 'table = '+tctable+'recid = '+str (sqlresult.id) additive
			Endif
			Set delete on
			If lError = .t. and !deleted()
				If lnvalidateId > 0
&& есть соответсвующая запись в таблице
					Insert into buh50trans (idDest, idSource,tbl);
						values (lnvalidateId, evaluate ('sqlresult.id'),tctable)
					lnvalidateId = 0

				Else
					cString = create_insert_string()
					Do case
						Case cDest = 'VFP'
							On error lError = .f.
							&cString
							lnId = evaluate(tctable+'.id')
						Case cDest = 'MSSQL'
							= sqlexec (gnhandleDest,cString,'lastnum')
*!*							If used ('lastnum')
*!*								lError = .t.
*!*							Endif
*!*							If !used ('lastnum')
*!*								Return .f.
*!*	*!*								cString = 'select top 1 id from '+tcTable + ' order by id desc '
*!*	*!*	&&							lnId = 0
*!*	*!*								lError = sqlexec (gnhandleDest,cString,'lastnum')
*!*	*!*								lError = iif (lError < 1,.f.,.t.)
*!*							Endif
							lError = .f.
							lnTbl = aUsed(aCursors)
							If lnTbl > 0
								Create cursor qryAlias (alias c(20), nAliase int)
								Index on alias tag alias for left (upper(alias),7) == 'LASTNUM'
								Set order to alias
								Append from array aCursors
								If reccount ('qryAlias') > 0
									Scan
										lcvartype = alltrim(qryAlias.alias)+".id"
										If type (lcvartype) = 'I' or type (lcvartype) = 'N'
											lcAlias = alltrim(upper(qryAlias.alias))+".tbl"
											If type(lcAlias) = 'C' and upper(evaluate (lcAlias)) = tctable
												lnId =evaluate(alltrim(qryAlias.alias)+".id")
												Use in (alltrim(qryAlias.alias))
												lError = .t.
												Exit
											Endif
										Endif
									Endscan
								Endif
								If used ('qryAlias')
									Use in qryAlias
								Endif
							Endif

*!*							lnId = lastnum.id
*!*							Use in lastnum
					Endcase
					If lError = .f.
						 
						Exit
					Else
						If !empty (lnId)
							Insert into buh50trans (idDest, idSource,tbl);
								values (lnId, evaluate ('sqlresult.id'),tctable)
							lnId = 0
						Endif
					Endif
				Endif
			Endif
		Endscan
		If lError =.f.
			If cDest = 'VFP'
				Rollback
			Else
				Set step on
				=sqlexec(gnhandleDest,'rollback transaction')
			Endif

		Else
			If cDest = 'VFP'
				End transaction
			Else
				=sqlexec(gnhandleDest,'commit')
			Endif
			Select buh50trans
			Count for upper(alltrim(tbl)) = alltrim(upper(tctable)) to lnCount
			Replace transtest.KiriDest with lnCount in transtest
		Endif
	Endif
Endproc

Function create_insert_string
	Select sqlresult
	lnFields = afields (atbl)
	cInsert = 'insert into '+tctable +"("
	cData = ' values ('
	For i = 1 to lnFields
		If atbl(i,1) <> 'ID' and atbl(i,2) <> 'G'
			cInsert = cInsert + atbl(i,1)+;
				iif(i < lnFields,',','')
			lvalue = evaluate ('sqlresult.'+atbl(i,1))
			Do case
				Case atbl(i,2) = 'C'
					lvalue = iif (isnull(lvalue),'null',lvalue)
					cData = cData + "'"+ltrim(rtrim(lvalue))+"'"
				Case atbl(i,2) = 'D'
					Do case
						Case cDest = 'VFP'
							lvalue = iif (isnull(lvalue),'{}',lvalue)
							ldDate = lvalue
							lcdate = ' date('+str (year (ldDate),4)+','+str(month(ldDate),2)+','+str(day(ldDate),2)+') '
							cData = cData + lcdate
						Case cDest = 'MSSQL'
							lvalue = iif (isnull(lvalue),'null',"'"+dtoc(lvalue,1)+"'")
							cData = cData + lvalue
					Endcase
				Case atbl(i,2) = 'I'
					lvalue = iif (isnull(lvalue),0,lvalue)
					cData = cData + alltrim(str(lvalue))
				Case atbl(i,2) = 'N'
					lvalue = iif (isnull(lvalue),0,lvalue)
					cData = cData + alltrim(str(lvalue,atbl(i,3)+4,atbl(i,4)))
				Case atbl(i,2) = 'Y'
					lvalue = iif (isnull(lvalue),0,lvalue)
					cData = cData + alltrim(str(lvalue,8,4))
				Case atbl(i,2) = 'M'
					lvalue = iif (isnull(lvalue),'null',lvalue)
					cData = cData + "'"+lvalue+"'"
				Case atbl(i,2) = 'T'
			Endcase
			If i < lnFields
				cData = cData + ", "
			Else
				cInsert = cInsert + ')'
				cData = cData + ')'
			Endif
		Endif
	Endfor
	Return cInsert + space(1)+cData
Endproc


Function get_table_data
	If used ('sqlresult')
		Use in sqlresult
	Endif
	cString = 'select * from '+tctable
	Do case
		Case cSource = 'VFP'
			cString = cString + ' into cursor sqlresult_ '
			&cString
			If used ('sqlResult_')
				lError = .t.
			Else
				lError = .f.
			Endif
		Case cSource = 'MSSQL'
			=sqlexec (gnhandleSource,cString,'sqlresult_')
*!*				lError = iif(lError < 1,.f.,.t.)
			If used ('sqlResult_')
				lError = .t.
			Else
				lError = .f.
			Endif
	Endcase
	If lError = .f.
		Return lError
	Endif
	Release atbl
	Select sqlresult_
	lnFields = afields (atbl)
	Create cursor sqlresult from array atbl
	Select sqlresult
	Append from dbf ('sqlresult_')
	Use in sqlresult_
	Return lError
Endproc

Function get_tbls_list
	Do case
		Case gVersiaSource = 'VFP'
			Create cursor qryObjekt (name c(120))
			lnObjekt = ADBOBJECTS (adb,'TABLE')
			If lnObjekt > 0
				For i = 1 to lnObjekt
					Insert into qryObjekt (name) values (adb(i))
				Endfor
				Release adb
			Endif
		Case gVersiaSource = 'MSSQL'
			Create cursor qryObjekt (name c(120))
			cString = 'sp_help '
			= sqlexec (gnhandleSource, cString,'qryObjekt_')
*!*				lError = iif (lError < 1,.f.,.t.)
			If !used ('qryObjekt_')
				Return .f.
			Endif
			Select qryObjekt_
			Scan for object_type = 'user table'
				Insert into qryObjekt (name) values (qryObjekt_.name)
			Endscan
			Use in qryObjekt_
	Endcase
Endproc

Function validate_field
	Parameter tctable, tcField
	Local lError, lnreturn
	lnreturn = 0
	If used ('qryresult')
		Use in qryResult
	Endif
	lcKood = evaluate('sqlresult.'+tcField)
	lcKood = iif (vartype(lcKood) = 'C',lcKood,str(lcKood))
	cString = "select id from "+tctable+ " where "+tcField +" = '"+ltrim(rtrim(lcKood))+"'"
	Do case
		Case gVersiaDest = 'MSSQL'
			=sqlexec (gnhandleDest, cString,'qryresult')
&&			lError = iif (lError < 1,.f.,.t.)
		Case gVersiaDest = 'VFP'
			cString = cString + ' into cursor qryResult'
			&cString
	Endcase
	lError = iif (used('qryResult'),.t.,.f.)
	lnreturn = qryResult.id
	If lError = .f. or reccount ('qryResult') > 0
&& есть результирующие записи
*!*	возвращаем результат
	Endif
	Return lnreturn
Endproc


Function clean_ref_integrity
	Lparameter tctable
	Wait window [Kontrolin ref. integrity] nowait
	Do case
		Case tctable = 'KLASSIFLIB'
			If !used ('nomenklatuur')
				Use nomenklatuur in 0
			Endif
			If !used ('klassiflib')
				Use klassiflib in 0
			Endif
			If !used ('library')
				Use library in 0
			Endif
			If !used ('palk_lib')
				Use palk_lib in 0
			Endif
			If !used ('lausend')
				Use lausend in 0
			Endif
			Select nomenklatuur
			Set order to id
			Select library
			Set order to id
			Select palk_lib
			Set order to id
			Select lausend
			Set order to id
			Select klassiflib
			Scan
				if klassiflib.nomId > 0
					Select nomenklatuur
					Seek klassiflib.nomid
					If !found()
						replace nomId with 0 in klassiflib
					Endif
				endif
				if klassiflib.palklibId > 0
					Select palk_lib
					Seek klassiflib.palklibid
					If !found()
						replace palklibId with 0 in klassiflib
					Endif
				endif
				if klassiflib.libId > 0
					Select library
					Seek klassiflib.libid
					If !found()
						replace libId with 0 in klassiflib
					Endif
				endif
				if klassiflib.kood1 > 0
					Select library
					Seek klassiflib.kood1
					If !found()
						replace kood1 with 0 in klassiflib
					Endif
				endif
				if klassiflib.kood2 > 0
					Select library
					Seek klassiflib.kood2
					If !found()
						replace kood2 with 0 in klassiflib
					Endif
				endif
				if klassiflib.kood3 > 0
					Select library
					Seek klassiflib.kood3
					If !found()
						replace kood3 with 0 in klassiflib
					Endif
				endif
				if klassiflib.kood4 > 0
					Select library
					Seek klassiflib.kood4
					If !found()
						replace kood4 with 0 in klassiflib
					Endif
				endif
				if klassiflib.kood5 > 0
					Select library
					Seek klassiflib.kood5
					If !found()
						replace kood5 with 0 in klassiflib
					Endif
				endif
			Endscan
			Use in nomenklatuur
			Use in library
			Use in palk_lib
			Use in klassiflib
		Case tctable = 'LADU_MINKOGUS'
			If !used ('nomenklatuur')
				Use nomenklatuur in 0
			Endif
			If !used ('ladu_minkogus')
				Use ladu_minkogus in 0
			Endif
			Select nomenklatuur
			Set order to id
			Select ladu_minkogus
			Scan
				Select nomenklatuur
				Seek ladu_minkogus.parentid
				If !found()
					Select ladu_minkogus
					Delete next 1
				Endif
			Endscan
			Use in nomenklatuur
			Use in ladu_minkogus
		Case tctable = 'LADU_JAAK'
			If !used ('nomenklatuur')
				Use nomenklatuur in 0
			Endif
			If !used ('ladu_jaak')
				Use ladu_jaak in 0
			Endif
			If !used ('arv1')
				Use arv1 in 0
			Endif
			Select nomenklatuur
			Set order to id
			Select arv1
			Set order to id
			Select ladu_jaak
			Scan
				Select nomenklatuur
				Seek ladu_jaak.nomid
				If !found()
					Select ladu_jaak
					Delete next 1
				else
					select arv1
					seek ladu_jaak.dokItemId
					If !found()
						Select ladu_jaak
						Delete next 1
					Endif
				Endif
			Endscan
			Use in nomenklatuur
			Use in ladu_jaak
			Use in arv1
		Case tctable = 'LAUSDOK'
			If !used ('lausend')
				Use lausend in 0
			Endif
			If !used ('lausdok')
				Use lausdok in 0
			Endif
			If !used ('library')
				Use library in 0
			Endif
			Select library
			Set order to id
			Select lausend
			Set order to id
			Select lausdok
			Scan
				Select lausend
				Seek lausdok.lausendid
				If !found()
					Select lausdok
					Delete next 1
				else
					select library
					seek lausdok.dokid
					If !found()
						Select lausdok
						Delete next 1
					Endif
				Endif
			Endscan
			Use in library
			Use in lausend
			Use in lausdok
		Case tctable = 'JOURNALID'
			If !used ('journalid')
				Use journalid in 0
			Endif
			If !used ('journal')
				Use journal in 0
			Endif
			Select journal
			Set order to id
			Select journalId
			Scan
				Select journal
				Seek journalid.journalid
				If !found()
					Select journalid
					Delete next 1
				Endif
			Endscan
			Use in journal
			Use in journalid
			
		Case tctable = 'SUBKONTO'
			If !used ('asutus')
				Use asutus in 0
			Endif
			If !used ('library')
				Use library in 0
			Endif
			If !used ('subkonto')
				Use subkonto in 0
			Endif
			Select library
			Set order to id
			Select asutus
			Set order to id
			Select subkonto
			Scan
				Select asutus
				Seek subkonto.asutusid
				If !found()
					Select subkonto
					Delete next 1
				Else
					Select library
					Seek subkonto.KontoId
					If !found()
						Select subkonto
						Delete next 1
					Endif
				Endif
			Endscan
			Use in subkonto
			Use in asutus
			Use in library

		Case tctable = 'MK1'
			If !used ('mk1')
				Use mk1 in 0
			Endif
			If !used ('mk')
				Use mk in 0
			Endif
			Select mk
			Set order to id
			Select mk1
			Scan
				Select mk
				Seek mk1.Parentid
				If !found()
					Select mk1
					Delete next 1
				Endif
			Endscan
			Use in mk1
			Use in mk
		Case tctable = 'VORDER2'
			If !used ('vorder1')
				Use vorder1 in 0
			Endif
			If !used ('vorder2')
				Use vorder2 in 0
			Endif
			Select vorder1
			Set order to id
			Select vorder2
			Scan
				Select vorder1
				Seek vorder2.Parentid
				If !found()
					Select vorder2
					Delete next 1
				Endif
			Endscan
			Use in vorder1
			Use in vorder2
		Case tctable = 'SORDER2'
			If !used ('sorder1')
				Use sorder1 in 0
			Endif
			If !used ('sorder2')
				Use sorder2 in 0
			Endif
			Select sorder1
			Set order to id
			Select sorder2
			Scan
				Select sorder1
				Seek sorder2.Parentid
				If !found()
					Select sorder2
					Delete next 1
				Endif
			Endscan
			Use in sorder1
			Use in sorder2
		Case tctable = 'ARV1'
			If !used ('arv')
				Use arv in 0
			Endif
			If !used ('arv1')
				Use ARV1 in 0
			Endif
			Select arv
			Set order to id
			Select ARV1
			Scan
				Select arv
				Seek ARV1.Parentid
				If !found()
					Select ARV1
					Delete next 1
				Endif
			Endscan
			Use in ARV1
			Use in arv
		Case tctable = 'KONTOINF'
			If !used ('library')
				Use library in 0
			Endif
			If !used ('kontoinf')
				Use kontoinf in 0
			Endif
			Select library
			Set order to id
			Select kontoinf
			Scan
				Select library
				Seek kontoinf.Parentid
				If !found()
					Select kontoinf
					Delete next 1
				Endif
			Endscan
			Use in library
			Use in kontoinf
		Case tctable = 'JOURNAL1'
			If !used ('journal')
				Use journal in 0
			Endif
			If !used ('journal1')
				Use journal1 in 0
			Endif
			Select journal
			Set order to id
			Select journal1
			Scan
				Select journal
				Seek journal1.Parentid
				If !found()
					Select journal1
					Delete next 1
				Endif
			Endscan
			Use in journal
			Use in journal1
		Case tctable = 'LADU_GRUPP'
			If !used ('ladu_grupp')
				Use ladu_grupp in 0
			Endif
			If !used ('nomenklatuur')
				Use nomenklatuur in 0
			Endif
			Select nomenklatuur
			Set order to id
			Select ladu_grupp
			Scan
				Select nomenklatuur
				Seek ladu_grupp.nomid
				If !found()
					Select ladu_grupp
					Delete next 1
				Endif
			Endscan
			Use in nomenklatuur
			Use in ladu_grupp
		Case tctable = 'LADU_ULEHIND'
			If !used ('ladu_ulehind')
				Use ladu_ulehind in 0
			Endif
			If !used ('nomenklatuur')
				Use nomenklatuur in 0
			Endif
			Select nomenklatuur
			Set order to id
			Select ladu_ulehind
			Scan
				Select nomenklatuur
				Seek ladu_ulehind.Parentid
				If !found()
					Select ladu_ulehind
					Delete next 1
				Endif
			Endscan
			Use in nomenklatuur
			Use in ladu_ulehind
		Case tctable = 'LEPING2'
			If !used ('leping2')
				Use leping2 in 0
			Endif
			If !used ('nomenklatuur')
				Use nomenklatuur in 0
			Endif
			Select nomenklatuur
			Set order to id
			Select leping2
			Scan
				Select nomenklatuur
				Seek leping2.nomid
				If !found()
					Select leping2
					Delete next 1
				Endif
			Endscan
			Use in nomenklatuur
			Use in leping2
		Case tctable = 'LEPING3'
			If !used ('leping2')
				Use leping2 in 0
			Endif
			If !used ('leping3')
				Use leping3 in 0
			Endif
			Select leping2
			Set order to id
			Select leping3
			Scan
				Select leping2
				Seek leping2.Parentid
				If !found()
					Select leping3
					Delete next 1
				Endif
			Endscan
			Use in leping3
			Use in leping2
		Case tctable = 'GRUPPOMANDUS'
			If !used ('gruppomandus')
				Use gruppomandus in 0
			Endif
			If !used ('library')
				Use library in 0
			Endif
			Select library
			Set order to id
			Select gruppomandus
			Scan
				Select library
				Seek gruppomandus.Parentid
				If !found()
					Select gruppomandus
					Delete next 1
				Endif
			Endscan
			Use in library
			If !used ('lausend')
				Use in lausend
			Endif
			Select lausend
			Set order to id
			Select gruppomandus
			Scan
				Select lausend
				Seek gruppomandus.lausendId
				If !found()
					Select gruppomandus
					Delete next 1
				Endif
			Endscan
			Use in lausend
			Use in gruppomandus
	Endcase
	Return

Function check_algsaldo
Set step on
On error do err
cSource = 'VFP'
gRekvSource = 1
gUserSource = 1
gVersiaSource = 'VFP'
&&cDataSource = 'c:\files\buh52\dbase\buhdata5.dbc'
cDataSource = 'c:\temp\dbrugodiv\buhdata5.dbc'
gnhandleSource = 1
if !dbused ('buhdata5')
	Open data (cDataSource)
endif
cDest = 'MSSQL'
gRekvDest = 27
gUserDest = 66
gVersiaDest = 'MSSQL'
cDataDest = 'NARVA'
gnhandleDest = sqlconnect (cDataDest)
If gnhandleDest < 1
	Messagebox('Viga: uhendus')
	Return .f.
Endif
cstring = 'select * from subkonto where rekvid = ' + str (grekvdest)
lError = sqlexec (gnhandledest,cstring,'qrysubkonto')
if !used ('subkonto')
	use subkonto in 0
endif
if !used ('buh50trans')
	use buh50trans in 0
endif
select subkonto
scan
	wait window str (recno('subkonto'))+'/'+str (reccount ('subkonto')) nowait
	select buh50trans
	locate for tbl = 'SUBKONTO' and;
		idsource = subkonto.id
	
	select qrysubkonto
	locate for id = buh50trans.iddest
	if found ()
	if qrysubkonto.algsaldo <> subkonto.algsaldo
		cstring = 'update subkonto set algsaldo = '+str (subkonto.algsaldo,14,2)+' where id = '+str (qrysubkonto.id)
		lError = sqlexec (gnhandledest,cstring) 
	endif
		if lError < 1
			set step on
		endif
	endif
endscan
=sqldisconnect (gnhandledest)