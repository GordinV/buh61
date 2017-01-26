Set step on
On error do err
cSource = 'VFP'
gRekvSource = 1
gUserSource = 1
gVersiaSource = 'VFP'
&&cDataSource = 'c:\files\buh52\dbase\buhdata5.dbc'
cDataSource = 'c:\temp\dbpaju\assetdata.dbc'
gnhandleSource = 1
Open data (cDataSource)
lerror = korrasta()
If lerror = .f.
	lnAnswer = messagebox ('Oli vigad, kas jatka?',1+16+0,'Kontrol')
	If lnAnswer <> 1
		Return .f.
	Endif
Endif
cDest = 'MSSQL'
gRekvDest = 18
gUserDest = 51
gVersiaDest = 'MSSQL'
cDataDest = 'NARVA'
gnhandleDest = sqlconnect (cDataDest,'vladislav','654')
If gnhandleDest < 1
	Messagebox('Viga: uhendus')
	Return .f.
Endif
&&lnError=sqlexec (gnhandleDest,'BEGIN TRANSACTION')
If !file ('PVtrans.dbf')
	Create table pvtrans free (idDest int, idSource int, tbl c(60))
Endif
Create cursor transtest (tblNimi c(60), KiriSource int, KiriDest int)
If !used ('pvtrans')
	Use pvtrans in 0
Endif

lnvalidateId = 0
lerror = .t.
If lerror = .t.
&&	=clean_ref_integrity('ASS_TYPES')
	lerror = transmit_table('ASS_TYPES')
Endif
If lerror = .t.
	lerror = transmit_table('ASS_OPER')
Endif
If lerror = .t.
	lerror = transmit_table('ASSET')
Endif
If lerror = .t.
	=clean_ref_integrity('ASS_BOOK')
	lerror = transmit_table('ASS_BOOK')
Endif
If lerror = .t.
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

Function transmit_table
	Parameter tctable
	Local lerror, lnGruppId
	lResult = get_table_data ()
	Insert into transtest (tblNimi, KiriSource, KiriDest) values (tctable,reccount ('sqlResult'),0)
	lerror = .t.
*!*		If cDest = 'VFP'
*!*			Begin transaction
*!*		Else
*!*			=sqlexec(gnhandleDest,'begin transaction')
*!*		Endif
	lnId = 0
	If lResult = .t. and used ('sqlresult')
		Select sqlresult
		Scan
			Wait window tctable + ':'+str(recno('sqlResult'))+'/'+str(reccount ('sqlresult')) nowait
			Do case
				Case alltrim(upper(tctable)) = 'ASS_TYPES'
&& группа ОС
					cString = " insert into library (rekvid, kood, nimetus, library) values ("+;
						str (gRekvDest)+",'"+left(sqlresult.types,20)+"','"+sqlresult.types+"','PVGRUPP')"

					Do case
						Case cDest = 'VFP'
							On error lerror = .f.
							&cString
							lnId = evaluate(tctable+'.id')
						Case cDest = 'MSSQL'
							= sqlexec (gnhandleDest,cString,'lastnum')
							lnId = lastnum.id
					Endcase
					SELECT LASTNUM
					GO TOP
					=ins_sourcetbl(lnId)
				Case alltrim(upper(tctable)) = 'ASS_OPER'

&& Операции с ОС
					Do case
						Case sqlresult.code = 'SISSESTAMINE'
							lcDok = 'PAIGUTUS'
						Case sqlresult.code = 'KULUMI ARVESTAMINE'
							lcDok = 'KULUM'
						Case left(sqlresult.code,4) = 'LIKV'
							lcDok = 'MAHAKANDMINE'
						Case left(sqlresult.code,9) = 'UMBERHIND'
							lcDok = 'PARANDUS'
					Endcase
					lcKood = left(ltrim(rtrim(sqlresult.code)) + '-'+ltrim(rtrim(sqlresult.objekt)),20)
					cString = " insert into nomenklatuur (rekvid, kood, nimetus, dok) values ("+;
						str (gRekvDest)+",'"+left(lcKood,20)+"','"+sqlresult.description+"','"+lcDok+"')"

					Do case
						Case cDest = 'VFP'
							On error lerror = .f.
							&cString
							lnId = evaluate(tctable+'.id')
						Case cDest = 'MSSQL'
							= sqlexec (gnhandleDest,cString,'lastnum')
							lnId = lastnum.id
					Endcase
					SELECT LASTNUM
					GO TOP
					=ins_sourcetbl(lnId)

				Case alltrim(upper(tctable)) = 'ASSET'
					Select pvtrans
					If !empty (sqlresult.type)
						If !used ('ass_types')
							Use ass_types in 0
						Endif
						Select ass_types
						Locate for alltrim(upper(types)) = alltrim(upper(sqlresult.type))
						Select pvtrans
						Locate for tbl = 'ASS_TYPES' AND idSource = ass_types.num
						lnGruppId = pvtrans.idDest
						If !used ('cl')
							Use cl in 0
						Endif
						If !empty (sqlresult.coode)
							Select cl
							Locate for coode = sqlresult.coode
							If !used ('qryCl')
								=sqlexec (gnhandleDest,'select * from asutus','qryCl')
							Endif
							Select qryCl
							Locate for alltrim(upper(nimetus)) = alltrim(upper(cl.client))
							If !found ()
								lnVastIsikId=getvastisikud(cl.num)
							else
								lnVastIsikId=qrycl.id
							endif	
						Else
							lnVastIsikId = 0
						Endif

						cString = " insert into library (rekvid, kood, nimetus, library, muud) values ("+;
							str (gRekvDest)+",'"+left(sqlresult.code,20)+"','"+sqlresult.description+"','POHIVARA','"+;
							ltrim(rtrim(sqlresult.location))+"')"
						lerror =sqlexec (gnhandleDest,cString,'QRYlastnum')
						if !used ('qrylastnum') or empty (qrylastnum.id)
							set step on
						endif
						SELECT QRYLASTNUM
						GO TOP
						lnId = QRYlastnum.id
						=ins_sourcetbl(lnId)
						cString = " insert into pv_kaart (parentid,vastisikId, soetmaks, soetkpv, kulum, algkulum, gruppId, konto, tunnus) values ("+;
							str (QRYlastnum.id)+","+str (lnVastIsikId)+","+str (sqlresult.alghind,14,2)+",'"+;
							dtoc(sqlresult.datexpl,1)+"',"+str (sqlresult.amort)+",0,"+str (lnGruppId)+",'"+;
							ltrim(rtrim(sqlresult.konto))+"',1)"
						=sqlexec (gnhandleDest,cString,'lastnum')
						SELECT LASTNUM
						GO TOP
						lnId = lastnum.id
						If sqlresult.tunnus = 9
&& mahakantud
							If !used ('ass_book')
								Use ass_book in 0
							Endif
							Select ass_book
							Locate for number = sqlresult.num and;
								'LIKV' $ ass_book.vid_oper
							If found ()

								cString = " UPDATE pv_kaart set tunnus = 0,"+;
									"mahakantud  = '"+dtoc(ass_book.dat,1)+"'"+ ;
									" where id = "+str (lnId)
								=sqlexec (gnhandleDest,cString)

							Else
								Set step on
							Endif
						Endif
					Endif
				Case alltrim(upper(tctable)) = 'ASS_BOOK'
					Select pvtrans
					Locate for tbl = 'ASSET' and idSource = sqlresult.number
					lnParentId = pvtrans.idDest
					Select pvtrans
					Locate for tbl = 'ASS_OPER' and idSource = sqlresult.operation
					lnNomId = pvtrans.idDest
					Do case
						Case left (sqlresult.vid_oper,4) = 'SISS'
							lcLiik = '1'
						Case left (sqlresult.vid_oper,5) = 'KULUM'
							lcLiik = '2'
						Case left (sqlresult.vid_oper,5) = 'UMBER'
							lcLiik = '3'
						Case left (sqlresult.vid_oper,4) = 'LIKV' or sqlresult.vid_oper = 'INVENTAAR_ULEKANDMINE'
							lcLiik = '4'
					Endcase
					cString = "insert into pv_oper (parentid, nomid, liik, summa, kpv, journal1Id, JOURNALID, lausendid, doklausid, muud) values ("+;
						Str (lnParentId)+","+str (lnNomId)+","+lcLiik+","+STR (sqlresult.summa,14,2)+",'"+;
						dtoc(sqlresult.dat,1)+"',0,0,0,0,space(1))"
					= sqlexec (gnhandleDest,cString,'lastnum')
					SELECT LASTNUM
					GO TOP
					lnId = lastnum.id
					=ins_sourcetbl(lnId)
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
			If lerror = .t. and !deleted()
			Endif
		Endscan
		If lerror =.f.
*!*				If cDest = 'VFP'
*!*					Rollback
*!*				Else
*!*					Set step on
*!*					=sqlexec(gnhandleDest,'rollback transaction')
*!*				Endif

		Else
*!*				If cDest = 'VFP'
*!*					End transaction
*!*				Else
*!*					=sqlexec(gnhandleDest,'commit')
*!*				Endif
			Select pvtrans
			Count for upper(alltrim(tbl)) = alltrim(upper(tctable)) to lnCount
			Replace transtest.KiriDest with lnCount in transtest
		Endif
	Endif
Endproc

Function ins_sourcetbl
	Parameter tnId, tnValidateId
	If empty (tnValidateId)
		tnValidateId = 0
	Endif
	If empty (tnId)
		tnId = 0
		Return .f.
	Endif
	If tnValidateId > 0
&& есть соответсвующая запись в таблице
		Insert into pvtrans (idDest, idSource,tbl);
			values (tnValidateId, evaluate ('sqlresult.num'),tctable)
		tnValidateId = 0

	Else
		If !empty (tnId)
			Insert into pvtrans (idDest, idSource,tbl);
				values (tnId, evaluate ('sqlresult.num'),tctable)
			lnId = 0
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
				lerror = .t.
			Else
				lerror = .f.
			Endif
		Case cSource = 'MSSQL'
			=sqlexec (gnhandleSource,cString,'sqlresult_')
*!*				lError = iif(lError < 1,.f.,.t.)
			If used ('sqlResult_')
				lerror = .t.
			Else
				lerror = .f.
			Endif
	Endcase
	If lerror = .f.
		Return lerror
	Endif
	Release atbl
	Select sqlresult_
	lnFields = afields (atbl)
	Create cursor sqlresult from array atbl
	Select sqlresult
	Append from dbf ('sqlresult_')
	Use in sqlresult_
	Return lerror
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
	Local lerror, lnreturn
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
	lerror = iif (used('qryResult'),.t.,.f.)
	lnreturn = qryResult.id
	If lerror = .f. or reccount ('qryResult') > 0
&& есть результирующие записи
*!*	возвращаем результат
	Endif
	Return lnreturn
Endproc


Function clean_ref_integrity
	Lparameter tctable
	Wait window [Kontrolin ref. integrity] nowait
	Do case
		Case tctable = 'ASS_BOOK'
			If !used ('ass_book')
				Use ass_book in 0
			Endif
			If !used ('asset')
				Use asset in 0
			Endif
			If !used ('ass_oper')
				Use ass_oper in 0
			Endif
			Select asset
			Set order to num
			Select ass_oper
			Set order to num
			Select ass_book
			Scan
				Wait window [Kontroling:]+tctable+str (recno('ass_book'))+'/'+str (reccount ('ass_book')) nowait
				Select asset
				Seek ass_book.number
				If !found()
					Select ass_book
					Delete next 1
				Else
					Select ass_oper
					Seek ass_book.operation
					If !found()
						Select ass_book
						Delete next 1

					Endif
				Endif
			Endscan
			Use in ass_book
			Use in asset
			Use in ass_oper
	Endcase
	Return



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
		Wait window str (recno('qryIdx_'))+'/'+str(reccount('qryIdx_')) nowait
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



Function korrasta
	lnError = ADBOBJECTS(atbl, 'TABLE')
	If lnError<1
		Return .F.
	Endif
	For i = 1 TO ALEN(atbl, 1)
		lcTable = atbl(i)
		Wait WINDOW NOWAIT 'kontrolin :'+lcTable
		If USED(lcTable)
			Use IN (lcTable)
		Endif
		Use EXCLUSIVE (lcTable) ALIAS tbLkorrasta IN 0
		If USED('tblKorrasta')
			Select tbLkorrasta
			Reindex
			Pack
			If lcTable<>'DBASE' .AND. lcTable<>'CURKUUD'
				Goto BOTTOM
				lnId = tbLkorrasta.num
				If  .NOT. USED('dbase')
					Use dbase IN 0
				Endif
				Select dbase
				Set ORDER TO alias
				Seek lcTable
				If FOUND()
					Replace lastnum WITH lnId IN dbase
				Endif
				Use IN dbase
			Endif
			Use IN tbLkorrasta
		Else
			cmEssage = 'Ei saa korrastada '+lcTable
			Messagebox(cmEssage, 'Kontrol')
		Endif
	Endfor
	Wait WINDOW NOWAIT ''

	Return

Function getvastisikud
	parameter clnum
	local lnreturn
	lnreturn = 0
	Select * from cl where coode in (select coode from asset) into cursor qryclnew
	Select qryclnew
	Scan
		Select qryCl
		locate for alltrim(upper(nimetus)) = alltrim(upper(qryclnew.client)) 
		if !found ()
			lcstring = " insert into asutus (rekvid, regkood, nimetus) values ("+;
				str (grekvdest)+",'"+qryclnew.regnumber+"','"+qryclnew.client+"')"
			lerror = sqlexec (gnhandledest,lcstring,'qryid')
		endif
		if qryclnew.num = clnum
			lnreturn = qryid.id
		endif
	Endscan
	lerror = sqlexec (gnhandledest,"select * from asutus",'qryCl')
	return lnReturn
endfunc 