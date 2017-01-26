* 1 koopia
lcFolder = SYS(5)+SYS(2003)
lcDataFolder = lcFolder+'\dbase'
IF !DIRECTORY(lcDataFolder)
	lcDataFolder = GETDIR()
	IF EMPTY(lcDataFolder) OR !DIRECTORY(lcDataFolder)
		RETURN .f.
	ENDIF
ENDIF
	lcUusDir = lcFolder+'\dbase2006'
	IF DIRECTORY(lcUusDir)
		lcUusDir= GETDIR()
		IF EMPTY(lcUusDir) OR !DIRECTORY(lcUusDir)
			RETURN .f.
		ENDIF
	ELSE
		MKDIR (lcUusDir)
	ENDIF


=fkoopia()
=fOpenData()


FUNCTION fkoopia
	SET DEFAULT TO (lcDataFolder)
	lnFiles = ADIR(aFiles)
	FOR i = 1 TO lnFiles
		lcFile1 = lcDataFolder+'\'+aFiles(i,1)
		lcFile2 = lcUusDir+'\'+aFiles(i,1)
		WAIT WINDOW 'Kooperin: '+lcFile1 + '-'+lcFile1 nowait
		COPY FILE (lcFile1) TO (lcFile2) 
	ENDFOR
	WAIT WINDOW 'Edukalt ..' TIMEOUT 1
*	WAIT WINDOW CLEAR nowait
	SET DEFAULT TO (lcFolder)	
	RETURN



FUNCTION fOpenData

lcdata = lcUusDir+'\buhdata5.dbc'
OPEN DATABASE (lcdata) 

select * from library where library = 'KONTOD' INTO CURSOR qryKONTOD

	IF f_loppsaldo() < 1
		MESSAGEBOX('Viga')
		exit
	ENDIF
RETURN


* loppsaldo 2004

Function f_loppsaldo
	Create Cursor curSaldod (kood c(20), asutusId Int, Summa Y, tyyp Int, tunnusid int)


	select * from library where library = 'TUNNUS' INTO CURSOR qryTunnus

	select l.kood, k.algsaldo from library l inner join kontoinf k on l.id = k.parentId ;
		 where algsaldo <> 0 order by kood INTO CURSOR qryAlgsaldo
	Wait Window 'Algsaldo konto' Nowait

	Insert Into curSaldod (kood, Summa, tyyp );
		SELECT kood, algsaldo, 1 From qryAlgsaldo

	select l.kood, k.algsaldo, k.asutusId from library l inner join subkonto k on l.id = k.kontoId ;
		 where algsaldo <> 0 and asutusid > 0 order by kood INTO CURSOR qryAlgSubsaldo

	Wait Window 'Algsaldo subkonto' Nowait

	Insert Into curSaldod (kood, Summa, asutusId, tyyp );
		SELECT kood, algsaldo, asutusId, 10 From qryAlgSubsaldo


	select l.kood, k.algsaldo, k.tunnusId from library l inner join tunnusinf k on l.id = k.kontoId ;
		where algsaldo <> 0 and tunnusid > 0 order by kood INTO CURSOR qryAlgTunsaldo

	Wait Window 'Algsaldo tunnus' Nowait


	Insert Into curSaldod (kood, Summa, tunnusId, tyyp );
		SELECT kood, algsaldo, tunnusId, 10 From qryAlgTunsaldo



	select * from curjournal_ where kpv < DATE(2007,01,01) INTO CURSOR qryKaibed
	Wait Window 'kaibed' Nowait


	Insert Into curSaldod (kood, Summa, tyyp );
		SELECT deebet, Summa, 2 From qryKaibed

	Insert Into curSaldod (kood, Summa,asutusId, tyyp );
		SELECT deebet, Summa, asutusId, 20 From qryKaibed

	Insert Into curSaldod (kood, Summa,tunnusId, tyyp );
		SELECT deebet, Summa, qryTunnus.Id, 200 From qryKaibed inner join qryTunnus ON(qryKaibed.tunnus = qryTunnus.kood AND !EMPTY(qryKaibed.tunnus))


	Insert Into curSaldod (kood, Summa, tyyp );
		SELECT kreedit, -1 * Summa, 3 From qryKaibed

	Insert Into curSaldod (kood, Summa, asutusId, tyyp );
		SELECT kreedit, -1 * Summa,asutusId, 30 From qryKaibed

	Insert Into curSaldod (kood, Summa,tunnusId, tyyp );
		SELECT kreedit, -1 * Summa, qryTunnus.Id, 300 From qryKaibed inner join qryTunnus ON(qryKaibed.tunnus = qryTunnus.kood AND !EMPTY(qryKaibed.tunnus))


	Select Sum(Summa) As Summa, kood, tunnusId From curSaldod ;
		WHERE asutusId = 0 AND tunnusId > 0 Group By kood, tunnusid Order By kood Into Cursor qryLoppTunSaldo

	Select Sum(Summa) As Summa, kood, asutusId From curSaldod ;
		WHERE asutusId > 0 AND tunnusId = 0 Group By kood, asutusid Order By kood Into Cursor qryLoppSubSaldo
	Select Sum(Summa) As Summa, kood From curSaldod ;
		WHERE asutusId = 0 AND tunnusId = 0 Group By kood Order By kood Into Cursor qryLoppSaldo


	CLOSE DATABASES 
	lcdata = lcDataFolder+'\buhdata5.dbc'
	OPEN DATABASE (lcdata)
	BEGIN TRANSACTION 
	
	Select qryLoppSaldo
	Scan
		lnAlgsaldo = 0

		Wait Window 'Konto'+Str(Recno('qryLoppSaldo'),3)+'/'+Str(Reccount('qryLoppSaldo'),3)+':'+qryLoppSaldo.kood Nowait

		IF qryLoppSaldo.kood = '202001'
			SET STEP ON 
		endif

		Select qryKONTOD
		Locate For Alltrim(kood) = Alltrim(qryLoppSaldo.kood)
		If Found()
			If qryKONTOD.tun5 > 2 OR VAL(LEFT(qryKontod.kood,1)) > 2 
				lnAlgsaldo = 0
			Else
				lnAlgsaldo = qryLoppSaldo.Summa
			Endif
			Wait WINDOW 'Updating Konto :'+ Str(Recno('qryLoppSaldo'),3)+'/'+Str(Reccount('qryLoppSaldo'),3)+':'+qryLoppSaldo.kood+;
				STR(lnAlgsaldo,12,2) Nowait
			update kontoinf set algsaldo = lnAlgsaldo where parentId = qryKONTOD.Id
			

		Endif

	Endscan
	
	* subkonto
	Select qryLoppSubSaldo

*	DELETE from qryLoppSubSaldo WHERE LEFT(kood,3) NOT in ('103','201','202','102','203') OR kood in( '202001','202002','202003','202004','202005','202006')
	Scan
		lnAlgsaldo = 0

		Wait Window 'Sub '+Str(Recno('qryLoppSubSaldo'),4)+'/'+Str(Reccount('qryLoppSubSaldo'),4)+':'+qryLoppSubSaldo.kood Nowait
		Select qryKONTOD
		Locate For Alltrim(kood) = Alltrim(qryLoppSubSaldo.kood)
		If Found()
			If qryKONTOD.tun5 > 2 OR VAL(LEFT(qryKontod.kood,1)) > 2 OR qryKONTOD.kood = '100100' 
				lnAlgsaldo = 0
			Else
				lnAlgsaldo = qryLoppSubSaldo.Summa
			ENDIF
			
			Wait WINDOW 'Updating sub:'+ Str(Recno('qryLoppSubSaldo'),4)+'/'+Str(Reccount('qryLoppSubSaldo'),4)+':'+qryLoppSubSaldo.kood+;
				STR(lnAlgsaldo,12,2) Nowait
			update subkonto set algsaldo = lnAlgsaldo ;
				where  kontoId = qryKONTOD.Id and asutusId = qryLoppSubSaldo.asutusId

		Endif

	Endscan
	
	* tunnus
	Select qryLoppTunSaldo

	Scan
		lnAlgsaldo = 0

		Wait Window 'tun '+Str(Recno('qryLoppTunSaldo'),4)+'/'+Str(Reccount('qryLoppTunSaldo'),4)+':'+qryLoppTunSaldo.kood Nowait
		Select qryKONTOD
		Locate For Alltrim(kood) = Alltrim(qryLoppTunSaldo.kood)
		If Found()
			If qryKONTOD.tun5 > 2 OR VAL(LEFT(qryKontod.kood,1)) > 2 OR qryKONTOD.kood = '100100'
				lnAlgsaldo = 0
			Else
				lnAlgsaldo = qryLoppTunSaldo.Summa
			Endif

			Wait WINDOW 'Updating tun:'+ Str(Recno('qryLoppTunSaldo'),4)+'/'+Str(Reccount('qryLoppTunSaldo'),4)+':'+qryLoppTunSaldo.kood+;
				STR(lnAlgsaldo,12,2) Nowait
			update tunnusinf set algsaldo = lnAlgsaldo ;
				where  kontoId = qryKONTOD.Id and tunnusId = qryLoppTunSaldo.tunnusId

		Endif

	ENDSCAN
	=fdeldok()
	END TRANSACTION 

	Return 1


Endfunc


FUNCTION fdeldok

		update arv set journalid = 0 where kpv < date(2007,01,01) 
		update mk set journalId = 0 where kpv < date(2007,01,01) 
		update korder1 set journalId = 0 where kpv < date(2007,01,01)
		update palk_oper set journalId = 0 where kpv < date(2007,01,01)
		update avans1 set journalId = 0 where kpv < date(2007,01,01) 
		update pv_oper set journalId = 0 where kpv < date(2007,1,1) and parentid in (select id from curPohivara_)
		update vanemtasu3 set journalId = 0 where kpv < date(2007,1,1) 
		delete from journal where kpv < date(2007,1,1)

RETURN
