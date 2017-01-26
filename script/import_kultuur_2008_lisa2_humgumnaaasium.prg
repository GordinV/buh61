*CLEAR ALL


gnHandle = SQLConnect('NarvaLvPg')
If gnHandle < 0
	Messagebox('Viga uhenduses',0,'Uhendus',5)
	Return
Endif

lError = 1
*Set Step On

lnDestAsutusId = 85
* hum. gumaasium

lnSourceAsutusid = 91
* hum. gumaasium

*!*	IF !EMPTY(lError)
*!*		lError = fnc_ameti_struktuur(lnDestAsutusId, 287538,'0911012')
*!*	ENDIF
IF !EMPTY(lError)
*!*		set step on
*!*			lError = fnc_palgaStruktuur(lnDestAsutusId)
*!*			lError = fnc_tooleping(lnDestAsutusId, 287538,'0911012')
		lError = fnc_palgaKaart(lnDestAsutusId,'0911012')
ENDIF


=SQLDISCONNECT(gnHandle)





Function fnc_eelarve
lParameter tnrekvId, tcKood, tcTunnus
if !used('nlvko2008')
	messagebox('Cursor ei leidnud')
endif

* taotluse number
lnNumber = 0
lcString = "select number from taotlus where rekvid = " + str(tnrekvid,9) + "order by id desc" 

lnError = SQLEXEC(gnHandle,lcString,'tmpNumber')
If lnError < 0
	Messagebox('Viga',0,'fnc_pv',10)
	set step on
	Return lnError
Endif

lnNumber = tmpNumber.number + 1
use in tmpNumber


* create taotlus
lcString = " insert into taotlus (rekvid, koostajaid,ametnikid,aktseptid, kpv, number, aasta, kuu, staatus) values ("+;
	str(tnrekvId,9)+",60,0,0,date(2008,01,01),"+str(lnNumber,9)+",2008,0,1)"

lnError = SQLEXEC(gnHandle,lcString)
If lnError < 0
	Messagebox('Viga',0,'fnc_pv',10)
	set step on
	Return lnError
Endif

lcString = "select id from taotlus order by id desc limit 1"
lnError = SQLEXEC(gnHandle,lcString, 'tmpId')
If lnError < 0
	Messagebox('Viga',0,'fnc_pv',10)
	set step on
	Return lnError
Endif

lnTaotlusId = tmpId.id

 
 
* create taotlus1

* count rec. nr

select nlvko2008
count for üksus = tcKood  to lnKokku
lntehtud = 0
lcTunnus = ''
if !empty(tcTunnus)
	lcTunnus = tcTunnus
endif

scan for üksus = tcKood
	wait window 'create taotlus1 ..'+str(lntehtud,9)+'/'+str( lnKokku,9) nowait
	lcString = "insert into taotlus1 (parentid, kood1, kood2,kood5, tunnus , summa, markused,  muud, eelprojid, eelarveid) values ("+;
		str( lnTaotlusId,9)+",'"+alltrim(nlvko2008.tegevusala)+"','"+alltrim(nlvko2008.allikas)+"','"+;
		alltrim(str(nlvko2008.eelarve,8))+"','"+lcTunnus+"',"+str(nlvko2008.summa,12,2)+",'importeeritud','"+;
		ltrim(rtrim(nlvko2008.märkused))+"',0,0)"

	lnError = SQLEXEC(gnHandle,lcString)
	If lnError < 0
		Messagebox('Viga',0,'fnc_pv',10)
		set step on
		Return lnError
	Endif
	lntehtud = lntehtud +1
endscan



endfunc



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
lcString = "select id from library where rekvid = 20 and library = 'OSAKOND' and kood = '"+lcKood+"'"
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
			" Tooleping.osakondid, Tooleping.ametid, amet.kood as amet "+;
			" FROM palk_kaart INNER JOIN tooleping  ON  Palk_kaart.lepingid = Tooleping.id inner join library palk on palk.id = palk_kaart.libId "+;
			" inner join library amet on amet.id = tooleping.ametId "+;			
			" where tooleping.rekvid = 91 "

*and osakond.kood = '"+tcOsakond+"'"

			
					lnError = SQLEXEC(gnHandle,lcString,'sqlHKSPalgaKaart')
		If lnError < 0
			Messagebox('Viga',0,'fnc_palgaStruktuur',10)
			*set step on
			Return lnError
		Endif
*	ENDIF
	lcString = "select * from library where rekvid = "+str(tnRekvId)+" and library = 'PALK'"
		lnError = SQLEXEC(gnHandle,lcString,'sqlUusPalk')
		If lnError < 0
			Messagebox('Viga',0,'fnc_palgaStruktuur',10)
			*set step on
			Return lnError
		Endif
	lcString = "select * from library where rekvid = "+str(tnRekvid)+" and library = 'OSAKOND' and kood = '"+tcOsakond+"'"
		lnError = SQLEXEC(gnHandle,lcString,'sqlUusOsakond')
		If lnError < 0
			Messagebox('Viga',0,'fnc_palgaStruktuur',10)
			*set step on
			Return lnError
		Endif
	lcString = "select * from library where rekvid = "+str(tnrekvId)+" and library = 'AMET'"
		lnError = SQLEXEC(gnHandle,lcString,'sqlUusAmet')
		If lnError < 0
			Messagebox('Viga',0,'fnc_palgaStruktuur',10)
			*set step on
			Return lnError
		Endif

	lcString = "select * from tooleping where rekvid = "+str(tnRekvId)+" and osakondId = "+STR(sqlUusOsakond.id,9)
		lnError = SQLEXEC(gnHandle,lcString,'sqlUusTooleping')
		If lnError < 0
			Messagebox('Viga',0,'fnc_palgaStruktuur',10)
			*set step on
			Return lnError
		Endif

	
	Select Distinct  Id, parentid, lepingid, libid From sqlHKSPalgaKaart Into Cursor tmpKaardid

	lnRea = 0
	Scan
		lnrea = lnRea + 1
		Wait Window 'tmpKaardid ..'+Str(lnRea,9)+'/'+str(reccount('tmpKaardid')) Nowait

*!*			IF tmpKaardid.lepingid = 131934
*!*				SET STEP ON 
*!*			endif

		SELECT sqlHKSPalgaKaart
		LOCATE FOR id = tmpKaardid.id
		
		SELECT sqluusAmet
		LOCATE FOR alltrim(upper(kood)) = alltrim(upper(sqlHKSPalgaKaart.amet))

		SELECT sqlUuspalk
		LOCATE FOR upper(alltrim(kood)) = upper(alltrim(sqlHKSPalgaKaart.palk))
		
		SELECT sqluusTooleping
		LOCATE FOR ametid = sqlUusAmet.id AND parentid = tmpKaardid.parentid
*!*			Select cur_tooleping
*!*			Locate For vanaid = tmpKaardid.lepingid

*!*			Select  cur_palklib
*!*			Locate For vanaid = tmpKaardid.libid
		
		
		If !Eof('sqluusTooleping') And !Eof('sqlUuspalk')
			lcString = "select sp_kopeeri_palgakaart("+Str(tmpKaardid.Id,9)+","+Str(sqluusTooleping.id,9)+","+Str(sqluuspalk.id,9)+")"
			lnError = SQLEXEC(gnHandle,lcString,'tmpId')
			If lnError < 0
				Messagebox('Viga',0,'fnc_palgaKaart',10)
				set step on
				Return lnError
			Endif
			Insert Into cur_palga_kaart (vanaid, uutid, rekvid) Values (tmpKaardid.Id,tmpId.sp_kopeeri_palgakaart,tnRekvId)
			USE IN tmpId
		else
			if !used ('tmpValeKood')
				create cursor tmpValeKood (kood c(20))				
			endif
			insert into tmpValeKood (kood) values (sqlHKSPalgaKaart.palk)
			
		ENDIF
		

	ENDSCAN
	
	IF USED('tmpKaardid')
		USE IN tmpKaardid 
	ENDIF
	
	select tmpValeKood
	copy to tmpValeKood type XLS
	
*	USE IN tmpKaardid 
	
	lnreturn = Recno('cur_palga_kaart')
	Select cur_palga_kaart
*	Browse
	USE IN cur_palga_kaart
*	USE IN cur_tooleping
*	USE IN cur_amet
*	USE IN cur_palklib
		
	Return lnreturn

Endfunc



Function fnc_palgaStruktuur
	Lparameters tnRekvId

	Create Cursor cur_palklib (vanaid Int, uutid Int, rekvid Int)

	set step on
	lcString = "Select Distinct id as libid From library where rekvid = 68 and library = 'PALK'"
	LeRROR = SQLEXEC(gnHandle,lcString,'tmpPalkLib')

* import palgastruktuur
	Select tmpPalkLib
	Scan
		Wait Window 'import tmpPalkLib ..' + Str(Recno('tmpPalkLib'),9) Nowait
		lcString = "select sp_kopeeri_palkastruktuur(" + Str(tmpPalkLib.libid,9)+","+Str(tnRekvId,9)+")"
		lnError = SQLEXEC(gnHandle,lcString,'tmpId')
		If lnError < 0
			Messagebox('Viga',0,'fnc_palgaStruktuur',10)
			set step on
			*Return lnError
		else
			Insert Into cur_palklib (vanaid, uutid, rekvid) Values (tmpPalkLib.libid,tmpId.sp_kopeeri_palkastruktuur,tnRekvId)
			USE IN tmpId
		Endif
	ENDSCAN
	USE IN tmpPalkLib
	
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
			" where tooleping.rekvId = 91 "
		lnError = SQLEXEC(gnHandle,lcString,'sqlHKSToolepingud')
		If lnError < 0
			Messagebox('Viga',0,'fnc_tooleping',10)
			*set step on
			Return lnError
		Endif
		Wait Window 'sqlHKSToolepingud ... done kokku:'+ Str(Reccount('sqlHKSToolepingud'),6) Timeout 1
*	Endif

	lnCount = 0

	lcString = "select * from library where rekvid = " + str(tnRekvId)+"  and library = 'AMET' "
		lnError = SQLEXEC(gnHandle,lcString,'sqlamet')
		If lnError < 0
			Messagebox('Viga',0,'fnc_tooleping',10)
			*set step on
			Return lnError
		Endif

	Select sqlHKSToolepingud
	Scan 
*	FOR osakond = tcKood
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
			" where library.rekvid = 91 "

		lnError = SQLEXEC(gnHandle,lcString,'sqlHKSstruktuur')
		If lnError < 0
			Messagebox('Viga',0,'fnc_ameti_struktuur',10)
			*set step on
			Return lnError
		Endif
		Wait Window 'sqlHKSstruktuur ... done kokku:'+ Str(Reccount('sqlHKSstruktuur'),6) Timeout 1
	Endif

* otsime meie struktuuri Id
	IF USED('sqlYksus')
		Select sqlYksus
		Locate For kood = tcOsakonnaKood
		If !Found()
			*set step on
			Return .F.
		Endif
	endif
	
	
	
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
	Scan 
*	For osakondId = tnOsakondId
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

	lcString = "select id, kood, nimetus from library where rekvid = 62 and library = 'OSAKOND'"
	lnError = SQLEXEC(gnHandle,lcString,'sqlYksus')
	If lnError < 0
		Messagebox('Viga',0,'fnc_yksused',5)
		*set step on
		Return lnError
	Endif

	lcString = "select id, nimetus from rekv where parentid = 62 or id = 119"
	lnError = SQLEXEC(gnHandle,lcString,'sqlRekv')
	If lnError < 0
		Messagebox('Viga',0,'fnc_yksused',5)
		*set step on
		Return lnError
	Endif


Endfunc

