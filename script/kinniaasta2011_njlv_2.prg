Local lError

*SET STEP ON 
gnHandle2009 = SQLConnect('njlv2011')
gnHandle2008 = SQLConnect('njlv2010')
If gnHandle2009 < 1
	Messagebox('Viga, uhendus')
	Set Step On
	Return
Endif
If gnHandle2008 < 1
	Messagebox('Viga, uhendus')
	Set Step On
	Return
Endif

* asutuse nimekirje
lcString = "select id, nimetus from rekv where id = 9 " 
*!*	and "+;
*!*	" id not in (select distinct rekvid from journal where kpv = date(2009,12,31) and selg like 'Alg.saldo%') order by id "

lError = sqlexec(gnHandle2009,lcString,'qryRekv')
if lError < 0 or not used('qryRekv')
	messagebox('Viga:'+lcString)
	return
endif

lcKpv = 'date(2011,01,01)'
lcKpv2 = 'date(2010,12,31)'
select qryRekv
scan
	lcAsutuseNimi = ltrim(rtrim(qryRekv.nimetus))
	wait window lcAsutuseNimi+' algus..' nowait 

	* Tellime saldoandmik


	* Tellime saldoasutusandmik

	IF USED('qrySaldoDeebet')
		USE IN qrySaldoDeebet
	ENDIF
	
	IF USED('qrySaldoKreedit')
		USE IN qrySaldoKreedit
	endif

	wait window lcAsutuseNimi+' subkontod ...' nowait 

	lcString = "select sp_subkontod_report('103%',"+ Str(qryRekv.id)+","+lcKpv2+","+lcKpv2+",0,'%',3,0)"
	lError = sqlexec(gnhandle2008,lcString,'qrySA')
	tcTimestamp = Alltrim(qrySA.sp_subkontod_report)

	wait window lcAsutuseNimi+' subkontod 10...' nowait 
	
	lcString = "select algjaak, konto, asutusId from tmp_subkontod_report where left(konto,6) in('103009','103610','103690','103699','103990') and timestamp = '"+tcTimestamp+"' order by konto, asutusid" 
	lError = sqlexec(gnhandle2008,lcString,'qrySaldoDeebet1')


*!*		lcString = "select sp_subkontod_report('108%',"+ Str(qryRekv.id)+","+lcKpv2+","+lcKpv2+",0,'%',3,0)"
*!*		lError = sqlexec(gnhandle2008,lcString,'qrySA')
*!*		tcTimestamp = Alltrim(qrySA.sp_subkontod_report)

*!*		lcString = "select algjaak, konto, asutusId from tmp_subkontod_report where left(konto,3) in('108') and timestamp = '"+tcTimestamp+"' order by konto, asutusid" 
*!*		lError = sqlexec(gnhandle2008,lcString,'qrySaldoDeebet3')

*!*		lcString = "select sp_subkontod_report('109%',"+ Str(qryRekv.id)+","+lcKpv2+","+lcKpv2+",0,'%',3,0)"
*!*		lError = sqlexec(gnhandle2008,lcString,'qrySA')
*!*		tcTimestamp = Alltrim(qrySA.sp_subkontod_report)

*!*		lcString = "select algjaak, konto, asutusId from tmp_subkontod_report where left(konto,3) in('109') and timestamp = '"+tcTimestamp+"' order by konto, asutusid" 
*!*		lError = sqlexec(gnhandle2008,lcString,'qrySaldoDeebet4')

*!*		lcString = "select sp_subkontod_report('155%',"+ Str(qryRekv.id)+","+lcKpv2+","+lcKpv2+",0,'%',3,0)"
*!*		lError = sqlexec(gnhandle2008,lcString,'qrySA')
*!*		tcTimestamp = Alltrim(qrySA.sp_subkontod_report)

*!*		lcString = "select algjaak, konto, asutusId from tmp_subkontod_report where left(konto,3) in('155') and timestamp = '"+tcTimestamp+"' order by konto, asutusid" 
*!*		lError = sqlexec(gnhandle2008,lcString,'qrySaldoDeebet5_')

*!*		SELECT * from qrySaldoDeebet5_ where LEFT(konto,6) in ('159910','156920','155900','155910') INTO CURSOR qrySaldoDeebet5
*!*	*	brow
*!*		USE IN qrySaldoDeebet5_

	select * from qrySaldoDeebet1 into cursor qrySaldoDeebet;
	
*	brow

	wait window lcAsutuseNimi+' subkontod 20...' nowait 

	lcString = "select sp_subkontod_report('202%',"+ Str(qryRekv.id)+","+lcKpv2+","+lcKpv2+",0,'%',3,0)"
	lError = sqlexec(gnhandle2008,lcString,'qrySA')
	tcTimestamp = Alltrim(qrySA.sp_subkontod_report)


	lcString = "select algjaak, konto, asutusId from tmp_subkontod_report where left(konto,6) in('202000','202090') and timestamp = '"+tcTimestamp+"' order by konto, asutusid" 
	lError = sqlexec(gnhandle2008,lcString,'qrySaldoKreedit1')

	lcString = "select sp_subkontod_report('203%',"+ Str(qryRekv.id)+","+lcKpv2+","+lcKpv2+",0,'%',3,0)"
	lError = sqlexec(gnhandle2008,lcString,'qrySA')
	tcTimestamp = Alltrim(qrySA.sp_subkontod_report)

	lcString = "select algjaak, konto, asutusId from tmp_subkontod_report where left(konto,6) in('203620','203850','203900','203990') and timestamp = '"+tcTimestamp+"' order by konto, asutusid" 
	lError = sqlexec(gnhandle2008,lcString,'qrySaldoKreedit2')

*!*		lcString = "select sp_subkontod_report('203%',"+ Str(qryRekv.id)+","+lcKpv2+","+lcKpv2+",0,'%',3,0)"
*!*		lError = sqlexec(gnhandle2008,lcString,'qrySA')
*!*		tcTimestamp = Alltrim(qrySA.sp_subkontod_report)

*!*		lcString = "select algjaak, konto, asutusId from tmp_subkontod_report where left(konto,3) in('203') and timestamp = '"+tcTimestamp+"' order by konto, asutusid" 
*!*		lError = sqlexec(gnhandle2008,lcString,'qrySaldoKreedit3')

*!*		lcString = "select sp_subkontod_report('206%',"+ Str(qryRekv.id)+","+lcKpv2+","+lcKpv2+",0,'%',3,0)"
*!*		lError = sqlexec(gnhandle2008,lcString,'qrySA')
*!*		tcTimestamp = Alltrim(qrySA.sp_subkontod_report)

*!*		lcString = "select algjaak, konto, asutusId from tmp_subkontod_report where left(konto,3) in('206') and timestamp = '"+tcTimestamp+"' order by konto, asutusid" 
*!*		lError = sqlexec(gnhandle2008,lcString,'qrySaldoKreedit4')

*!*		lcString = "select sp_subkontod_report('208%',"+ Str(qryRekv.id)+","+lcKpv2+","+lcKpv2+",0,'%',3,0)"
*!*		lError = sqlexec(gnhandle2008,lcString,'qrySA')
*!*		tcTimestamp = Alltrim(qrySA.sp_subkontod_report)

*!*		lcString = "select algjaak, konto, asutusId from tmp_subkontod_report where left(konto,3) in('208') and timestamp = '"+tcTimestamp+"' order by konto, asutusid" 
*!*		lError = sqlexec(gnhandle2008,lcString,'qrySaldoKreedit5')

*!*		lcString = "select sp_subkontod_report('258%',"+ Str(qryRekv.id)+","+lcKpv2+","+lcKpv2+",0,'%',3,0)"
*!*		lError = sqlexec(gnhandle2008,lcString,'qrySA')
*!*		tcTimestamp = Alltrim(qrySA.sp_subkontod_report)

*!*		lcString = "select algjaak, konto, asutusId from tmp_subkontod_report where left(konto,3) in('258') and timestamp = '"+tcTimestamp+"' order by konto, asutusid" 
*!*		lError = sqlexec(gnhandle2008,lcString,'qrySaldoKreedit6')

	select * from qrySaldoKreedit1;
	union all;
	select * from qrySaldoKreedit2;
	into cursor qrySaldoKreedit
	
*	brow

*!*		USE IN qrySaldoKreedit1
*!*		USE IN qrySaldoKreedit2
*!*		USE IN qrySaldoKreedit3
*!*		USE IN qrySaldoKreedit4
*!*		USE IN qrySaldoKreedit5
*!*		USE IN qrySaldoKreedit6

*		select * from qrySaldoKreedit1 into cursor qrySaldoKreedit


	lcString = "select id, tp from asutus " 
	lError = sqlexec(gnhandle2008,lcString,'qryAsutus')

	lnVastus = MESSAGEBOX('Andmed kogunenud, kas jatka?',1+32+256,'Kontrol')
	IF lnVastus <> 1
		return
	ENDIF
		

*	lcString = sqlexec(gnhandle2009,'begin work')

	* kustutame vana lausend
	wait window lcAsutuseNimi+' kustutame vana saldo..' nowait

*!*		* koostame deebet subkonto lausend
*!*		
	select qrySaldoDeebet
	brow
	scan
		lctegev = ''
		lcAllikas = ''
		lcRahavoo = ''
		lcTp = ''
	
		select qryAsutus
		locate for id = qrySaldoDeebet.asutusId
		if found()
			lcTp = qryAsutus.tp
		endif
	
		lcString = "insert into journal (rekvid, userid, asutusid, kpv,  selg,MUUD ) values ("+;
			str(qryRekv.id)+",60,"+str(qrySaldoDeebet.asutusId)+","+lcKpv2+",'Alg.saldo deebet','ALGSALDO')"	

		lError = sqlexec(gnhandle2009,lcString)
		if lError < 0
			messagebox('Viga.'+lcString)
			exit
		endif
		lcString = "select id from journal order by id desc limit 1"
		lError = sqlexec(gnhandle2009,lcString,'qryId')
		if lError < 0 or !used('qryId') 
			messagebox('Viga.'+lcString)
			exit
		endif
		IF LEFT(ALLTRIM(qrySaldoDeebet.konto),3) = '203' AND lcTp <> '014003'
			lcTp = '014003'
		ENDIF

		lcString = "insert into journal1 (parentid, summa,kood1,kood2,kood3,deebet,lisa_d,kreedit,lisa_k) values ("	+;
			str(qryId.id,9)+","+str(qrySaldoDeebet.algjaak,14,2)+",'"+lcTegev+"','"+lcAllikas+"','"+;
			lcRahavoo+"','"+qrySaldoDeebet.konto+"','"+lcTp+"','999999','"+lcTp+"')"

		lError = sqlexec(gnhandle2009,lcString)
		if lError < 0 or !used('qryId') 
			messagebox('Viga.'+lcString)
			exit
		endif


*			lnSummaDb = lnSummaDb +  qrySaldoDeebet.algjaak		
		
	endscan


	* koostame kreedit subkonto lausend

	select qrySaldoKreedit
*	brow


	scan
		lctegev = ''
		lcAllikas = ''
		lcRahavoo = ''
		lcTp = ''
	
		select qryAsutus
		locate for id = qrySaldoKreedit.asutusId
		if found()
			lcTp = qryAsutus.tp
		endif
		select qrySaldoKreedit
		
		lcString = "insert into journal (rekvid, asutusid, kpv, userid, selg,muud ) values ("+;
			str(qryRekv.id)+","+str(qrySaldoKreedit.asutusId)+","+lcKpv2+",60,'Alg.saldo kreedit','ALGSALDO')"	

		lError = sqlexec(gnhandle2009,lcString)
		if lError < 0
			messagebox('Viga.'+lcString)
			exit
		endif
		lcString = "select id from journal order by id desc limit 1"
		lError = sqlexec(gnhandle2009,lcString,'qryId')
		if lError < 0 or !used('qryId') 
			messagebox('Viga.'+lcString)
			exit
		endif
*!*			if qrySaldoKreedit.konto = '202010'
*!*				set step on
*!*			endif

*		lcTp = qrySaldoAruanne.tp
		IF LEFT(ALLTRIM(qrySaldoKreedit.konto),3) = '203' AND lcTp <> '014003'
			lcTp = '014003'
		ENDIF


		lcString = "insert into journal1 (parentid, summa,kood1,kood2,kood3,kreedit,lisa_k,deebet,lisa_d) values ("	+;
			str(qryId.id,9)+","+ str(-1 * qrySaldoKreedit.algjaak,14,2)+",'"+lcTegev+"','"+lcAllikas+"','"+;
			lcRahavoo+"','"+qrySaldoKreedit.konto+"','"+lcTp+"','999999','"+lcTp+"')"

		lError = sqlexec(gnhandle2009,lcString)
		if lError < 0 or !used('qryId') 
			messagebox('Viga.'+lcString)
			exit
		endif

		lnSummaKr = lnSummaKr +  (-1 * qrySaldoKreedit.algjaak)	
		
	endscan

	
*	lError = sqlexec(gnhandle2009,'commit work')

endscan 

*!*	if lError < 0
*!*			lError = sqlexec(gnhandle2009,'rollback work')

*!*	endif


=sqldisconnect(gnhandle2008)
=sqldisconnect(gnhandle2009)