Set Step On
*!*	On Error Do err
cSource = 'VFP'
gRekvSource = 1
gUserSource = 1
gVersiaSource = 'VFP'

*!*	cDataSource = 'c:\temp\dblv\assetdata.dbc'
*!*	*!*	gnhandleSource = 1
*!*	Open Data (cDataSource)
*!*	lerror = korrasta()
*!*	If lerror = .F.
*!*		lnAnswer = Messagebox ('Oli vigad, kas jatka?',1+16+0,'Kontrol')
*!*		If lnAnswer <> 1
*!*			Return .F.
*!*		Endif
*!*	Endif
cDest = 'MSSQL'
gRekvDest = 18
gUserDest = 51
gVersiaDest = 'MSSQL'
cDataDest = 'NARVA'
gnhandleDest = SQLConnect (cDataDest,'vladislav','490710')
If gnhandleDest < 1
	Messagebox('Viga: uhendus')
	Return .F.
Endif
lnError=sqlexec (gnhandleDest,'BEGIN TRANSACTION')

lnvalidateId = 0
lerror = .T.

cstring = 'SELECT ID, KOOD, soetmaks FROM CURPOHIVARA WHERE REKVID = 3'
lerror = sqlexec(gnhandleDest, cstring,'curPohivara')
If lerror < 1
	Messagebox('Viga')
	Set Step On
	Return .F.
ENDIF
IF !USED('ass_amort')
	USE ass_amort IN 0 excl
endif
Select ass_amort
Index On  dat Tag kpv
Set Order To kpv
lerror = 1
Select curPohivara
SCAN
	WAIT WINDOW curpohivara.kood+STR(RECNO('curpohivara'))+'-'+STR(RECCOUNT('curpohivara')) nowait
	Select ass_amort
	lnHind = 0
	Scan For Alltrim(Code)= Alltrim(curPohivara.kood) And ass_amort.dat >= Date(2003,1,1)
		lnParentId = curPohivara.Id
		lnNomid = 208
		lcLiik = '2'
		lnSumma = ass_amort.Summa
		ldDat = ass_amort.dat
		lnHind = ass_amort.hind
		cstring = "insert into pv_oper (parentid, nomid, liik, summa, kpv, journal1Id, JOURNALID, lausendid, doklausid, muud) values ("+;
			Str (lnParentId)+","+Str (lnNomid)+","+lcLiik+","+Str (lnSumma,14,2)+",'"+;
			dtoc(ldDat,1)+"',0,0,0,0,space(1))"
		lerror = sqlexec (gnhandleDest,cstring)
		If lerror < 1
			Messagebox('Viga')
			Set Step On
			Exit
		Endif
	ENDSCAN
*!*		IF lnHind = 0
*!*			lnHind = curPohivara.soetmaks
*!*		endif
		Select ass_amort
		locate For Alltrim(Code)= Alltrim(curPohivara.kood) And ;
		MONTH(ass_amort.dat) = 12 AND YEAR(ass_amort.dat)=2002
		IF FOUND()
			lnHind = ass_amort.hind
		ELSE
			lnHind = 0
		endif
		cstring = "SELECT sum (summa) as summa from pv_oper where liik = 2 and parentId = "+Str(curPohivara.Id)
		lerror = sqlexec (gnhandleDest,cstring,'qryJaak')
		If lerror < 1
			Messagebox('Viga')
			Set Step On
		ENDIF
		IF !isnull(qryJaak.summa) 
			lnJaak = curPohivara.soetmaks - qryJaak.Summa
		ELSE
			lnJaak = curPohivara.soetmaks
		endif
		If lnJaak <> lnHind
			lnSumma = lnJaak - lnHind
			If lnSumma < 0
				lnSumma = 0
			Endif
			lnParentId = curPohivara.Id
			lnNomid = 208
			lcLiik = '2'
			ldDat = Date(2002,12,31)

			cstring = "insert into pv_oper (parentid, nomid, liik, summa, kpv, journal1Id, JOURNALID, lausendid, doklausid, muud) values ("+;
				Str (lnParentId)+","+Str (lnNomid)+","+lcLiik+","+Str (lnSumma,14,2)+",'"+;
				dtoc(ldDat,1)+"',0,0,0,0,space(1))"
			lerror = sqlexec (gnhandleDest,cstring)
			If lerror < 1
				Messagebox('Viga')
				Set Step On
			Endif

	Endif
Endscan
If lerror < 1
	cstring = 'ROLLBACK'
Else
	cstring = 'COMMIT'
Endif
lerror = sqlexec(gnhandleDest,cstring)




*!*	If lerror = .T.
*!*	&&	=clean_ref_integrity('ASS_TYPES')
*!*		lerror = transmit_table('ASS_TYPES')
*!*	Endif
*!*	If lerror = .T.
*!*		lerror = transmit_table('ASS_OPER')
*!*	Endif
*!*	If lerror = .T.
*!*		lerror = transmit_table('ASSET')
*!*	Endif
*!*	If lerror = .T.
*!*		=clean_ref_integrity('ASS_BOOK')
*!*		lerror = transmit_table('ASS_BOOK')
*!*	Endif
If lerror = .T.
	=sqlexec (gnhandleDest,'COMMIT')
	Messagebox ('Ok','Kontrol')
Else
	=sqlexec (gnhandleDest,'ROLLBACK')
	Messagebox ('Viga','Kontrol')
Endif

On Error
Select transtest
Browse
If Used ('qryDeleted')
	Copy Memo qryDeleted.rec To c:\temp\Report.prn
	Messagebox('Отчет скопирован в файл c:\temp\report.prn')
	Use In qryDeleted
Endif

Function transmit_table
Parameter tctable
Local lerror, lnGruppId
lResult = get_table_data ()
Insert Into transtest (tblNimi, KiriSource, KiriDest) Values (tctable,Reccount ('sqlResult'),0)
lerror = .T.
*!*		If cDest = 'VFP'
*!*			Begin transaction
*!*		Else
*!*			=sqlexec(gnhandleDest,'begin transaction')
*!*		Endif
lnId = 0
If lResult = .T. And Used ('sqlresult')
	Select sqlresult
	Scan
		Wait Window tctable + ':'+Str(Recno('sqlResult'))+'/'+Str(Reccount ('sqlresult')) Nowait
		Do Case
		Case Alltrim(Upper(tctable)) = 'ASS_TYPES'
&& группа ОС
			cstring = " insert into library (rekvid, kood, nimetus, library) values ("+;
				str (gRekvDest)+",'"+Left(sqlresult.types,20)+"','"+sqlresult.types+"','PVGRUPP')"

			Do Case
			Case cDest = 'VFP'
				On Error lerror = .F.
				&cstring
				lnId = Evaluate(tctable+'.id')
			Case cDest = 'MSSQL'
				= sqlexec (gnhandleDest,cstring,'lastnum')
				lnId = lastnum.Id
			Endcase
			Select lastnum
			Go Top
			=ins_sourcetbl(lnId)
		Case Alltrim(Upper(tctable)) = 'ASS_OPER'

&& Операции с ОС
			Do Case
			Case sqlresult.Code = 'SISSESTAMINE'
				lcDok = 'PAIGUTUS'
			Case sqlresult.Code = 'KULUMI ARVESTAMINE'
				lcDok = 'KULUM'
			Case Left(sqlresult.Code,4) = 'LIKV'
				lcDok = 'MAHAKANDMINE'
			Case Left(sqlresult.Code,9) = 'UMBERHIND'
				lcDok = 'PARANDUS'
			Endcase
			lcKood = Left(Ltrim(Rtrim(sqlresult.Code)) + '-'+Ltrim(Rtrim(sqlresult.objekt)),20)
			cstring = " insert into nomenklatuur (rekvid, kood, nimetus, dok) values ("+;
				str (gRekvDest)+",'"+Left(lcKood,20)+"','"+sqlresult.Description+"','"+lcDok+"')"

			Do Case
			Case cDest = 'VFP'
				On Error lerror = .F.
				&cstring
				lnId = Evaluate(tctable+'.id')
			Case cDest = 'MSSQL'
				= sqlexec (gnhandleDest,cstring,'lastnum')
				lnId = lastnum.Id
			Endcase
			Select lastnum
			Go Top
			=ins_sourcetbl(lnId)

		Case Alltrim(Upper(tctable)) = 'ASSET'
			Select pvtrans
			If !Empty (sqlresult.Type)
				If !Used ('ass_types')
					Use ass_types In 0
				Endif
				Select ass_types
				Locate For Alltrim(Upper(types)) = Alltrim(Upper(sqlresult.Type))
				Select pvtrans
				Locate For tbl = 'ASS_TYPES' And idSource = ass_types.num
				lnGruppId = pvtrans.idDest
				If !Used ('cl')
					Use cl In 0
				Endif
				If !Empty (sqlresult.coode)
					Select cl
					Locate For coode = sqlresult.coode
					If !Used ('qryCl')
						=sqlexec (gnhandleDest,'select * from asutus','qryCl')
					Endif
					Select qryCl
					Locate For Alltrim(Upper(nimetus)) = Alltrim(Upper(cl.client))
					If !Found ()
						lnVastIsikId=getvastisikud(cl.num)
					Else
						lnVastIsikId=qryCl.Id
					Endif
				Else
					lnVastIsikId = 0
				Endif

				cstring = " insert into library (rekvid, kood, nimetus, library, muud) values ("+;
					str (gRekvDest)+",'"+Left(sqlresult.Code,20)+"','"+sqlresult.Description+"','POHIVARA','"+;
					ltrim(Rtrim(sqlresult.location))+"')"
				lerror =sqlexec (gnhandleDest,cstring,'QRYlastnum')
				If !Used ('qrylastnum') Or Empty (qrylastnum.Id)
					Set Step On
				Endif
				Select qrylastnum
				Go Top
				lnId = qrylastnum.Id
				=ins_sourcetbl(lnId)
				cstring = " insert into pv_kaart (parentid,vastisikId, soetmaks, soetkpv, kulum, algkulum, gruppId, konto, tunnus) values ("+;
					str (qrylastnum.Id)+","+Str (lnVastIsikId)+","+Str (sqlresult.alghind,14,2)+",'"+;
					dtoc(sqlresult.datexpl,1)+"',"+Str (sqlresult.amort)+",0,"+Str (lnGruppId)+",'"+;
					ltrim(Rtrim(sqlresult.konto))+"',1)"
				=sqlexec (gnhandleDest,cstring,'lastnum')
				Select lastnum
				Go Top
				lnId = lastnum.Id
				If sqlresult.tunnus = 9
&& mahakantud
					If !Used ('ass_book')
						Use ass_book In 0
					Endif
					Select ass_book
					Locate For Number = sqlresult.num And;
						'LIKV' $ ass_book.vid_oper
					If Found ()

						cstring = " UPDATE pv_kaart set tunnus = 0,"+;
							"mahakantud  = '"+Dtoc(ass_book.dat,1)+"'"+ ;
							" where id = "+Str (lnId)
						=sqlexec (gnhandleDest,cstring)

					Else
						Set Step On
					Endif
				Endif
			Endif
		Case Alltrim(Upper(tctable)) = 'ASS_BOOK'
			Select pvtrans
			Locate For tbl = 'ASSET' And idSource = sqlresult.Number
			lnParentId = pvtrans.idDest
			Select pvtrans
			Locate For tbl = 'ASS_OPER' And idSource = sqlresult.operation
			lnNomid = pvtrans.idDest
			Do Case
			Case Left (sqlresult.vid_oper,4) = 'SISS'
				lcLiik = '1'
			Case Left (sqlresult.vid_oper,5) = 'KULUM'
				lcLiik = '2'
			Case Left (sqlresult.vid_oper,5) = 'UMBER'
				lcLiik = '3'
			Case Left (sqlresult.vid_oper,4) = 'LIKV' Or sqlresult.vid_oper = 'INVENTAAR_ULEKANDMINE'
				lcLiik = '4'
			Endcase
			If lcLiik <> 2
				cstring = "insert into pv_oper (parentid, nomid, liik, summa, kpv, journal1Id, JOURNALID, lausendid, doklausid, muud) values ("+;
					Str (lnParentId)+","+Str (lnNomid)+","+lcLiik+","+Str (sqlresult.Summa,14,2)+",'"+;
					dtoc(sqlresult.dat,1)+"',0,0,0,0,space(1))"
				= sqlexec (gnhandleDest,cstring,'lastnum')
				Select lastnum
				Go Top
				lnId = lastnum.Id
				=ins_sourcetbl(lnId)
			Endif
		Endcase
		Select sqlresult
		Set Delete Off
		If Deleted()
			If !Used ('qryDeleted')
				Create Cursor qryDeleted (rec m)
				Append Blank
			Endif
			Replace qryDeleted.rec With 'table = '+tctable+'recid = '+Str (sqlresult.Id) Additive
		Endif
		Set Delete On
		If lerror = .T. And !Deleted()
		Endif
	Endscan
	If lerror =.F.
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
		Count For Upper(Alltrim(tbl)) = Alltrim(Upper(tctable)) To lnCount
		Replace transtest.KiriDest With lnCount In transtest
	Endif
Endif
Endproc

Function ins_sourcetbl
Parameter tnId, tnValidateId
If Empty (tnValidateId)
	tnValidateId = 0
Endif
If Empty (tnId)
	tnId = 0
	Return .F.
Endif
If tnValidateId > 0
&& есть соответсвующая запись в таблице
	Insert Into pvtrans (idDest, idSource,tbl);
		values (tnValidateId, Evaluate ('sqlresult.num'),tctable)
	tnValidateId = 0

Else
	If !Empty (tnId)
		Insert Into pvtrans (idDest, idSource,tbl);
			values (tnId, Evaluate ('sqlresult.num'),tctable)
		lnId = 0
	Endif
Endif
Endproc


Function create_insert_string
Select sqlresult
lnFields = Afields (atbl)
cInsert = 'insert into '+tctable +"("
cData = ' values ('
For i = 1 To lnFields
	If atbl(i,1) <> 'ID' And atbl(i,2) <> 'G'
		cInsert = cInsert + atbl(i,1)+;
			iif(i < lnFields,',','')
		lvalue = Evaluate ('sqlresult.'+atbl(i,1))
		Do Case
		Case atbl(i,2) = 'C'
			lvalue = Iif (Isnull(lvalue),'null',lvalue)
			cData = cData + "'"+Ltrim(Rtrim(lvalue))+"'"
		Case atbl(i,2) = 'D'
			Do Case
			Case cDest = 'VFP'
				lvalue = Iif (Isnull(lvalue),'{}',lvalue)
				ldDate = lvalue
				lcdate = ' date('+Str (Year (ldDate),4)+','+Str(Month(ldDate),2)+','+Str(Day(ldDate),2)+') '
				cData = cData + lcdate
			Case cDest = 'MSSQL'
				lvalue = Iif (Isnull(lvalue),'null',"'"+Dtoc(lvalue,1)+"'")
				cData = cData + lvalue
			Endcase
		Case atbl(i,2) = 'I'
			lvalue = Iif (Isnull(lvalue),0,lvalue)
			cData = cData + Alltrim(Str(lvalue))
		Case atbl(i,2) = 'N'
			lvalue = Iif (Isnull(lvalue),0,lvalue)
			cData = cData + Alltrim(Str(lvalue,atbl(i,3)+4,atbl(i,4)))
		Case atbl(i,2) = 'Y'
			lvalue = Iif (Isnull(lvalue),0,lvalue)
			cData = cData + Alltrim(Str(lvalue,8,4))
		Case atbl(i,2) = 'M'
			lvalue = Iif (Isnull(lvalue),'null',lvalue)
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
Return cInsert + Space(1)+cData
Endproc


Function get_table_data
If Used ('sqlresult')
	Use In sqlresult
Endif
cstring = 'select * from '+tctable
Do Case
Case cSource = 'VFP'
	cstring = cstring + ' into cursor sqlresult_ '
	&cstring
	If Used ('sqlResult_')
		lerror = .T.
	Else
		lerror = .F.
	Endif
Case cSource = 'MSSQL'
	=sqlexec (gnhandleSource,cstring,'sqlresult_')
*!*				lError = iif(lError < 1,.f.,.t.)
	If Used ('sqlResult_')
		lerror = .T.
	Else
		lerror = .F.
	Endif
Endcase
If lerror = .F.
	Return lerror
Endif
Release atbl
Select sqlresult_
lnFields = Afields (atbl)
Create Cursor sqlresult From Array atbl
Select sqlresult
Append From Dbf ('sqlresult_')
Use In sqlresult_
Return lerror
Endproc

Function get_tbls_list
Do Case
Case gVersiaSource = 'VFP'
	Create Cursor qryObjekt (Name c(120))
	lnObjekt = Adbobjects (adb,'TABLE')
	If lnObjekt > 0
		For i = 1 To lnObjekt
			Insert Into qryObjekt (Name) Values (adb(i))
		Endfor
		Release adb
	Endif
Case gVersiaSource = 'MSSQL'
	Create Cursor qryObjekt (Name c(120))
	cstring = 'sp_help '
	= sqlexec (gnhandleSource, cstring,'qryObjekt_')
*!*				lError = iif (lError < 1,.f.,.t.)
	If !Used ('qryObjekt_')
		Return .F.
	Endif
	Select qryObjekt_
	Scan For object_type = 'user table'
		Insert Into qryObjekt (Name) Values (qryObjekt_.Name)
	Endscan
	Use In qryObjekt_
Endcase
Endproc

Function validate_field
Parameter tctable, tcField
Local lerror, lnreturn
lnreturn = 0
If Used ('qryresult')
	Use In qryResult
Endif
lcKood = Evaluate('sqlresult.'+tcField)
lcKood = Iif (Vartype(lcKood) = 'C',lcKood,Str(lcKood))
cstring = "select id from "+tctable+ " where "+tcField +" = '"+Ltrim(Rtrim(lcKood))+"'"
Do Case
Case gVersiaDest = 'MSSQL'
	=sqlexec (gnhandleDest, cstring,'qryresult')
&&			lError = iif (lError < 1,.f.,.t.)
Case gVersiaDest = 'VFP'
	cstring = cstring + ' into cursor qryResult'
	&cstring
Endcase
lerror = Iif (Used('qryResult'),.T.,.F.)
lnreturn = qryResult.Id
If lerror = .F. Or Reccount ('qryResult') > 0
&& есть результирующие записи
*!*	возвращаем результат
Endif
Return lnreturn
Endproc


Function clean_ref_integrity
Lparameter tctable
Wait Window [Kontrolin ref. integrity] Nowait
Do Case
Case tctable = 'ASS_BOOK'
	If !Used ('ass_book')
		Use ass_book In 0
	Endif
	If !Used ('asset')
		Use asset In 0
	Endif
	If !Used ('ass_oper')
		Use ass_oper In 0
	Endif
	Select asset
	Set Order To num
	Select ass_oper
	Set Order To num
	Select ass_book
	Scan
		Wait Window [Kontroling:]+tctable+Str (Recno('ass_book'))+'/'+Str (Reccount ('ass_book')) Nowait
		Select asset
		Seek ass_book.Number
		If !Found()
			Select ass_book
			Delete Next 1
		Else
			Select ass_oper
			Seek ass_book.operation
			If !Found()
				Select ass_book
				Delete Next 1

			Endif
		Endif
	Endscan
	Use In ass_book
	Use In asset
	Use In ass_oper
Endcase
Return



Procedure chkdouble
Parameter tctable
Local lused, lcstring

gRekvDest = 27
gUserDest = 66
gVersiaDest = 'MSSQL'
cDataDest = 'RUGODIV'
gnhandleDest = SQLConnect (cDataDest)
If gnhandleDest < 1
	Messagebox('Viga: uhendus')
	Return .F.
Endif
tctable = 'KONTOINF'
Create Cursor qryidx_ (Id Int, inx c(20), algsaldo Y)
Index On inx + Str (algsaldo,12,2) Desc Tag inx
Do Case
Case tctable = 'KONTOINF'
	lcstring = 'select id, ltrim(rtrim(str (parentid))) as inx, algsaldo from kontoinf where rekvid = '+Str (gRekvDest)
Case tctable = 'SUBKONTO'
	lcstring = 'select id, ltrim(rtrim(str (kontoid)))+'-'+ltrim(rtrim(str(asutusId))) as inx, algsaldo from subkonto where rekvid = '+Str (gRekvDest)
Endcase
Do Case
Case gVersiaDest = 'MSSQL'
	=sqlexec (gnhandleDest,lcstring,'qryIdx')
Case gVersiaDest = 'VFP'
	lcstring = lcstring + ' into cursor qryIdx'
	&lcstring
Endcase
If !Used ('qryIdx')
	Return .F.
Endif
Select qryidx_
If Reccount () > 0
	Zap
Endif
Append From Dbf ('qryIdx')
Use In qryIdx
lcVanaIdx = ''
lused = .F.
Scan
	Wait Window Str (Recno('qryIdx_'))+'/'+Str(Reccount('qryIdx_')) Nowait
	If lcVanaIdx <> qryidx_.inx
&& первая запись
		lcVanaIdx = qryidx_.inx
	Else
		lcstring = 'delete from '+tctable+ ' where id = '+Str (qryidx_.Id)
	Endif
	Do Case
	Case gVersiaDest = 'MSSQL'
		=sqlexec (gnhandleDest,lcstring)
	Case gVersiaDest = 'VFP'
		&lcstring
	Endcase

Endscan
Endproc

Procedure err
lnErr = Aerror(err)
If lnErr > 0 And err(1,1) <> 1463  And !Isnull(err(1,2))
	Messagebox('Viga'+err(1,2))
	Set Step On
Endif
Endproc



Function korrasta
lnError = Adbobjects(atbl, 'TABLE')
If lnError<1
	Return .F.
Endif
For i = 1 To Alen(atbl, 1)
	lcTable = atbl(i)
	Wait Window Nowait 'kontrolin :'+lcTable
	If Used(lcTable)
		Use In (lcTable)
	Endif
	Use Exclusive (lcTable) Alias tbLkorrasta In 0
	If Used('tblKorrasta')
		Select tbLkorrasta
		Reindex
		Pack
		If lcTable<>'DBASE' .And. lcTable<>'CURKUUD'
			Goto Bottom
			lnId = tbLkorrasta.num
			If  .Not. Used('dbase')
				Use dbase In 0
			Endif
			Select dbase
			Set Order To Alias
			Seek lcTable
			If Found()
				Replace lastnum With lnId In dbase
			Endif
			Use In dbase
		Endif
		Use In tbLkorrasta
	Else
		cmEssage = 'Ei saa korrastada '+lcTable
		Messagebox(cmEssage, 'Kontrol')
	Endif
Endfor
Wait Window Nowait ''

Return

Function getvastisikud
Parameter clnum
Local lnreturn
lnreturn = 0
Select * From cl Where coode In (Select coode From asset) Into Cursor qryclnew
Select qryclnew
Scan
	Select qryCl
	Locate For Alltrim(Upper(nimetus)) = Alltrim(Upper(qryclnew.client))
	If !Found ()
		lcstring = " insert into asutus (rekvid, regkood, nimetus) values ("+;
			str (gRekvDest)+",'"+qryclnew.regnumber+"','"+qryclnew.client+"')"
		lerror = sqlexec (gnhandleDest,lcstring,'qryid')
	Endif
	If qryclnew.num = clnum
		lnreturn = qryid.Id
	Endif
Endscan
lerror = sqlexec (gnhandleDest,"select * from asutus",'qryCl')
Return lnreturn
Endfunc
