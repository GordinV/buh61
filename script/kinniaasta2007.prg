
gnHandle2004 = SQLConnect('meke2006','vlad','490710')
If gnHandle2004 < 1
	Messagebox('Viga,gnHandle2004')
	Return
Endif

gnHandle2005 = SQLConnect('meke2007','vlad','490710')

If gnHandle2005 < 1
	Messagebox('Viga,gnHandle2005')
	=SQLDISCONNECT(gnHandle2004)
	Return
Endif

lcString = "select * from library where library = 'KONTOD'"
lnError = SQLEXEC(gnHandle2004,lcString,'qryKONTOD')
If lnError < 0
	Messagebox('Viga,'+lcString)
	Set Step On
	Return lnError
Endif
lcstring = "select id, nimetus from rekv"
lnError = SQLEXEC(gnHandle2004,lcString,'qryRekv')
If lnError < 0
	Messagebox('Viga,'+lcString)
	Set Step On
	Return lnError
Endif
SELECT qryRekv
scan
	WAIT WINDOW qryRekv.nimetus TIMEOUT 3
	IF f_loppsaldo(qryRekv.id) < 1
		MESSAGEBOX('Viga')
		exit
	ENDIF
	
ENDSCAN

=SQLDISCONNECT(gnHandle2004)
=SQLDISCONNECT(gnHandle2005)


* loppsaldo 2004

Function f_loppsaldo
	Parameters tnRekvId
	Create Cursor curSaldod (kood c(20), asutusId Int, Summa Y, tyyp Int, tunnusid int)


	lcString = "select * from library where library = 'TUNNUS'"
	lnError = SQLEXEC(gnHandle2004,lcString,'qryTunnus')
If lnError < 0
	Messagebox('Viga,'+lcString)
	Set Step On
	Return lnError
Endif



	lcString = 'select l.kood, k.algsaldo from library l inner join kontoinf k on l.id = k.parentId '+;
		' where k.rekvid = '+Str(tnRekvId) +' and algsaldo <> 0 order by kood '
	Wait Window 'Algsaldo konto' Nowait
	lnError = SQLEXEC(gnHandle2004,lcString,'qryAlgsaldo')
	If lnError < 0
		Messagebox('Viga,'+lcString)
		Set Step On
		Return lnError
	Endif

	Insert Into curSaldod (kood, Summa, tyyp );
		SELECT kood, algsaldo, 1 From qryAlgsaldo

	lcString = 'select l.kood, k.algsaldo, k.asutusId from library l inner join subkonto k on l.id = k.kontoId '+;
		' where k.rekvid = '+Str(tnRekvId) +' and algsaldo <> 0 and asutusid > 0 order by kood '

	Wait Window 'Algsaldo subkonto' Nowait

	lnError = SQLEXEC(gnHandle2004,lcString,'qryAlgSubsaldo')
	If lnError < 0
		Messagebox('Viga,'+lcString)
		Set Step On
		Return lnError
	Endif

	Insert Into curSaldod (kood, Summa, asutusId, tyyp );
		SELECT kood, algsaldo, asutusId, 10 From qryAlgSubsaldo


	lcString = 'select l.kood, k.algsaldo, k.tunnusId from library l inner join tunnusinf k on l.id = k.kontoId '+;
		' where k.rekvid = '+Str(tnRekvId) +' and algsaldo <> 0 and tunnusid > 0 order by kood '

	Wait Window 'Algsaldo tunnus' Nowait

	lnError = SQLEXEC(gnHandle2004,lcString,'qryAlgTunsaldo')
	If lnError < 0
		Messagebox('Viga,'+lcString)
		Set Step On
		Return lnError
	Endif

	Insert Into curSaldod (kood, Summa, tunnusId, tyyp );
		SELECT kood, algsaldo, tunnusId, 10 From qryAlgTunsaldo



	lcString = 'select * from curjournal where kpv < DATE(2007,01,01) and rekvid = '+Str(tnRekvId)

	Wait Window 'kaibed' Nowait
	lnError = SQLEXEC(gnHandle2004,lcString,'qryKaibed')
	If lnError < 0
		Messagebox('Viga,'+lcString)
		Set Step On
		Return lnError
	Endif

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
		WHERE asutusId = 0 AND tunnusId > 0 ;
		AND tyyp in (100,200,300);
		Group By kood, tunnusid Order By kood Into Cursor qryLoppTunSaldo

	Select Sum(Summa) As Summa, kood, asutusId From curSaldod ;
		WHERE asutusId > 0 AND tunnusId = 0 AND tyyp in (10,20,30) ;
Group By kood, asutusid Order By kood Into Cursor qryLoppSubSaldo
	Select Sum(Summa) As Summa, kood From curSaldod ;
		WHERE asutusId = 0 AND tunnusId = 0 AND tyyp in (1,2,3);
		 Group By kood Order By kood Into Cursor qryLoppSaldo

	Select qryLoppSaldo
	lnError = SQLEXEC(gnHandle2005,'begin work')
	If lnError < 0
		Messagebox('Viga,'+'begin work')
		Set Step On
		Return lnError
	Endif
	Scan
		lnAlgsaldo = 0

		Wait Window 'Konto'+Str(Recno('qryLoppSaldo'),3)+'/'+Str(Reccount('qryLoppSaldo'),3)+':'+qryLoppSaldo.kood Nowait

*!*			IF qryLoppSaldo.kood = '202001'
*!*				SET STEP ON 
*!*			endif

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
			lcString = "update kontoinf set algsaldo = "+ALLTRIM(Str(lnAlgsaldo,16,2))+;
				" where rekvid = "+Str(tnRekvId,9)+" and parentId = "+Str(qryKONTOD.Id,9)
			lnError = SQLEXEC(gnHandle2005,lcString)
			If lnError < 0
				Messagebox('Viga,'+lcString)
				Set Step On
				Exit
			Endif

		Endif

	Endscan
	If lnError < 1
		= SQLEXEC(gnHandle2005,'rollback')
	Else
		= SQLEXEC(gnHandle2005,'commit')
	Endif
	IF lnError < 1
		RETURN lnError
	ENDIF
	
	* subkonto
	Select qryLoppSubSaldo
	lnError = SQLEXEC(gnHandle2005,'begin work')
	If lnError < 0
		Messagebox('Viga,'+'begin work')
		Set Step On
		Return lnError
	Endif

*	DELETE from qryLoppSubSaldo WHERE LEFT(kood,3) NOT in ('103','201','202','102','203') OR kood in( '202001','202002','202003','202004','202005','202006')
	Scan
		lnAlgsaldo = 0

		Wait Window 'Sub '+Str(Recno('qryLoppSubSaldo'),4)+'/'+Str(Reccount('qryLoppSubSaldo'),4)+':'+qryLoppSubSaldo.kood Nowait
		Select qryKONTOD
		Locate For Alltrim(kood) = Alltrim(qryLoppSubSaldo.kood)
		If Found()
			If qryKONTOD.tun5 > 2 OR VAL(LEFT(qryKontod.kood,1)) > 2 OR LEFT(qryKONTOD.kood,6) = '100100' 
				lnAlgsaldo = 0
			Else
				lnAlgsaldo = qryLoppSubSaldo.Summa
			ENDIF
			
			Select qryLoppSaldo
			Locate For Alltrim(kood) = Alltrim(qryLoppSubSaldo.kood)
			If Found() AND qryLoppSaldo.Summa = 0 
				lnAlgsaldo = 0
			Endif
			
			
			
			Wait WINDOW 'Updating sub:'+ Str(Recno('qryLoppSubSaldo'),4)+'/'+Str(Reccount('qryLoppSubSaldo'),4)+':'+qryLoppSubSaldo.kood+;
				STR(lnAlgsaldo,12,2) Nowait
			lcString = "update subkonto set algsaldo = "+ALLTRIM(Str(lnAlgsaldo,16,2))+;
				" where rekvid = "+Str(tnRekvId,9)+" and kontoId = "+Str(qryKONTOD.Id,9)+" and asutusId = "+STR(qryLoppSubSaldo.asutusId,9)
			lnError = SQLEXEC(gnHandle2005,lcString)
			If lnError < 0
				Messagebox('Viga,'+lcString)
				Set Step On
				Exit
			Endif

		Endif

	Endscan
	If lnError < 1
		= SQLEXEC(gnHandle2005,'rollback')
		RETURN lnError
	Else
		= SQLEXEC(gnHandle2005,'commit')
	Endif
	
	* tunnus
	Select qryLoppTunSaldo
	lnError = SQLEXEC(gnHandle2005,'begin work')
	If lnError < 0
		Messagebox('Viga,'+'begin work')
		Set Step On
		Return lnError
	Endif

	Scan
		lnAlgsaldo = 0

		Wait Window 'tun '+Str(Recno('qryLoppTunSaldo'),4)+'/'+Str(Reccount('qryLoppTunSaldo'),4)+':'+qryLoppTunSaldo.kood Nowait
		Select qryKONTOD
		Locate For Alltrim(kood) = Alltrim(qryLoppTunSaldo.kood)
		If Found()
			If qryKONTOD.tun5 > 2 OR VAL(LEFT(qryKontod.kood,1)) > 2 OR LEFT(qryKONTOD.kood,6) = '100100'
				lnAlgsaldo = 0
			Else
				lnAlgsaldo = qryLoppTunSaldo.Summa
			Endif

			Wait WINDOW 'Updating tun:'+ Str(Recno('qryLoppTunSaldo'),4)+'/'+Str(Reccount('qryLoppTunSaldo'),4)+':'+qryLoppTunSaldo.kood+;
				STR(lnAlgsaldo,12,2) Nowait
			lcString = "update tunnusinf set algsaldo = "+ALLTRIM(Str(lnAlgsaldo,16,2))+;
				" where rekvid = "+Str(tnRekvId,9)+" and kontoId = "+Str(qryKONTOD.Id,9)+" and tunnusId = "+STR(qryLoppTunSaldo.tunnusId,9)
			lnError = SQLEXEC(gnHandle2005,lcString)
			If lnError < 0
				Messagebox('Viga,'+lcString)
				Set Step On
				Exit
			Endif

		Endif

	Endscan
	If lnError < 1
		= SQLEXEC(gnHandle2005,'rollback')
	Else
		= SQLEXEC(gnHandle2005,'commit')
	Endif


	Return lnError


Endfunc
