lnSoeVesiNomId = 115
lcMotteKpv = 'date(2011,06,30)'
lCheck = 0

lcAadress = 'Geoloogia 8/1%'
gnHandle = SQLConnect('mekearv')
If gnHandle < 0
	Messagebox('Uhnduse viga',0,'Viga',10)
	Return
Endif

*!*	IF !USED('base')
*!*		USE ('C:\avpsoft\files\buh61\meke\base.dbf') in 0
*!*	ENDIF

*!*	IF !USED('vodmer')
*!*		USE ('C:\avpsoft\files\buh61\meke\vodmer.dbf') IN 0
*!*	ENDIF


Select 0

*CREATE CURSOR tmpIsikud (ls c(20), nimi c(254))
IF !USED('vd_062011')
	lcFile = 'c:\avpsoft\files\buh61\meke\vd_062011.xls'
	Import From (lcFile) Type Xls
*BROWSE

ENDIF
CREATE CURSOR vastus (aadress c(254), akogus y, lkogus y)
Select Distinct a As ls From vd_062011 Where a <> 'LS' Into Cursor tmpLs

WAIT WINDOW 'Selecting' NOWAIT

lcString = "select asutus.regkood, library.*, objekt.* from library inner join objekt on library.id = objekt.libid inner join asutus on objekt.asutusid = asutus.id where library.kood like '"+lcAadress+"'"
	lnError = SQLEXEC(gnHandle,lcString,'tmpObj')
	If lnError < 0
		Messagebox('P�ringu viga')
		SET STEP ON 
	Endif

WAIT WINDOW 'Tehtud, vormistan' NOWAIT

*SELECT * from vd_062011 WHERE a in (select tmpObj.regkood FROM tmpObj) INTO CURSOR tmpNait
SELECT VAL(ALLTRIM(vd_062011.c)) as alg, VAL(ALLTRIM(vd_062011.d )) as lopp, tmpObj.kood ;
	from vd_062011 INNER JOIN tmpObj ON ALLTRIM(vd_062011.a) = ALLTRIM(tmpObj.regkood) ;
	WHERE a in (select tmpObj.regkood FROM tmpObj) ORDER BY tmpObj.kood INTO CURSOR tmpNait

SELECT tmpNait 
WAIT WINDOW 'Eksport' NOWAIT

*brow
EXPORT TO nait.xls TYPE XL5
WAIT WINDOW 'Koik' NOWAIT


*!*	Select tmpLs
*!*	Scan
*!*		Wait Window 'Kontrollin (vodomer)..'+Str(Recno('tmpLs'))+'/'+Str(Reccount('tmpLs')) Nowait
*!*	* kontrolin kas see isik on andmebaasis
*!*		SELECT 

*!*		lnAsutusId = 0
*!*		lcString = "select id from asutus where regkood = '"+Alltrim(tmpLs.ls) +"'"
*!*		lnError = SQLEXEC(gnHandle,lcString,'tmpId')
*!*		If lnError < 0
*!*			Messagebox('P�ringu viga')
*!*			Exit
*!*		Endif
*!*		If Reccount('tmpId') > 0
*!*			lnAsutusId = tmpId.Id
*!*		Endif

*!*	* objekted

*!*		Wait Window 'otsime (objekted)..' Nowait

*!*	* kontrolin kas on objekt
*!*		lcString = "select objektid as id from leping1 where asutusId = "+ Str(lnAsutusId)
*!*		lnError = SQLEXEC(gnHandle,lcString,'tmpObjId')
*!*		If lnError < 0
*!*			Messagebox('Viga')
*!*			Set Step On
*!*			Exit
*!*		Endif
*!*		Select tmpObjId
*!*		Scan
*!*	* motted
*!*			lcKpv = "date(2011,06,30)"
*!*			lcString = "select id from counter where parentid in (select id from library where tun2 = " + Str(tmpObjId.Id)+") and kpv = "+lcKpv
*!*			lnError = SQLEXEC(gnHandle,lcString,'tmpMotteId')
*!*			If lnError < 0
*!*				Messagebox('Viga')
*!*				Set Step On
*!*				Exit
*!*			Endif
*!*			If Reccount('tmpMotteId') = 0
*!*	* motted puuduvad, sisestame
*!*	* motteid
*!*				lcString = "select id, kood from library where tun2 = "+Str(tmpObjId.Id) + " order by kood "
*!*				lnError = SQLEXEC(gnHandle,lcString,'tmpMotteId')
*!*				If lnError < 0
*!*					Messagebox('Viga')
*!*					Set Step On
*!*					Exit
*!*				Endif
*!*				Select tmpMotteId
*!*				Scan

*!*					Select vd_062011
*!*					If Recno('tmpMotteId') > 1
*!*						lnrecno = Recno()
*!*					Else
*!*						lnrecno = 0
*!*					Endif
*!*					Locate For a = tmpLs.ls And Recno() > lnrecno
*!*					If Found()
*!*						lcAlg = Alltrim(vd_062011.c)
*!*						lcLopp = Alltrim(vd_062011.d)
*!*						lcString = "select sp_salvesta_counter(0, "+Str(tmpMotteId.Id)+", "+lcKpv+","+ lcAlg+","+lcLopp+",'import')"
*!*						lnError = SQLEXEC(gnHandle,lcString)
*!*						If lnError < 0
*!*							Messagebox('Viga')
*!*							Set Step On
*!*							Exit
*!*						Endif
*!*					Endif

*!*				Endscan

*!*			Endif
*!*		Endscan

*!*	Endscan


=SQLDISCONNECT(gnHandle)

