lnSoeVesiNomId = 115
lcMotteKpv = 'date(2011,06,30)'
lCheck = 0

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


*!*	SELECT 0
*CREATE CURSOR tmpMotted (aadress c(254), nimi c(254))
If !Used('heeter_062011')
	lcFile = 'c:\avpsoft\files\buh61\meke\heeter_062011.xls'
	Import From (lcFile) Type Xls
Endif
*SET STEP ON

Select heeter_062011
Scan For Upper(Alltrim(a)) <> 'HOTMETER' AND !EMPTY(e)
* objekt

	lcObjekt = 	Alltrim(Upper(heeter_062011.a))
	If Atc('  ',lcObjekt) > 0
		lcObjekt = Stuff(lcObjekt,Atc('  ',lcObjekt),1,'')
	Endif

	lnObjektId = 0
	lnMotteId = 0
*	WAIT WINDOW lcObjekt
	lcString = "select id from library where library = 'OBJEKT' AND RTRIM(LTRIM(UPPER(nimetus))) = '"+ lcObjekt+"'"
	lnResult = SQLEXEC(gnHandle,lcString,'qry1')
	If lnResult > 0 And Reccount('qry1') > 0
		Wait Window 'Ok' Nowait
		lnObjektId = QRY1.Id
		lcKood = Upper(lcObjekt) + '-'+Alltrim(heeter_062011.b)
		lcString = "select id from library where library = 'MOTTED' AND RTRIM(LTRIM(UPPER(kood))) = '"+ lcKood+"'"
		lnResult = SQLEXEC(gnHandle,lcString,'qry1')
		If lnResult > 0 And Reccount('qry1') > 0
			Wait Window 'Motted leitud' Nowait
			lnMotteId = QRY1.Id
		Else
* sisestamine motted andmed
			lcString = "select sp_salvesta_library(0, 1, '"+lcKood+"','kuttemotte','MOTTED','',1,"+ Str(lnObjektId)+",132,0,0)"
			lnResult = SQLEXEC(gnHandle,lcString,'qry1')
			If lnResult > 0 And Reccount('qry1') > 0
				lnMotteId = QRY1.sp_salvesta_library
			Endif
		Endif

* Naitused
* kontrollin kas on andmed selle periodi jargi


		lcString = "select id from counter where parentid = "+ Str(lnMotteId)+ " and kpv = "+lcMotteKpv

		lnResult = SQLEXEC(gnHandle,lcString,'qry1')
		If lnResult > 0 And Reccount('qry1') > 0
			Wait Window "Selle periodi jaoks motted on olemas" Nowait
		Else
			If lnResult < 0
				_Cliptext = lcString
				Wait Window "viga"
				Exit
			Endif
			lcString = "select sp_salvesta_counter(0, "+Str(lnMotteId)+","+lcMotteKpv+","+heeter_062011.F+","+heeter_062011.e+",'import')"
			lnResult = SQLEXEC(gnHandle,lcString,'qry1')

			If lnResult < 0
				_Cliptext = lcString
				Wait Window "viga"
				Exit
			Else
				Wait Window 'Motted salvestatud ' Timeout 1
			Endif
		Endif
* koef K
		If lnObjektId = 0
			Exit
		Endif

		lcString = "update objekt set nait04 = "+heeter_062011.g + " where libId = "+ Str(lnObjektId)
		lnResult = SQLEXEC(gnHandle,lcString)
		If lnResult < 0
			_Cliptext = lcString
			Wait Window "viga"
			Exit
		Else
			Wait Window 'Koef. K  salvestatud ' Timeout 1
		Endif

	Else
		Set Step On
		_Cliptext = lcString
		Wait Window 'Puudub' Nowait
*		exit
	Endif
Endscan

=SQLDISCONNECT(gnHandle)
Return

*APPEND FROM (lcFile) TYPE XL5

Select tmpIsikud
Scan For ls <> 'LS'
	Wait Window 'Import (isikud)..'+Str(Recno('tmpIsikud'))+'/'+Str(Reccount('tmpIsikud')) Nowait
* kontrolin kas see isik on andmebaasis

	lcString = "select id from asutus where regkood = '"+Alltrim(tmpIsikud.ls) +"'"
	lnError = SQLEXEC(gnHandle,lcString,'tmpId')

	Messagebox('Päringu viga')
	Exit
Endif
If Reccount('tmpId') < 1 Or Empty(tmpId.Id)
* isik puudub
	lcString = " INSERT into asutus (rekvid,regkood, nimetus) values (1,'"+Alltrim(tmpIsikud.ls)+"','"+;
		ALLTRIM(tmpIsikud.nimi)+"')"
	lnError = SQLEXEC(gnHandle,lcString)
	If lnError < 0
		Messagebox('Päringu viga')
		Set Step On
		Exit
	Else
		lcString = "select id from asutus where regkood = '"+Alltrim(tmpIsikud.ls) +"'"
		lnError = SQLEXEC(gnHandle,lcString,'tmpId')
		If lnError < 0
			Messagebox('Päringu viga')
			Exit
		Else
			Wait Window 'Import (isikud)..inserted'+Str(Recno('tmpIsikud'))+'/'+Str(Reccount('tmpIsikud')) Nowait
		Endif

	Endif
Endif

* objekted
Select Base
Scan For Alltrim(Base.ls) = Alltrim(tmpIsikud.ls)

	Wait Window 'Import (objekted)..'+Str(Recno('tmpIsikud'))+'/'+Str(Reccount('tmpIsikud')) Nowait

* kontrolin kas on objekt
	lcString = "select library.id from library inner join objekt on library.id = objekt.libid and objekt.asutusid = "+;
		STR(tmpId.Id,9)+" and library.kood = '"+Alltrim(Base.addshort)+"'"
	lnError = SQLEXEC(gnHandle,lcString,'tmpObjId')
	If lnError < 0
		Messagebox('Viga')
		Set Step On
	Endif
	If Reccount('tmpObjId') = 0
* uus ojekt

* otsime parentobjekt
		lcString = "select library.id from library inner join objekt on library.id = objekt.libid and objekt.asutusid = 0 and library.kood = '"+Alltrim(Base.house)+"'"

		lnError = SQLEXEC(gnHandle,lcString,'tmpParObjId')
		If lnError < 0
			Messagebox('Viga')
			Set Step On
		Endif
		If Reccount('tmpParObjId') = 0
* dom puudub
			lcString = "select sp_salvesta_objekt(0,1,'"+Alltrim(Base.house)+"','"+Alltrim(Base.house)+"',SPACE(1),1,0,0,0,0,0,0,"+;
				" 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,SPACE(1))"

			lnError = SQLEXEC(gnHandle,lcString,'tmpParObjekt')
			If lnError < 0
				Messagebox('Viga')
				Set Step On
				Exit
			Endif
			lnParentObjektId = tmpParObjekt.sp_salvesta_objekt
		Else
			lnParentObjektId = tmpParObjId.Id
		Endif

		Wait Window 'Import (parent objekt korras)..'+Str(Recno('tmpIsikud'))+'/'+Str(Reccount('tmpIsikud')) Nowait

		lcString = "select sp_salvesta_objekt(0,1,'"+Alltrim(Base.addshort)+"','"+Alltrim(Base.addslong)+"',SPACE(1),1,0,0,0,0,0,0,"+;
			STR(tmpId.Id,9)+",0,"+Str(Base.people,1)+","+Str(Base.rooms,1)+",0,"+Str(lnParentObjektId,9)+","+Str(Base.hotwater,1)+","+;
			STR(Base.shot,9,2)+","+Str(Base.sbath,9,2)+","+Str(Base.heating,1)+",0,0,0,0,0,0,SPACE(1))"

		lnError = SQLEXEC(gnHandle,lcString,'tmpObjekt')
		If lnError < 0
			Messagebox('Viga')
			Set Step On
			Exit
		Endif

		lnObjektId = tmpObjekt.sp_salvesta_objekt
	Else
		lnObjektId = tmpObjId.Id
	Endif
	Wait Window 'Import (objekt korras)..'+Str(Recno('tmpIsikud'))+'/'+Str(Reccount('tmpIsikud')) Nowait


* vodmer
	Select vodmer
	Scan For Alltrim(vodmer.ls) = Alltrim(tmpIsikud.ls) And Alltrim(vodmer.addshort) = Alltrim(Base.addshort)


		Wait Window 'Import (motte leitud)..'+Str(Recno('tmpIsikud'))+'/'+Str(Reccount('tmpIsikud')) Nowait
* otsime motte

		lcString = "select id from library where library = 'MOTTED' and kood = '"+Left(Alltrim(vodmer.addshort)+'/'+Alltrim(vodmer.nr),20)+"'"
		lnError = SQLEXEC(gnHandle,lcString,'tmpMotte')
		If lnError < 0
			Messagebox('Viga')
			Set Step On
			Exit
		Endif
		If Reccount('tmpMotte') < 1
* motte puudub, lisame

			lcString = "insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3) values (1,'"+;
				LEFT(Alltrim(vodmer.addshort)+'/'+Alltrim(vodmer.nr),20)+"','soevesi','MOTTED',1,"+Str(lnObjektId ,9)+","+Str(lnSoeVesiNomId,9)+")"

			lnError = SQLEXEC(gnHandle,lcString)
			If lnError < 0
				Messagebox('Viga')
				Set Step On
				Exit
			Endif
			lcString = "select id from library where library = 'MOTTED' and kood = '"+Left(Alltrim(vodmer.addshort)+'/'+Alltrim(vodmer.nr),20)+"'"
			lnError = SQLEXEC(gnHandle,lcString,'tmpMotte')
			If lnError < 0
				Messagebox('Viga')
				Set Step On
				Exit
			Endif
			Wait Window 'Import (motte inserted)..'+Str(Recno('tmpIsikud'))+'/'+Str(Reccount('tmpIsikud')) Nowait

		Endif

* sisestame andmed
		lcString = "select id from counter where parentid = "+Str(tmpMotte.Id,9)+" and kpv = "+lcMotteKpv
		lnError = SQLEXEC(gnHandle,lcString,'tmpMotteAndmed')
		If lnError < 0
			Messagebox('Viga')
			Set Step On
			Exit
		Endif
		If Reccount('tmpMotteAndmed') = 0
*andmed puuduvad, sisestame
			lcString = "select sp_salvesta_counter(0, "+Str(tmpMotte.Id,9)+","+lcMotteKpv+"," +Str(vodmer.v10,9)+","+Str(vodmer.v11,9)+",SPACE(1))"
			lnError = SQLEXEC(gnHandle,lcString)
			If lnError < 0
				Messagebox('Viga')
				Set Step On
				Exit
			Endif

			Wait Window 'Import (motte andmed inserted)..'+Str(Recno('tmpIsikud'))+'/'+Str(Reccount('tmpIsikud')) Nowait

		Endif
	Endscan
*vodmer

* lepingud

	lcString = " select id from leping1 where number = '"+Alltrim(Base.addshort)+"'"
	lnError = SQLEXEC(gnHandle,lcString,'tmpLep1Id')
	If lnError < 0
		Messagebox('Viga')
		Set Step On
		Exit
	Endif
	If Reccount('tmpLep1Id') < 1
		Wait Window 'Import (leping)..'+Str(Recno('tmpIsikud'))+'/'+Str(Reccount('tmpIsikud')) Nowait

		If Base.heating = 1
			lnPakketId = 38536
		Else
			lnPakketId = 38522
		Endif

		lcString = "select sp_salvesta_leping1(0, "+Str(tmpId.Id,9)+",1,0,'"+Alltrim(Base.addshort)+"',DATE(2010,01,01),DATE(2020,12,31),'Leping',SPACE(1),"+;
			"space(1),"+Str(lnPakketId,9)+","+Str(lnObjektId,9)+")"

		lnError = SQLEXEC(gnHandle,lcString,'tmpLep1Id')
		If lnError < 0
			Messagebox('Viga')
			Set Step On
			Exit
		Endif
		lnleping1Id = tmpLep1Id.sp_salvesta_leping1
	Else
		lnleping1Id = tmpLep1Id.Id
	Endif
	Wait Window 'Import (leping inserted)..'+Str(Recno('tmpIsikud'))+'/'+Str(Reccount('tmpIsikud')) Nowait




Endscan
* objekt
*!*		 IF RECno('tmpIsikud') > 100
*!*		 	exit
*!*		 endif

Endscan


=SQLDISCONNECT(gnHandle)


