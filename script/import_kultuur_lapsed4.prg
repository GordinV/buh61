Local lError, lnSumma
Clear All

lnSumma = 0
gnhandle = SQLConnect('narvalvpg','vlad','654')
If gnhandle < 0
	Messagebox('Viga, uhendus')
	Return
Endif
lError = 0
* select lapsed, uksused
lcFile = 'c:\temp\paemuru_laps1.dbf'
Use (lcFile) In 0 Alias qrylp

*!*	SELECT ikood as isik, LTRIM(RTRIM(nimi))+' ' +LTRIM(RTRIM(perenimi)) as nimi,;
*!*		 LTRIM(RTRIM(nimiv))+' ' +LTRIM(RTRIM(perenimiv)) as nimi2, ikv, grupp, asutus;
*!*		 FROM qryLp WHERE !EMPTY(ikood) INTO CURSOR qryLapsed

SELECT DISTINCT asutus;
	 FROM qryLp WHERE !EMPTY(ikood) INTO CURSOR qryLapsed


*lcString = "select distinct isikukood1 as isikkood, isik1 as nimi, tunnus, rekvid from tulud2 inner join tulud1 on tulud1.id = tulud2.parentid "
*!*	lError = SQLEXEC(gnhandle, lcString,'qryLapsed')
*!*	If lError < 0
*!*		Set Step On
*!*	Else
lnCount = 0
lError =SQLEXEC(gnhandle,'begin work')
If lError < 1
	Set Step On
Endif

Select qrylapsed
Scan 
		Wait Window Str(Recno('qrylapsed'),4)+'/'+Str(Reccount('qrylapsed'),4)+Ltrim(Rtrim(asutus )) Nowait

		lcTunnus = LEFT(qrylapsed.asutus,20)
		* check tunnus
		lcString = "select id from library where library = 'TUNNUS' AND REKVID = 17 AND KOOD = '" + LTRIM(RTRIM(lcTunnus))+ "'"
		lnError = SQLEXEC(gnhandle, lcString, 'qryTunId')
		IF RECCOUNT('qryTunId') < 1
				WAIT WINDOW lcTunnus + 'lisame..' nowait
				lcString = "insert into library (rekvid, kood, nimetus, library) values (17,'"+;
				lcTunnus+"','"+lcTunnus+"','TUNNUS')"
				lnError = SQLEXEC(gnhandle, lcString)
				IF lnError < 0 
					exit
				ENDIF
				
		endif
*!*	* check isik
*!*		lcString = "select id from vanemtasu1 where isikkood = '"+Ltrim(Rtrim((qrylapsed.isik)))+"'"
*!*		lError = SQLEXEC(gnhandle, lcString,'qryLapsId')
*!*		If lError > 0
*!*			If Reccount('qrylapsId') < 1
*!*	* uus laps
*!*				lcString = "insert into vanemtasu1 (isikkood, nimi, vanemkood, vanemnimi ) values ('"+;
*!*					LTRIM(Rtrim(qrylapsed.isik))+"','"+Ltrim(Rtrim(qrylapsed.nimi))+"','"+;
*!*					ltrim(RTRIM(qrylapsed.ikv))+"','"+LTRIM(RTRIM(qryLapsed.nimi2))+"')"

*!*				lError = SQLEXEC(gnhandle, lcString)


*!*				If lError > 0
*!*					lcString = "select id from vanemtasu1 where isikkood = '"+Ltrim(Rtrim(qrylapsed.isik))+"'"
*!*					lError = SQLEXEC(gnhandle, lcString,'qryLapsId')


*!*	* uksus
*!*	*	  id serial NOT NULL,  isikid int4 NOT NULL,  tunnus varchar(20) DEFAULT space(1),  rekvid int4 NOT NULL,  algkpv date NOT NULL DEFAULT date(),  loppkpv date NOT NULL DEFAULT date("year"(date()), "month"(date()), "day"(date())),  jaak numeric(14,4) DEFAULT 0,  muud text DEFAULT space(1),  grupp varchar(20) NOT NULL DEFAULT space(1),  number varchar(20) NOT NULL DEFAULT space(1),
*!*				Endif
*!*			Endif

*!*			If lError > 0 And qryLapsId.Id > 0
*!*				lcString = "select id from vanemtasu2 where isikid = "+Str(qryLapsId.Id)+;
*!*					" and rekvid = 17 and tunnus = '"+Ltrim(Rtrim(lcTunnus)) +"'"


*!*				lError = SQLEXEC(gnhandle, lcString,'qryUksusId')
*!*				If Reccount('qryUksusId') < 1
*!*					lcString = "insert into vanemtasu2 (isikid , tunnus ,  rekvid ,  algkpv ,  loppkpv, grupp) values ("+;
*!*						STR(qryLapsId.Id,9)+",'"+Ltrim(Rtrim(lcTunnus))+"',17 ,DATE(2006,01,01),DATE(2006,12,31),'"+;
*!*								LEFT(Alltrim((qrylapsed.grupp)),20)+"')"
*!*					lError = SQLEXEC(gnhandle, lcString)
*!*					lnCount = lnCount + 1
*!*				Endif
*!*			Else
*!*				Set Step On
*!*				lError = -1

*!*			Endif


*!*		Endif

*!*	*!*			If lError > 0

*!*	* list of arv. lapse jaoks

*!*	*!*				lcString = " select tulud1.kpv, tulud1.liik, tulud1.dokpropId,   tulud2.isikukood1 as isikkood, "+;
*!*	*!*					" tulud2.isikukood2 as maksjakood,  tulud2.isik2 as maksjanimi,  tulud2.summa ,  tulud2.konto ,"+;
*!*	*!*					" tulud2.tunnus ,  tulud2.kood1 ,  kood2 ,  kood3 ,  kood4 ,  kood5, tulud1.userid "+;
*!*	*!*					" from tulud1 inner join tulud2 on tulud1.id = tulud2.parentid "+;
*!*	*!*					" where rekvid = 13 and tulud2.isikukood1 = '"+Ltrim(Rtrim(qryLapsed.isikkood))+"' and tulud2.tunnus = '"+;
*!*	*!*					LTRIM(RTRIM(qrylapsed.tunnus))+"'"

*!*	*!*				lError =SQLEXEC(gnhandle,lcString, 'qryDok')

*!*	*!*				If lError > 0
*!*	*!*					Select qryDok
*!*	*!*					Scan
*!*	*!*						lcString = "insert into vanemtasu3 (rekvid, userid ,  opt ,  kpv ,  tunnus, muud, dokpropId) values ("+;
*!*	*!*							" 13,"+ Str(qryDok.Userid,9)+","+Str(qryDok.LIIK,1)+", DATE(2004,"+Str(Month(qryDok.kpv),2)+","+Str(Day(qryDok.kpv),2)+"),'"+;
*!*	*!*							Ltrim(Rtrim(qryDok.tunnus))+"','Importeritud vana andmed',"+Str(qryDok.dokpropId,9)+")"

*!*	*!*						lError =SQLEXEC(gnhandle,lcString)
*!*	*!*						If lError > 0

*!*	*!*							lcString = " SELECT id FROM vanemtasu3 ORDER BY id desc limit 1"
*!*	*!*							lError =SQLEXEC(gnhandle,lcString,'qryDokId')
*!*	*!*							If lError > 0 And Reccount('qryDokid') > 0

*!*	*!*								If qryDok.konto = '323330'
*!*	*!*									lcNomid = '859'
*!*	*!*								Else
*!*	*!*									lcNomid = '858'
*!*	*!*								Endif


*!*	*!*								lcString = " insert into vanemtasu4 (parentid,isikid , maksjakood , maksjanimi ,  nomid ,  kogus ,  hind ,  summa, konto, kood1, kood2, kood3, kood4, kood5 ) values ("+;
*!*	*!*									STR(qryDokId.Id,9)+","+Str(qryLapsid.Id,9)+",'"+Ltrim(Rtrim(qryDok.maksjakood))+"','"+;
*!*	*!*									LTRIM(Rtrim(qryDok.maksjanimi))+"',"+lcNomid+",1,"+Str(qryDok.Summa,12,2)+","+Str(qryDok.Summa,12,2)+",'"+;
*!*	*!*									qryDok.konto +"','"+qryDok.kood1+"','"+qryDok.kood2+"','"+qryDok.kood3+"','"+qryDok.kood4+"','"+qryDok.kood5+"')"

*!*	*!*								lError =SQLEXEC(gnhandle,lcString)
*!*	*!*
*!*	*!*							Else
*!*	*!*								lError = -1
*!*	*!*								Exit
*!*	*!*							Endif

*!*	*!*						Endif
*!*	*!*						lnSumma = lnSumma + qryDok.Summa
*!*	*!*					Endscan
*!*	*!*				Endif
*!*	*!*			Endif
	If lError < 1
		Set Step On
		Exit
	Endif
Endscan
If lError > 0
	=SQLEXEC(gnhandle,'commit work')
	=Messagebox('Ok, kokku'+Str(lnCount,12) + '/' + Str(Reccount('qryLapsed')) )
Else
	=SQLEXEC(gnhandle,'rollback work')
	=Messagebox('Viga')
Endif

*Endif


* select dok kassa/fakt

=SQLDISCONNECT(gnhandle)
