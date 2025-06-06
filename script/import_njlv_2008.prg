*CLEAR ALL


gnHandle = SQLConnect('njlv2007')
If gnHandle < 0
	Messagebox('Viga uhenduses',0,'Uhendus',5)
	Return
Endif

lError = 1

Set Step On
lError = fnc_yksused()
	lError = 1
*	lcKood = UPPER(LEFT(LTRIM(sqlrekv.nimetus),7))
	lcKood = 'Projekt 3'
	lnOsakondId = fnc_osakonna_struktuur(9,lcKood)
*!*		IF !EMPTY(lError) AND lnOsakondId > 0
*!*			lError = fnc_ameti_struktuur(9,lnOsakondId, lcKood)
*!*	*!*		ELSE
*!*	*!*			SET STEP ON 
*!*		ENDIF
	IF !EMPTY(lError) AND lnOsakondId > 0
		lError = fnc_tooleping(9, lnOsakondId, lcKood)
	ENDIF
*!*		IF !EMPTY(lError) AND lnOsakondId > 0
*!*			lError = fnc_palgaStruktuur(9)
*!*		ENDIF
	IF !EMPTY(lError) AND lnOsakondId > 0
		lError = fnc_palgaKaart(9, lcKood)
	ENDIF
		lerror = fnc_analuus(9)
SELECT cur_analuus
brow
=SQLDISCONNECT(gnHandle)

FUNCTION fnc_analuus
PARAMETERS tnRekvId

IF !USED('cur_analuus')
	CREATE CURSOR cur_analuus (rekvid int, nimetus c(254), tlpuut int, tlpvana int, pkaartuut int, pkaartvana int,;
		libuut int, libvana int, plibuut int, plibvana int, klassuut int, klassvana int, ametuut int, ametvana int)
ENDIF

INSERT INTO cur_analuus (rekvId, nimetus) VALUES (tnrekvId, sqlRekv.nimetus)

* otsin vana asutuse andmed
WAIT WINDOW 'Vana asutuse andmete kogunemine ..' nowait
SELECT sqlRekv
IF sqlRekv.id <> tnrekvId
	LOCATE FOR sqlRekv.id = tnRekvId
endif
lcKood = LEFT(LTRIM(sqlRekv.nimetus),7)
lcString = "select id from library where rekvid = 62 and library = 'OSAKOND' and kood = '"+lcKood+"'"
lnError = SQLEXEC(gnHandle,lcString,'tmpId')
If lnError < 0
	Messagebox('Viga',0,'fnc_palgaKaart',10)
	*set step on
	Return lnError
Endif
lnAsutusId = tmpId.id

* arvestan  toolepingud
lcString = "select count(id)::int as kogus from tooleping where rekvid = 62 and osakondId = "+STR(lnAsutusid,9)
lnError = SQLEXEC(gnHandle,lcString,'tmpAndm')
If lnError < 0
	Messagebox('Viga',0,'fnc_analuus',20)
	*set step on
	Return lnError
Endif
replace cur_analuus.tlpvana WITH tmpAndm.kogus IN cur_analuus

* arvestan  palgakaardid
lcString = "select count(id)::int as kogus from palk_kaart where  lepingid in (select id from tooleping where rekvid = 62 and osakondId = "+STR(lnAsutusid,9)+")"
lnError = SQLEXEC(gnHandle,lcString,'tmpAndm')
If lnError < 0
	Messagebox('Viga',0,'fnc_analuus',20)
	*set step on
	Return lnError
Endif
replace cur_analuus.pkaartvana WITH tmpAndm.kogus IN cur_analuus

* arvestan  palklib, lib
lcString = "select count(id)::int as kogus from library where rekvid = 62 and library = 'PALK' and id in (select distinct libid from palk_kaart where lepingid in (select id from tooleping where rekvid = 62 and osakondId = "+STR(lnAsutusid,9)+"))"
lnError = SQLEXEC(gnHandle,lcString,'tmpAndm')
If lnError < 0
	Messagebox('Viga',0,'fnc_analuus',20)
	*set step on
	Return lnError
Endif
replace cur_analuus.libvana WITH tmpAndm.kogus IN cur_analuus

* arvestan  palklib, palk_lib
lcString = "select count(id)::int as kogus from palk_lib where  parentid in (select distinct libid from palk_kaart where  lepingid in (select id from tooleping where rekvid = 62 and osakondId = "+STR(lnAsutusid,9)+"))"
lnError = SQLEXEC(gnHandle,lcString,'tmpAndm')
If lnError < 0
	Messagebox('Viga',0,'fnc_analuus',20)
	*set step on
	Return lnError
Endif
replace cur_analuus.plibvana WITH tmpAndm.kogus IN cur_analuus

* arvestan  palklib, klassiflib
lcString = "select count(id)::int as kogus from klassiflib where libid in (select distinct libid from palk_kaart where  lepingid in (select id from tooleping where rekvid = 62 and osakondId = "+STR(lnAsutusid,9)+"))"
lnError = SQLEXEC(gnHandle,lcString,'tmpAndm')
If lnError < 0
	Messagebox('Viga',0,'fnc_analuus',20)
	*set step on
	Return lnError
Endif
replace cur_analuus.klassvana  WITH tmpAndm.kogus IN cur_analuus


* uut andmed
* arvestame  toolepingud

WAIT WINDOW 'Arvestan uut asutus  ..' nowait
lcString = "select count(id)::int as kogus from tooleping where rekvid = "+STR(tnrekvId,9)
lnError = SQLEXEC(gnHandle,lcString,'tmpAndm')
If lnError < 0
	Messagebox('Viga',0,'fnc_analuus',20)
	*set step on
	Return lnError
Endif
replace cur_analuus.tlpuut WITH tmpAndm.kogus IN cur_analuus

* arvestan  palgakaardid
lcString = "select count(id)::int as kogus from palk_kaart where  lepingid in (select id from tooleping where rekvid = "+STR(tnrekvId,9)+")"
lnError = SQLEXEC(gnHandle,lcString,'tmpAndm')
If lnError < 0
	Messagebox('Viga',0,'fnc_analuus',20)
	*set step on
	Return lnError
Endif
replace cur_analuus.pkaartuut WITH tmpAndm.kogus IN cur_analuus

* arvestan  palklib, lib
lcString = "select count(id)::int as kogus from library where rekvid = "+STR(tnrekvId,9)+" and library = 'PALK' and id in (select distinct libid from palk_kaart where  lepingid in (select id from tooleping where rekvid = "+STR(tnrekvId,9)+"))"
lnError = SQLEXEC(gnHandle,lcString,'tmpAndm')
If lnError < 0
	Messagebox('Viga',0,'fnc_analuus',20)
	*set step on
	Return lnError
Endif
replace cur_analuus.libuut WITH tmpAndm.kogus IN cur_analuus

* arvestan  palklib, palk_lib
lcString = "select count(id)::int as kogus from palk_lib where  parentid in (select distinct libid from palk_kaart where  lepingid in (select id from tooleping where rekvid = "+STR(tnrekvId,9)+"))"
lnError = SQLEXEC(gnHandle,lcString,'tmpAndm')
If lnError < 0
	Messagebox('Viga',0,'fnc_analuus',20)
	*set step on
	Return lnError
Endif
replace cur_analuus.plibuut WITH tmpAndm.kogus IN cur_analuus

* arvestan  palklib, klassiflib
lcString = "select count(id)::int as kogus from klassiflib where libid in (select distinct libid from palk_kaart where  lepingid in (select id from tooleping where rekvid = "+STR(tnrekvId,9)+"))"
If lnError < 0
	Messagebox('Viga',0,'fnc_analuus',20)
	*set step on
	Return lnError
Endif
replace cur_analuus.klassuut  WITH tmpAndm.kogus IN cur_analuus

SELECT cur_analuus
*brow

ENDFUNC



Function fnc_palgaKaart
	Lparameters tnRekvId, tcOsakond

	Create Cursor cur_palga_kaart (vanaid Int, uutid Int, rekvid Int)


*	If !Used('sqlHKSPalgaKaart')
		lcString = "SELECT Palk_kaart.id, Palk_kaart.parentid, Palk_kaart.lepingid, Palk_kaart.libid, palk.kood as palk, "+;
			" Tooleping.osakondid, Tooleping.ametid, osakond.kood as osakond, amet.kood as amet "+;
			" FROM palk_kaart INNER JOIN tooleping  ON  Palk_kaart.lepingid = Tooleping.id inner join library palk on palk.id = palk_kaart.libId "+;
			" inner join library osakond on osakond.id = tooleping.osakondId "+;
			" inner join library amet on amet.id = tooleping.ametId "+;			
			" where tooleping.rekvid = 1 "
		lnError = SQLEXEC(gnHandle,lcString,'sqlHKSPalgaKaart')
		If lnError < 0
			Messagebox('Viga',0,'fnc_palgaStruktuur',10)
			*set step on
			Return lnError
		Endif
*	ENDIF
	lcString = "select * from library where rekvid = 9 and library = 'PALK'"
		lnError = SQLEXEC(gnHandle,lcString,'sqlUusPalk')
		If lnError < 0
			Messagebox('Viga',0,'fnc_palgaStruktuur',10)
			*set step on
			Return lnError
		Endif
	lcString = "select * from library where rekvid = 9 and library = 'OSAKOND' and kood = '"+tcOsakond+"'"
		lnError = SQLEXEC(gnHandle,lcString,'sqlUusOsakond')
		If lnError < 0
			Messagebox('Viga',0,'fnc_palgaStruktuur',10)
			*set step on
			Return lnError
		Endif
	lcString = "select * from library where rekvid = 9 and library = 'AMET'"
		lnError = SQLEXEC(gnHandle,lcString,'sqlUusAmet')
		If lnError < 0
			Messagebox('Viga',0,'fnc_palgaStruktuur',10)
			*set step on
			Return lnError
		Endif

	lcString = "select * from tooleping where rekvid = 9 and osakondId = "+STR(sqlUusOsakond.id,9)
		lnError = SQLEXEC(gnHandle,lcString,'sqlUusTooleping')
		If lnError < 0
			Messagebox('Viga',0,'fnc_palgaStruktuur',10)
			*set step on
			Return lnError
		Endif

	
	Select Distinct  Id, lepingid, libid From sqlHKSPalgaKaart Where osakond = tcOsakond Into Cursor tmpKaardid
	Scan
		Wait Window 'tmpKaardid ..'+Str(Recno('tmpKaardid'),9) Nowait

		SELECT sqlHKSPalgaKaart
		LOCATE FOR id = tmpKaardid.id
		
		SELECT sqluusAmet
		LOCATE FOR kood = sqlHKSPalgaKaart.amet

		SELECT sqlUuspalk
		LOCATE FOR kood = sqlHKSPalgaKaart.palk
		
		SELECT sqluusTooleping
		LOCATE FOR ametid = sqlUusAmet.id
*!*			Select cur_tooleping
*!*			Locate For vanaid = tmpKaardid.lepingid

*!*			Select  cur_palklib
*!*			Locate For vanaid = tmpKaardid.libid
		
		
		If !Eof('sqluusTooleping') And !Eof('sqlUuspalk')
			lcString = "select sp_kopeeri_palgakaart("+Str(tmpKaardid.Id,9)+","+Str(sqluusTooleping.id,9)+","+Str(sqluuspalk.id,9)+")"
			lnError = SQLEXEC(gnHandle,lcString,'tmpId')
			If lnError < 0
				Messagebox('Viga',0,'fnc_palgaKaart',10)
				*set step on
				Return lnError
			Endif
			Insert Into cur_palga_kaart (vanaid, uutid, rekvid) Values (tmpKaardid.Id,tmpId.sp_kopeeri_palgakaart,tnRekvId)
			USE IN tmpId
			
		Endif

	ENDSCAN
	
	IF USED('tmpKaardid')
		USE IN tmpKaardid 
	ENDIF
	
*	USE IN tmpKaardid 
	
	lnreturn = Recno('cur_palga_kaart')
	Select cur_palga_kaart
*	Browse
	USE IN cur_palga_kaart
	USE IN cur_tooleping
*	USE IN cur_amet
*	USE IN cur_palklib
		
	Return lnreturn

Endfunc



Function fnc_palgaStruktuur
	Lparameters tnRekvId

	If !Used('cur_amet') Or !Used('cur_tooleping')
		Messagebox('Puudub failid ..')
		Return
	Endif

	Create Cursor cur_palklib (vanaid Int, uutid Int, rekvid Int)

*!*	IF !USED('sqlHKSPalgaStruktuur')
*!*	lcString = "SELECT Library.id FROM library  INNER JOIN palk_lib oN  Library.id = Palk_lib.parentid where library.rekvid = 62"
*!*		lnError = SQLEXEC(gnHandle,lcString,'sqlHKSPalgaStruktuur')
*!*		If lnError < 0
*!*			Messagebox('Viga',0,'fnc_palgaStruktuur',10)
*!*			Set Step On
*!*			Return lnError
*!*		Endif
*!*	ENDIF

	If !Used('sqlHKSPalgaKaart')
		lcString = "SELECT Palk_kaart.id, Palk_kaart.parentid, Palk_kaart.lepingid, Palk_kaart.libid, Tooleping.osakondid, Tooleping.ametid "+;
			" FROM palk_kaart INNER JOIN tooleping  ON  Palk_kaart.lepingid = Tooleping.id  where tooleping.rekvid = 1 "
		lnError = SQLEXEC(gnHandle,lcString,'sqlHKSPalgaKaart')
		If lnError < 0
			Messagebox('Viga',0,'fnc_palgaStruktuur',10)
			*set step on
			Return lnError
		Endif
	Endif


	Select Distinct libid From sqlHKSPalgaKaart Where lepingid In (Select vanaid From cur_tooleping) Into Cursor tmpPalkLib

* import palgastruktuur
	Select tmpPalkLib
	Scan
		Wait Window 'import tmpPalkLib ..' + Str(Recno('tmpPalkLib'),9) Nowait
		lcString = "select sp_kopeeri_palkastruktuur(" + Str(tmpPalkLib.libid,9)+","+Str(tnRekvId,9)+")"
		lnError = SQLEXEC(gnHandle,lcString,'tmpId')
		If lnError < 0
			Messagebox('Viga',0,'fnc_palgaStruktuur',10)
			*set step on
			*Return lnError
		else
			Insert Into cur_palklib (vanaid, uutid, rekvid) Values (tmpPalkLib.libid,tmpId.sp_kopeeri_palkastruktuur,tnRekvId)
			USE IN tmpId
		Endif
	ENDSCAN
	USE IN tmpPalkLib
	
	lcString = "select sp_parandada_palkastruktuur(ID) from library where rekvid = "+STR(tnrekvid,9) +" and library = 'PALK'"
		lnError = SQLEXEC(gnHandle,lcString)
		If lnError < 0
			Messagebox('Viga',0,'sp_parandada_palkastruktuur',10)
			*set step on
			Return lnError
		Endif
	
	Return Reccount('cur_palklib')

Endfunc


Function fnc_tooleping
	Lparameters tnRekvId, tnOsakondId, tcKood
	Wait Window 'fnc_tooleping ... ' Nowait
*	If !Used('cur_tooleping')
		Create Cursor cur_tooleping (vanaid Int, uutid Int, rekvid Int)
*	Endif

* kustutame vana toolepingud
*!*		Wait Window 'kustutame vana toolepingud ..' Nowait

*!*		lcString = "delete from tooleping where rekvId = "+Str(tnRekvId,6)
*!*		lnError = SQLEXEC(gnHandle,lcString)
*!*		If lnError < 0
*!*			Messagebox('Viga',0,'fnc_tooleping',10)
*!*			*set step on
*!*			Return lnError
*!*		Endif
*!*		Wait Window 'kustutame vana toolepingud .. done' Timeout 1


	* otsime vanaosakondId
	lcOsakonnaKood = tcKood

*	If !Used('sqlHKSToolepingud')
		Wait Window 'sqlHKSToolepingud .. ' Nowait
		lcString = "select tooleping.*, osakond.kood as osakond, amet.kood as amet "+;
			" from tooleping inner join library osakond on osakond.id = tooleping.osakondId inner join library amet on amet.id = tooleping.ametid "+;
			" where tooleping.rekvId = 1 and osakondid in (select id from library where rekvid = 1 and library = 'OSAKOND' "+;
			" and kood = '"+lcOsakonnaKood+"')"
		lnError = SQLEXEC(gnHandle,lcString,'sqlHKSToolepingud')
		If lnError < 0
			Messagebox('Viga',0,'fnc_tooleping',10)
			*set step on
			Return lnError
		Endif
		Wait Window 'sqlHKSToolepingud ... done kokku:'+ Str(Reccount('sqlHKSToolepingud'),6) Timeout 1
*	Endif

	lnCount = 0

	lcString = "select * from library where rekvid = 9 and library = 'AMET' "
		lnError = SQLEXEC(gnHandle,lcString,'sqlamet')
		If lnError < 0
			Messagebox('Viga',0,'fnc_tooleping',10)
			*set step on
			Return lnError
		Endif

	Select sqlHKSToolepingud
	Scan FOR osakond = tcKood
			lnCount = lnCount +1
			Wait Window 'uut tooleping ..'+ Str(lnCount,6) Nowait
			
			SELECT sqlamet
			LOCATE FOR kood = sqlHKSToolepingud.amet
			IF FOUND()
			
			lcString = "insert into Tooleping (parentid, osakondid, ametid, algab, lopp, toopaev, palgamaar, palk, pohikoht,koormus, ametnik,"+;
				" tasuliik, muud, rekvid, toend, resident, riik) values ("+;
				STR(sqlHKSToolepingud.parentId,9)+","+Str(tnOsakondId,9)+","+Str(sqlamet.id,9)+","+;
				fnc_kpv(sqlHKSToolepingud.algab)+","+fnc_kpv(sqlHKSToolepingud.lopp)+","+;
				STR(sqlHKSToolepingud.toopaev,12,4)+","+Str(sqlHKSToolepingud.palgamaar,12,2)+","+;
				STR(sqlHKSToolepingud.palk,12,2)+","+Str(sqlHKSToolepingud.pohikoht,6)+","+;
				STR(sqlHKSToolepingud.koormus,12,4)+","+Str(sqlHKSToolepingud.ametnik,6)+","+Str(sqlHKSToolepingud.tasuliik,4)+",'"+;
				IIF(Isnull(sqlHKSToolepingud.muud),'',sqlHKSToolepingud.muud)+"',"+Str(tnRekvId,9)+","+fnc_kpv(sqlHKSToolepingud.toend)+","+;
				STR(sqlHKSToolepingud.resident,6)+",'"+sqlHKSToolepingud.riik+"')"

			lnError = SQLEXEC(gnHandle,lcString)
			If lnError < 0
				Messagebox('Viga',0,'fnc_tooleping',10)
				*set step on
				Return lnError
			Endif
			lcString = "select id from tooleping where rekvid = "+Str(tnRekvId,9) + " order by id desc limit 1"
			lnError = SQLEXEC(gnHandle,lcString,'tmpId')
			If lnError < 0
				Messagebox('Viga',0,'fnc_tooleping',10)
				*set step on
				Return lnError
			Endif
			Insert Into cur_tooleping (vanaid, uutid, rekvid) Values (sqlHKSToolepingud.Id, tmpId.Id, tnRekvId)
			USE IN tmpId
			ENDIF
			
		Endscan

	Select cur_tooleping
*	Brow
	Return Reccount('cur_tooleping')
Endfunc


Function fnc_kpv
	Lparameters tdKpv
	Local lcKpv
	If Empty(tdKpv) Or Isnull(tdKpv)
		Return 'null'
	Endif
	lcKpv = "date("+Str(Year(tdKpv),4)+","+Str(Month(tdKpv),2)+","+Str(Day(tdKpv),2)+")"

	Return lcKpv
Endfunc



Function fnc_ameti_struktuur
	Lparameters tnRekvId, tnOsakondId, tcOsakonnaKood
* selecting from parentosakond
* checking meie struktuur
* deleting all mitte meie
* insert oma struktuur


	Create Cursor cur_amet(vanaAmetId Int, uutAmetid Int, rekvid Int)

* SELECT SOURCE
	Wait Window 'fnc_ameti_struktuur ... ' Nowait

	If !Used('sqlHKSstruktuur')
		Wait Window 'sqlHKSstruktuur ... ' Nowait
		lcString = " SELECT Library.*, Palk_asutus.osakondid, Palk_asutus.ametid, Palk_asutus.kogus, Palk_asutus.vaba, Palk_asutus.palgamaar,"+;
			" Palk_asutus.muud, Palk_asutus.tunnusid "+;
			" FROM library  INNER JOIN palk_asutus  ON  Library.id = Palk_asutus.ametid "+;
			" where library.rekvid = 1 "

		lnError = SQLEXEC(gnHandle,lcString,'sqlHKSstruktuur')
		If lnError < 0
			Messagebox('Viga',0,'fnc_ameti_struktuur',10)
			*set step on
			Return lnError
		Endif
		Wait Window 'sqlHKSstruktuur ... done kokku:'+ Str(Reccount('sqlHKSstruktuur'),6) Timeout 1
	Endif

* otsime meie struktuuri Id
	Select sqlYksus
	Locate For kood = tcOsakonnaKood
	If !Found()
		*set step on
		Return .F.
	Endif

*!*	* kustutame vana andmeid
*!*		Wait Window 'kustutame vana andmeid ... ' Nowait

*!*		lcString = " delete from library where rekvid = "+Str(tnRekvId,9) + " and library = 'AMET' "
*!*		lnError = SQLEXEC(gnHandle,lcString,'sqlHKSstruktuur')
*!*		If lnError < 0
*!*			Messagebox('Viga',0,'fnc_ameti_struktuur',10)
*!*			*set step on
*!*			Return lnError
*!*		Endif
*!*		Wait Window 'kustutame vana andmeid ... done' Timeout 1

* lisame uut struktuur
	Wait Window 'lisame uut struktuur ... ' Nowait
	lnCount = 0
	Select sqlHKSstruktuur
	Scan For osakondId = sqlYksus.Id
		lnCount = lnCount +1
		Wait Window 'Lisan struktuur .. '+Str(lnCount,9) Nowait
		lcString = "select sp_salvesta_palk_amet(0,"+Str(tnRekvId,9)+",'"+Alltrim(sqlHKSstruktuur.kood)+"'::varchar,'"+Alltrim(sqlHKSstruktuur.nimetus)+"'::varchar,"+Str(tnOsakondId,9)+","+;
			STR(sqlHKSstruktuur.kogus,12,2)+",0,"+Str(sqlHKSstruktuur.vaba,12,2)+","+Str(sqlHKSstruktuur.palgamaar,9)+")"
		lnError = SQLEXEC(gnHandle,lcString,'tmpId')
		If lnError < 0
			Messagebox('Viga',0,'fnc_ameti_struktuur',10)
			*set step on
			Return lnError
		Endif
		Insert Into cur_amet(vanaAmetId , uutAmetid, rekvid ) Values (sqlHKSstruktuur.Id, tmpId.sp_salvesta_palk_amet, tnRekvId)

	Endscan
	Select cur_amet
*brow
	Return Reccount('cur_amet')

Endfunc


Function fnc_osakonna_struktuur
	Lparameters tnRekvId, tcKood
* koostab asutuse structuur

	Local lnOmaOsakonnaId
	lnOmaOsakonnaId = 0

	lcString = "select * from library where library = 'OSAKOND' and rekvid = "+Str(tnRekvId,6)
	lnError = SQLEXEC(gnHandle,lcString,'sqlOsakond')
	If lnError < 0
		Messagebox('Viga',0,'fnc_osakonna_struktuur',5)
		*set step on
		Return lnError
	Endif

	If Reccount('sqlOsakond') > 0
* kustuta koik peale oma osakond
		Select sqlOsakond
		Locate For UPPER(kood) = UPPER(tcKood)
		If Found()
			lnOmaOsakonnaId = sqlOsakond.Id
		Endif
*!*			Scan For Id <> lnOmaOsakonnaId And rekvid = tnRekvId And Library = 'OSAKOND'
*!*				lcString = " select sp_del_osakonnad("+Str(sqlOsakond.Id,9)+",0)"
*!*				lnError = SQLEXEC(gnHandle,lcString,'tmpDel')
*!*				If lnError < 0
*!*					Messagebox('Viga',0,'fnc_osakonna_struktuur',5)
*!*					*set step on
*!*					Return lnError
*!*				Endif

*!*			Endscan

	Endif
	If lnOmaOsakonnaId = 0
* puudub osakond, lisame
		Select sqlYksus
		Locate For UPPER(kood) = UPPER(tcKood)
		If !Found()
			*set step on
			Return 0
		Endif
		lcString = "insert into library (rekvId, kood, nimetus,library) " +;
			" select "+Str(tnRekvId,9)+",kood, nimetus, library from library where id = "+Str(sqlYksus.Id,9)

		lnError = SQLEXEC(gnHandle,lcString)
		If lnError < 0
			Messagebox('Viga',0,'fnc_osakonna_struktuur')
			*set step on
			Return lnError
		Endif
		lcString = "select * from library where library = 'OSAKOND' AND rekvid = " + Str(tnRekvId,9)+" order by id desc limit 1"
		lnError = SQLEXEC(gnHandle,lcString)
		If lnError < 0
			Messagebox('Viga',0,'fnc_osakonna_struktuur','QRYiD')
			*set step on
			Return lnError
		Endif
		If Used('qryid') And UPPER(kood) = UPPER(sqlYksus.kood) And rekvid = tnRekvId
			lnOmaOsakonnaId = qryId.Id
		Endif

	Endif

	Return lnOmaOsakonnaId

Endfunc



Function fnc_yksused
* yksuse list
* 1. select library
* 2. select from rekv where left(nimetus,..) = yksuse.kood

	lcString = "select id, kood, nimetus from library where rekvid = 1 and library = 'OSAKOND'"
	lnError = SQLEXEC(gnHandle,lcString,'sqlYksus')
	If lnError < 0
		Messagebox('Viga',0,'fnc_yksused',5)
		*set step on
		Return lnError
	Endif

	lcString = "select id, nimetus from rekv where parentid = 1"
	lnError = SQLEXEC(gnHandle,lcString,'sqlRekv')
	If lnError < 0
		Messagebox('Viga',0,'fnc_yksused',5)
		*set step on
		Return lnError
	Endif


Endfunc

