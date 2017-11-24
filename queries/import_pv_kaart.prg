local lError
SET POINT TO '.'
Set step on
gnHandle = sqlconnect('buhdata5','zinaida','159')
If gnHandle < 0
	Set step on
	Return
Endif
=sqlexec(gnHandle,'BEGIN TRANSACTION')
gRekv = 1
tcKood = '%%'
tcNimetus = '%%'
tcKonto = '%%'
tcVastIsik = '%%'
tcGrupp = '%%'
tnSoetmaks1 = -99999999999
tnSoetmaks2 = 99999999999
tdSoetkpv1 = date(1995,01,01)
tdSoetkpv2 = date()

Set classlib to classes\classlib
oDb = createobject('db')
*!*	Select AS_GOODS.type, AS_GOODS.group, AS_GOODS.code, NAME, AS_MGDS.REG_DATE, AS_MGDS.REG_NUM,;
*!*		AS_MGDS.GOODS,AS_GOODS.PERCENT,AS_MGDS.DEB_BILL,AS_MGDS.cre_BILL,;
*!*		AS_MGDS.INV_NUM, AS_MGDS.SUMMA FROM AS_GOODS;
*!*		INNER JOIN AS_MGDS ON AS_GOODS.TYPE+AS_GOODS.GROUP+AS_GOODS.CODE = AS_MGDS.GOODS ;
*!*		where (left(AS_MGDS.REG_NUM,2) = 'RT' OR;
*!*		left(AS_MGDS.REG_NUM,2) = 'NS';
*!*		or left(AS_MGDS.REG_NUM,2) = 'FI';
*!*		OR left(AS_MGDS.REG_NUM,2) = 'KK');
*!*		and left (alltrim(as_mgds.deb_bill),2) = '18';
*!*		order by as_mgds.inv_num;
*!*		INTO CURSOR QRYpOHIVARA
*!*	Select QRYpOHIVARA
*!*	SET STEP ON
*!*	Scan 
*!*		wait window qrypohivara.name nowait
*!*		lError = create_kaart()
*!*		If lError = .f.
*!*			Exit
*!*		Endif
*!*	ENDSCAN
	lError = imp_algkulum()
	If lError = .t.
		=sqlexec(gnHandle,'COMMIT TRANSACTION')
		Messagebox('Ok','Kontrol')
	Else
		=sqlexec(gnHandle,'ROLLBACK TRANSACTION')
		Messagebox('Viga','Kontrol')
	Endif
	=sqldisconnect(gnHandle)

Function imp_algkulum
Select AS_MGDS.INV_NUM, AS_MGDS.SUMMA FROM AS_MGDS ;
	where left(AS_MGDS.REG_NUM,2) = 'NS' ;
	and as_mgds.deb_bill = '999';
	and as_mgds.cre_bill = '185';
	order by as_mgds.inv_num;
	INTO CURSOR QRYALGKULUM
scan
	cString = "select id from library where ltrim(rtrim(kood)) = '"+ltrim(rtrim(qryAlgkulum.inv_num))+"'"+;
		" and library = 'POHIVARA'"
	LeRROR = sqlexec(gnHandle,cString,'qryPvKaart')
	if lError < 1 or reccount ('qryPvKaart') < 1
		set step on
		exit
	endif 
	cString = 'update pv_kaart set algkulum = '+str (qryalgkulum.summa,12,2)+;
		' where parentid = '+str (qryPvKaart.id)
	LeRROR = sqlexec(gnHandle,cString)
	if lError < 1 
		set step on
		exit
	endif 
endscan
lError = iif (lError < 1,.f.,.t.)
return lError

Function pv_kulum
	lError = .t.

	Select AS_MGDS.REG_DATE, AS_MGDS.REG_NUM,;
		AS_MGDS.GOODS, AS_MGDS.SUMMA FROM AS_GOODS;
		INNER JOIN AS_MGDS ON AS_GOODS.TYPE+AS_GOODS.GROUP+AS_GOODS.CODE = AS_MGDS.GOODS ;
		where left(AS_MGDS.REG_NUM,2) = 'HU';
		and AS_MGDS.GOODS = qryPohivara.goods;
		and as_mgds.inv_num = qryPohivara.inv_num;
		INTO CURSOR QRYKulum
	Select QRYKulum
	Scan
		nNomId = 159
		lnDokProp = 1037
		oDb.use ('v_pv_oper','v_pvkulum',gnHandle,.t.)
		Select v_pvkulum
		Append blank
		Replace parentId with v_library.id,;
			nomId with nNomId,;
			doklausId with lnDokProp,;
			liik with 2,;
			kpv with QRYkulum.REG_DATE,;
			summa with QRYkulum.summa in v_pvkulum
		lError = oDb.cursorupdate('v_pvkulum','v_pv_oper')
		If lError = .f.
			Set step on
			Exit
		Endif
	Endscan
	Return lError


Function pv_paigutus
	lError = .f.
*!*		Select curPohivara
*!*		Locate for alltrim(curPohivara.nimetus) = alltrim(QRYpOHIVARA.name)
*!*		If !found()
*!*			Return
*!*		Endif
	nNomId = 158
	lnDokProp = 1036
	oDb.use ('v_pv_oper','v_pv_oper',gnHandle,.t.)
	Select v_pv_oper
	Append blank
	Replace parentId with V_LIBRARY.id,;
		nomId with nNomId,;
		doklausId with lnDokProp,;
		liik with 1,;
		kpv with QRYpOHIVARA.REG_DATE,;
		summa with QRYpOHIVARA.summa in v_pv_oper
	lError = oDb.cursorupdate('v_pv_oper')
	Return lError

Function get_algkulum
Select sum(AS_MGDS.SUMMA) as summa FROM  AS_MGDS ;
	where AS_MGDS.goods = qryPohivara.goods;
	and left (as_mgds.reg_num,2) = 'NS' ;
	AND DEB_BILL = '999';
	INTO CURSOR QRYALGKULUM
Select QRYALGKULUM
return QRYALGKULUM.summa

Function create_kaart
	oDb.use ('v_library','v_library',gnHandle,.t.)
	oDb.use ('v_pv_kaart','v_pv_kaart',gnHandle,.t.)
	nGruppId = get_grupp()
	If nGruppId = 0
		Set step on
		Return .f.
	Endif

Select AS_MGDS.INV_NUM, AS_MGDS.SUMMA FROM AS_MGDS ;
	where left(AS_MGDS.REG_NUM,2) = 'NS' ;
	and as_mgds.deb_bill = '999';
	and as_mgds.cre_bill = '185';
	and AS_MGDS.GOODS = qryPohivara.goods;
	and as_mgds.inv_num = qryPohivara.inv_num;
	order by as_mgds.inv_num;
	INTO CURSOR QRYALGKULUM

	nKulum = QRYALGKULUM.summa
	use in qryAlgKulum
	Select v_library
	Append blank
	Replace rekvid with 1,;
		kood with alltrim(QRYpOHIVARA.INV_NUM),;
		nimetus with rtrim(QRYpOHIVARA.name),;
		library with 'POHIVARA'
	lError = oDb.cursorupdate('v_library')
	If lError = .t.
	Select v_pv_kaart
	Append blank

	Replace soetmaks with QRYpOHIVARA.summa,;
		parentid with v_library.id,;
		algkulum with nKulum,;
		soetkpv with QRYpOHIVARA.REG_DATE,;
		kulum with QRYpOHIVARA.PERCENT,;
		konto with QRYpOHIVARA.DEB_BILL,;
		tunnus with 1,;
		vastisikId with 7,;
		gruppId with nGruppId in v_pv_kaart
		lError = oDb.cursorupdate('v_pv_kaart')
	Endif
	If lError = .t.	
		lError = pv_paigutus()
	endif
	If lError = .t.
		lError = pv_kulum()
	endif
	Return lError

Function get_grupp
	Local lnReturn
	lnReturn = 0
	Select * from AS_GOODS;
		where type = QRYpOHIVARA.type and group = QRYpOHIVARA.group;
		and empty (AS_GOODS.code) into cursor qry1
	IF RECCOUNT ('QRY1') < 1
		SET STEP ON
	ENDIF
	cString = "select id from library where library = 'PVGRUPP' and rtrim(nimetus) = '"+rtrim(qry1.name)+"'"
	lError = sqlexec(gnHandle,cString,'qry2')
	If lError < 1
		Set step on

	Endif
	lnReturn = qry2.id
	Use in qry2
	Return lnReturn
