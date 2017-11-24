Local lError

*SET STEP ON
gnHandle2009 = SQLConnect('njlv')
gnHandle2008 = SQLConnect('njlv2014')
 
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
lcString = "select id, nimetus from rekv where id =9" 
*!*	and "+;
*!*	" id not in (select distinct rekvid from journal where kpv = date(2009,12,31) and selg like 'Alg.saldo%') order by id "

lError = sqlexec(gnHandle2009,lcString,'qryRekv')
if lError < 0 or not used('qryRekv')
	messagebox('Viga:'+lcString)
	return
endif

lcKpv = 'date(2015,01,01)'
lcKpv2 = 'date(2014,12,31)'
select qryRekv
scan
	lcAsutuseNimi = ltrim(rtrim(qryRekv.nimetus))
	wait window lcAsutuseNimi+' algus..' nowait 

	* Tellime saldoandmik

	lcString  = " select sp_saldoandmik_report("+ Str(qryRekv.id)+","+lcKpv2+",2,0,0)"
	wait window lcAsutuseNimi+' saldoanmikuandmed..' nowait 
	lError = sqlexec(gnHandle2008,lcString,'qrySA')
	if lError < 0 or !used('qrySA')
		messagebox('Viga.'+lcString)
		exit
	endif
	
	If Used('qrySA')
		tcTimestamp = Alltrim(qrySA.sp_saldoandmik_report)
		lcString = "select konto, tp, tegev, allikas, rahavoo, sum(db) as db, sum(kr) as kr, nimetus from tmp_saldoandmik where rekvid = "+str(qryRekv.id)+;
			" and timestamp = '"+tcTimestamp +"' and "+;
			" LEFT(konto,1) in ('1','2') and "+;
			" left(konto,3) not in ('102','103','201','202') "+;
			" and LEFT(konto,6) not in ('159910','156920','155900','155910') "+;
			" group by konto, tp, tegev, allikas, rahavoo, nimetus order by konto, tp, tegev, allikas, rahavoo  "
		lError = sqlexec(gnhandle2008,lcString,'qrySaldoaruanne')
	endif
	select qrySaldoaruanne
*	brow

	* Tellime saldoasutusandmik

	IF USED('qrySaldoDeebet')
		USE IN qrySaldoDeebet
	ENDIF
	
	IF USED('qrySaldoKreedit')
		USE IN qrySaldoKreedit
	endif

	wait window lcAsutuseNimi+' subkontod ...' nowait 
*!*		if qryrekv.id = 66
*!*			set step on
*!*		endif
	
	lcString = "select sp_subkontod_report('102%',"+ Str(qryRekv.id)+","+lcKpv2+","+lcKpv2+",0,'%',3,0)"
	lError = sqlexec(gnhandle2008,lcString,'qrySA')
	tcTimestamp = Alltrim(qrySA.sp_subkontod_report)

	wait window lcAsutuseNimi+' subkontod 10...' nowait 
	
	lcString = "select algjaak, konto, asutusId from tmp_subkontod_report where left(konto,3) in('102') and timestamp = '"+tcTimestamp+"' order by konto, asutusid" 
	lError = sqlexec(gnhandle2008,lcString,'qrySaldoDeebet1')

	lcString = "select sp_subkontod_report('103%',"+ Str(qryRekv.id)+","+lcKpv2+","+lcKpv2+",0,'%',3,0)"
	lError = sqlexec(gnhandle2008,lcString,'qrySA')
	tcTimestamp = Alltrim(qrySA.sp_subkontod_report)

	lcString = "select algjaak, konto, asutusId from tmp_subkontod_report where left(konto,6) in('103000','103010','103009','103610','103690','103699','103990') and timestamp = '"+tcTimestamp+"' order by konto, asutusid" 
	lError = sqlexec(gnhandle2008,lcString,'qrySaldoDeebet2')


*!*		lcString = "select algjaak, konto, asutusId from tmp_subkontod_report where left(konto,3) in('103') and timestamp = '"+tcTimestamp+"' order by konto, asutusid" 
*!*		lError = sqlexec(gnhandle2008,lcString,'qrySaldoDeebet2')


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

	select * from qrySaldoDeebet1;
	union all;
	select * from qrySaldoDeebet2;
	into cursor qrySaldoDeebet;
	
*	brow

	wait window lcAsutuseNimi+' subkontod 20...' nowait 

	lcString = "select sp_subkontod_report('201%',"+ Str(qryRekv.id)+","+lcKpv2+","+lcKpv2+",0,'%',3,0)"
	lError = sqlexec(gnhandle2008,lcString,'qrySA')
	tcTimestamp = Alltrim(qrySA.sp_subkontod_report)

	
	lcString = "select algjaak, konto, asutusId from tmp_subkontod_report where left(konto,3) in('201') and timestamp = '"+tcTimestamp+"' order by konto, asutusid" 
	lError = sqlexec(gnhandle2008,lcString,'qrySaldoKreedit1')

	lcString = "select sp_subkontod_report('202%',"+ Str(qryRekv.id)+","+lcKpv2+","+lcKpv2+",0,'%',3,0)"
	lError = sqlexec(gnhandle2008,lcString,'qrySA')
	tcTimestamp = Alltrim(qrySA.sp_subkontod_report)

	lcString = "select algjaak, konto, asutusId from tmp_subkontod_report where left(konto,3) in('202') and timestamp = '"+tcTimestamp+"' order by konto, asutusid" 
	lError = sqlexec(gnhandle2008,lcString,'qrySaldoKreedit2')

*!*		lcString = "select sp_subkontod_report('203%',"+ Str(qryRekv.id)+","+lcKpv2+","+lcKpv2+",0,'%',3,0)"
*!*		lError = sqlexec(gnhandle2008,lcString,'qrySA')
*!*		tcTimestamp = Alltrim(qrySA.sp_subkontod_report)

*!*		lcString = "select algjaak, konto, asutusId from tmp_subkontod_report where left(konto,3) in('203') and timestamp = '"+tcTimestamp+"' order by konto, asutusid" 
*!*		lError = sqlexec(gnhandle2008,lcString,'qrySaldoKreedit3')


	lcString = "select sp_subkontod_report('203%',"+ Str(qryRekv.id)+","+lcKpv2+","+lcKpv2+",0,'%',3,0)"
	lError = sqlexec(gnhandle2008,lcString,'qrySA')
	tcTimestamp = Alltrim(qrySA.sp_subkontod_report)

	lcString = "select algjaak, konto, asutusId from tmp_subkontod_report where left(konto,6) in('203620','203850','203900','203990') and timestamp = '"+tcTimestamp+"' order by konto, asutusid" 
	lError = sqlexec(gnhandle2008,lcString,'qrySaldoKreedit3')


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
	union all;
	select * from qrySaldoKreedit3;
	into cursor qrySaldoKreedit
*!*		select * from qrySaldoKreedit3;
*!*		union all;
	
*	brow

	USE IN qrySaldoKreedit1
	USE IN qrySaldoKreedit2
	USE IN qrySaldoKreedit3
*!*		USE IN qrySaldoKreedit4
*!*		USE IN qrySaldoKreedit5
*!*		USE IN qrySaldoKreedit6

*		select * from qrySaldoKreedit1 into cursor qrySaldoKreedit


	lcString = "select id, tp from asutus " 
	lError = sqlexec(gnhandle2008,lcString,'qryAsutus')

	

	lcString = sqlexec(gnhandle2009,'begin work')

	* kustutame vana lausend
	wait window lcAsutuseNimi+' kustutame vana saldo..' nowait
	
	lcString = "delete from journal where rekvid = " + str(qryrekv.id,9)+ " and kpv = date(2014,12,31) "
	lError = sqlexec(gnhandle2009,lcString)
	if lError < 0
		messagebox('Viga.'+lcString)
		set step on
		exit
	endif

	* Koostame deebet lausend
	wait window lcAsutuseNimi+' deebet lausend..' nowait
 	lnSummaDb = 0
	lcString = "insert into journal (rekvid, userid, asutusid, kpv, selg, muud ) values ("+;
		str(qryRekv.id)+",2,0,"+lcKpv2+",'Alg.saldo deebet','ALGSALDO')"	

	lError = sqlexec(gnhandle2009,lcString)
	if lError < 0
		messagebox('Viga.'+lcString)
		set step on
		exit
	endif
	lcString = "select id from journal order by id desc limit 1"
	lError = sqlexec(gnhandle2009,lcString,'qryId')
	if lError < 0 or !used('qryId') 
		messagebox('Viga.'+lcString)
		set step on
		exit
	endif
	
	select qrySaldoAruanne
	scan for qrySaldoAruanne.db <> 0 
		lcTp = qrySaldoAruanne.tp
		IF LEFT(ALLTRIM(qrySaldoAruanne.konto),3) = '203' AND lcTp <> '014003'
			lcTp = '014003'
		ENDIF

lcString = "select Sp_salvesta_journal1(0,"+ str(qryId.id,9)+", "+str(ROUND(qrySaldoAruanne.db,2),14,2)+",'','','"+;
	  qrySaldoAruanne.tegev+"','"+qrySaldoAruanne.allikas+"','"+ qrySaldoAruanne.rahavoo+"','','','"+ qrySaldoAruanne.konto+"','"+lcTp+"','999999','"+lcTP+"','EUR',1,"+;
	  str(ROUND(qrySaldoAruanne.db,2),14,2)+",'','')"
		
	
*		if left(qrySaldoAruanne.KONTO,3) <> '102' and left(qrySaldoAruanne.konto,3) <> '103'
*!*				lcString = "insert into journal1 (parentid, summa,kood1,kood2,kood3,deebet,lisa_d,kreedit,lisa_k) values ("	+;
*!*					str(qryId.id,9)+","+str(qrySaldoAruanne.db,14,2)+",'"+qrySaldoAruanne.tegev+"','"+qrySaldoAruanne.allikas+"','"+;
*!*					qrySaldoAruanne.rahavoo+"','"+qrySaldoAruanne.konto+"','"+lcTp+"','999999','"+lcTp+"')"

			lError = sqlexec(gnhandle2009,lcString)
			if lError < 0 
				messagebox('Viga.'+lcString)
				set step on
				exit
			endif
			lnSummaDb = lnSummaDb +  qrySaldoAruanne.db		
*		endif
	endscan	
	IF lError < 0
		exit
	endif

	* koostame deebet subkonto lausend
	
	select qrySaldoDeebet
*	brow
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
			str(qryRekv.id)+",2,"+str(qrySaldoDeebet.asutusId)+","+lcKpv2+",'Alg.saldo deebet','ALGSALDO')"	

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
		IF LEFT(ALLTRIM(qrySaldoDeebet.konto),3) = '203' AND lcTp <> '014001'
			lcTp = '014001'
		ENDIF

lcString = "select Sp_salvesta_journal1(0,"+ str(qryId.id,9)+", "+str(ROUND(qrySaldoDeebet.algjaak,2),14,2)+",'','','"+;
	  lcTegev+"','"+lcAllikas+"','"+ lcRahavoo+"','','','"+ qrySaldoDeebet.konto+"','"+lcTp+"','999999','"+lcTP+"','EUR',1,"+;
	  str(ROUND(qrySaldoDeebet.algjaak,2),14,2)+",'','')"

*!*			lcString = "insert into journal1 (parentid, summa,kood1,kood2,kood3,deebet,lisa_d,kreedit,lisa_k) values ("	+;
*!*				str(qryId.id,9)+","+str(qrySaldoDeebet.algjaak,14,2)+",'"+lcTegev+"','"+lcAllikas+"','"+;
*!*				lcRahavoo+"','"+qrySaldoDeebet.konto+"','"+lcTp+"','999999','"+lcTp+"')"

		lError = sqlexec(gnhandle2009,lcString)
		if lError < 0 or !used('qryId') 
			messagebox('Viga.'+lcString)
			exit
		endif


			lnSummaDb = lnSummaDb +  qrySaldoDeebet.algjaak		
		
	endscan

	* Koostame kreedit lausend
	wait window lcAsutuseNimi+' kreedit lausend..' nowait
 	lnSummaKr = 0
 	
	lcString = "insert into journal (rekvid, userid, asutusid, kpv,  selg,muud ) values ("+;
		str(qryRekv.id)+",2,0,"+lcKpv2+",'Alg.saldo kreedit','ALGSALDO')"	

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
	
	select qrySaldoAruanne
	scan for qrySaldoAruanne.kr <> 0
*		if left(qrySaldoAruanne.konto,3) <> '201' and left(qrySaldoAruanne.konto,3) <> '202' and left(qrySaldoAruanne.konto,3) <> '203'

		lcTp = qrySaldoAruanne.tp
		IF LEFT(ALLTRIM(qrySaldoAruanne.konto),3) = '203' AND lcTp <> '014001'
			lcTp = '014001'
		ENDIF

lcString = "select Sp_salvesta_journal1(0,"+ str(qryId.id,9)+", "+str(ROUND(qrySaldoAruanne.kr,2),14,2)+",'','','"+;
	  qrySaldoAruanne.tegev+"','"+qrySaldoAruanne.allikas+"','"+ qrySaldoAruanne.rahavoo+"','','','999999','"+lcTp+"','"+qrySaldoAruanne.konto+"','"+lcTP+"','EUR',1,"+;
	  str(ROUND(qrySaldoAruanne.kr,2),14,2)+",'','')"


*!*				lcString = "insert into journal1 (parentid, summa,kood1,kood2,kood3,kreedit,lisa_k,deebet,lisa_d) values ("	+;
*!*					str(qryId.id,9)+","+str(qrySaldoAruanne.kr,14,2)+",'"+qrySaldoAruanne.tegev+"','"+qrySaldoAruanne.allikas+"','"+;
*!*					qrySaldoAruanne.rahavoo+"','"+qrySaldoAruanne.konto+"','"+lcTp+"','999999','"+lcTp+"')"

			lError = sqlexec(gnhandle2009,lcString)
			if lError < 0 
				messagebox('Viga.'+lcString)
				SET STEP on
				exit
			endif
			lnSummaKr = lnSummaKr +  qrySaldoAruanne.kr		
*		endif
	endscan	
	IF lError < 0
		exit
	endif

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
			str(qryRekv.id)+","+str(qrySaldoKreedit.asutusId)+","+lcKpv2+",2,'Alg.saldo kreedit','ALGSALDO')"	

		lError = sqlexec(gnhandle2009,lcString)
		if lError < 0
			messagebox('Viga.'+lcString)
			exit
		endif
		lcString = "select id from journal order by id desc limit 1"
		lError = sqlexec(gnhandle2009,lcString,'qryId')
		if lError < 0 or !used('qryId') 
			messagebox('Viga.'+lcString)
				SET STEP on
			exit
		endif
*!*			if qrySaldoKreedit.konto = '202010'
*!*				set step on
*!*			endif

*		lcTp = qrySaldoAruanne.tp
		IF LEFT(ALLTRIM(qrySaldoKreedit.konto),3) = '203' AND lcTp <> '014001'
			lcTp = '014001'
		ENDIF

lcString = "select Sp_salvesta_journal1(0,"+ str(qryId.id,9)+", "+str(ROUND(-1*qrySaldoKreedit.algjaak,2),14,2)+",'','','"+;
	  lcTegev+"','"+lcAllikas+"','"+ lcRahavoo+"','','','999999','"+lcTp+"','"+qrySaldoKreedit.konto+"','"+lcTP+"','EUR',1,"+;
	  str(ROUND(-1*qrySaldoKreedit.algjaak,2),14,2)+",'','')"


*!*			lcString = "insert into journal1 (parentid, summa,kood1,kood2,kood3,kreedit,lisa_k,deebet,lisa_d) values ("	+;
*!*				str(qryId.id,9)+","+ str(-1 * qrySaldoKreedit.algjaak,14,2)+",'"+lcTegev+"','"+lcAllikas+"','"+;
*!*				lcRahavoo+"','"+qrySaldoKreedit.konto+"','"+lcTp+"','999999','"+lcTp+"')"

		lError = sqlexec(gnhandle2009,lcString)
		if lError < 0 or !used('qryId') 
			messagebox('Viga.'+lcString)
				SET STEP on
			exit
		endif

		lnSummaKr = lnSummaKr +  (-1 * qrySaldoKreedit.algjaak)	
		
	endscan

*!*		* update subkonto, eelarveinf, tunnusinf
*!*		wait window lcAsutuseNimi+' Nullime algsaldo kontoplaanis ...' nowait
*!*		
*!*		lcString = "update kontoinf set algsaldo = 0 where rekvid = " + str(qryrekv.id)
*!*		lError = sqlexec(gnhandle2009,lcString)
*!*		if lError < 0  
*!*			messagebox('Viga.'+lcString)
*!*			exit
*!*		endif
*!*		lcString = "update subkonto set algsaldo = 0 where rekvid = " + str(qryrekv.id)
*!*		lError = sqlexec(gnhandle2009,lcString)
*!*		if lError < 0  
*!*			messagebox('Viga.'+lcString)
*!*			exit
*!*		endif
*!*		lcString = "update eelarveinf set algsaldo = 0 where rekvid = " + str(qryrekv.id)
*!*		lError = sqlexec(gnhandle2009,lcString)
*!*		if lError < 0  
*!*			messagebox('Viga.'+lcString)
*!*			exit
*!*		endif
*!*		lcString = "update tunnusinf set algsaldo = 0 where rekvid = " + str(qryrekv.id)
*!*		lError = sqlexec(gnhandle2009,lcString)
*!*		if lError < 0  
*!*			messagebox('Viga.'+lcString)
*!*			exit
*!*		endif
*!*		
	if (lnSummaDb - lnSummaKr) = 0
		wait window lcAsutuseNimi+' lõpp. edukalt' timeout 5
	endif
	

	
	
	lError = sqlexec(gnhandle2009,'commit work')

endscan 

if lError < 0
		lError = sqlexec(gnhandle2009,'rollback work')

endif


=sqldisconnect(gnhandle2008)
=sqldisconnect(gnhandle2009)