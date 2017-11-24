gnHandle = SQLCONNECT('spordikeskus')
IF gnHandle < 0
	MESSAGEBOX('Viga, uhendus')
	return
ENDIF


IF !USED('tmpSport')
	USE tmpSport IN 0
ENDIF
CREATE CURSOR tmpLog (log m)
APPEND BLANK
*SET STEP ON 
lnresult = SQLEXEC(gnhandle,'begin work')
SELECT tmpSport
SCAN
		Wait Window Str(Recno('tmpsport'))+ '/'+Str(Reccount('tmpsport')) Nowait
		* journal
		nAsutusid = get_asutus()
		
		lcString = "insert into journal (rekvid,userid, kpv, asutusid, selg,dok,  muud) values (1,1,"+;
			 "DATE("+STR(YEAR(tmpSport.kpv),4)+","+STR(MONTH(tmpsport.kpv),2)+","+STR(DAY(tmpSport.kpv),2)+"),"+STR(nAsutusId,9)+",'"+;
			LTRIM(rtrim(tmpSport.selg))+"','"+tmpSport.dok+"','import')"

		lnresult = SQLEXEC(gnhandle,lcString)
		IF lnresult < 0
			MESSAGEBOX('Viga')
			SET STEP ON
			exit
		ENDIF

		lnparentid = 0

		lcString = "select id from journal order by id desc limit 1"

		lnresult = SQLEXEC(gnhandle,lcString,'tmpId')
		IF lnresult < 0
			MESSAGEBOX('Viga')
			SET STEP ON
			exit
		ENDIF

		lnParentid = tmpId.id

		lcDb = fnc_konto(fnc_remove_blank(ALLTRIM(tmpSport.db)),fnc_remove_blank(ALLTRIM(tmpsport.kr)),'DB')
		lcKr = fnc_konto(fnc_remove_blank(ALLTRIM(tmpSport.db)),fnc_remove_blank(ALLTRIM(tmpsport.kr)),'KR')
		lcTpD = fnc_tp(lcDb)
		lcTpK = fnc_tp(lcKr)
		lcArt = fnc_kulud(lcdb,lckr)
		lcString = " insert into journal1 (parentid,summa,deebet,lisa_d,kreedit,lisa_k, kood1,kood5) values ("+;
		  STR(lnParentId,9)+","+STR(tmpSport.summa,12,2)+",'"+lcDb+"','"+fnc_tp(lcDb)+"','"+;
		  lckr+"','"+fnc_tp(lckr)+"','08102','"+fnc_kulud(lcdb,lckr)+"')";

		lnresult = SQLEXEC(gnhandle,lcString)

		IF lnresult < 0
			MESSAGEBOX('Viga')
			SET STEP ON
			exit
		ENDIF
		
		SELECT tmpLog
		replace tmpLog.log WITH tmpSport.db + '-'+lcDb + '-'+lctpD+'-'+ tmpSport.kr + '-' + lcKr + '-'+ lcTpK+'-'+lcArt+CHR(13) ADDITIVE

ENDSCAN

SELECT tmpLog
MODIFY MEMO log 

If lnResult > 0
	lnAnswer = MESSAGEBOX('kas salvesta',4+16,'Import')
	IF lnAnswer = 6 
		=SQLEXEC(gnhandle,'commit work')
		=Messagebox('Ok' )
	ELSE
		=SQLEXEC(gnhandle,'rollback work')
	ENDIF
	
Else
	=SQLEXEC(gnhandle,'rollback work')
	=Messagebox('Viga')
ENDIF

= SQLDISCONNECT(gnHandle)

*!*	Set Step On
*!*	Select tmpSport
*!*	Scan
*!*		Wait Window get_asutus() Nowait
*!*	Endscan



Function get_asutus
	Local lnAsutus
* otsime asutus nimi
	lnrea = 0
	lnAsutusRea = 0
	lnAsutusid = 0
	For i = 1 To Memlines(tmpSport.selg)
		Do Case
			Case 'AS' $ MLINE(tmpSport.selg,i)
				lnrea = i
				lcTp = '800599'
			Case 'OU' $ MLINE(tmpSport.selg,i)
				lnrea = i
				lcTp = '800599'
			Case 'FIE' $ MLINE(tmpSport.selg,i)
				lnrea = i
				lcTp = '800699'
			Case 'MTU' $  MLINE(tmpSport.selg,i)
				lnrea = i
				lcTp = '800399'
			Case 'Nadezda' $ MLINE(tmpSport.selg,i)
				lnrea = i
				lcTp = '800699'
			Case 'Natalja' $ MLINE(tmpSport.selg,i)
				lnrea = i
				lcTp = '800699'
			Case 'Vladimir' $ MLINE(tmpSport.selg,i)
				lnrea = i
				lcTp = '800699'
			Case 'Tatjana' $ MLINE(tmpSport.selg,i)
				lnrea = i
				lcTp = '800699'
			Case 'Raissa' $ MLINE(tmpSport.selg,i)
				lnrea = i
				lcTp = '800699'
			Case 'Ljudmila' $ MLINE(tmpSport.selg,i)
				lnrea = i
				lcTp = '800699'
			Case 'Jelena' $ MLINE(tmpSport.selg,i)
				lnrea = i
				lcTp = '800699'
			Case 'Igor' $ MLINE(tmpSport.selg,i)
				lnrea = i
				lcTp = '800699'
			Case 'Galina' $ MLINE(tmpSport.selg,i)
				lnrea = i
				lcTp = '800699'
			Case 'Andrei' $ MLINE(tmpSport.selg,i)
				lnrea = i
				lcTp = '800699'
			Case 'Juri' $ MLINE(tmpSport.selg,i)
				lnrea = i
				lcTp = '800699'
		Endcase
		If lnrea > 0
			lnAsutusRea = lnrea
		Endif

	Endfor

	If lnAsutusRea > 0
		lcAsutus = Mline(tmpSport.selg,lnAsutusRea)
*		Return lcAsutus

* look in asutuse register

		lcString = "select id from asutus where UPPER(nimetus) like '%" + lcAsutus +"%'" 
		lnresult = SQLEXEC(gnhandle,lcString,'tmpAsutus')	
		IF lnresult > 0 AND USED('tmpAsutus') AND RECCOUNT('tmpAsutus') > 0
				lnAsutusId = tmpAsutus.id
		ELSE
			* asutus puudub
			lcString = " insert into asutus ( rekvid, nimetus, tp) values (1,'"+;
				lcAsutus +"','"+lcTp+"')"
			lnresult = SQLEXEC(gnhandle,lcString)	
			lcString = "select id from asutus where UPPER(nimetus) like '%" + lcAsutus +"%'" 
			lnresult = SQLEXEC(gnhandle,lcString,'tmpAsutus')	
			lnAsutusId = tmpAsutus.id
		ENDIF
		
	ENDIF
	
	Return lnAsutusiD
Endfunc




Function fnc_konto
	Lparameters tcDB, tcKr, tcOpt
	Local lcKonto
	lcKonto =  IIF(tcOpt = 'DB',tcDb,tcKr)
	Do Case
		Case !Isdigit(tcDB) AND tcOPT = 'DB'
			lcKonto = '999999'
		Case !Isdigit(tcKR) AND tcOPT = 'KR'
			lcKonto = '999999'
		CASE tcDB = '26'
			IF tcKR = '60.1' 
				lcKonto = IIF(tcOPT = 'DB','550000','201000')
			ENDIF			
			IF  tcKR = '51' 
				lcKonto = IIF(tcOPT = 'DB','550012','100100')
			ENDIF
			IF tcKR = '70.1' 
				lcKonto = IIF(tcOPT = 'DB','658910','202000')
			ENDIF
			IF tcKR = '71' 
				lcKonto = IIF(tcOPT = 'DB','550013','103920')
			ENDIF
			IF tcKR = '67.1' 
				lcKonto = IIF(tcOPT = 'DB','601510','202001')
			ENDIF
			IF tcKR = '67.6' 
				lcKonto = IIF(tcOPT = 'DB','601530','202003')
			ENDIF
			IF tcKR = '02.1' 
				lcKonto = IIF(tcOPT = 'DB','611000','155110')
			ENDIF
			IF tcKR = '02.4' 
				lcKonto = IIF(tcOPT = 'DB','611009','155119')
			ENDIF
			IF tcKR = '03.3' 
				lcKonto = IIF(tcOPT = 'DB','613060','156010')
			ENDIF
			IF tcKR = '68.13' 
				lcKonto = IIF(tcOPT = 'DB','601510','203010')
			ENDIF
			IF tcKR = '68.15' 
				lcKonto = IIF(tcOPT = 'DB','650900','203095')
			ENDIF
			IF tcKR = '68.12' 
				lcKonto = IIF(tcOPT = 'DB','650900','203095')
			ENDIF
			IF tcKR = '68.16' 
				lcKonto = IIF(tcOPT = 'DB','650900','203095')
			ENDIF
							
		CASE tcDB = '48 .2' AND tcKR = '80.1'
			lcKonto = IIF(tcOpt = 'DB','100100','388890')
		CASE tcOPT = 'DB' AND LEFT(tcDB,2) = '50'
			lcKonto = '100000'
		CASE tcOPT = 'DB' AND LEFT(tcDB,2) = '51'
			lcKonto = '100100'
		CASE tcOPT = 'KR' AND LEFT(tcKR,2) = '51'
			lcKonto = '100100'
		CASE tcOPT = 'DB' AND LEFT(tcDB,2) = '60'
			lcKonto = '201000'
		CASE tcOPT = 'DB' AND tcDB = '62.1'
			lcKonto = '103000'
		CASE tcOPT = 'DB' AND tcDB = '62.2'
			lcKonto = '103000'
		CASE tcOPT = 'DB' AND tcDB = '70.1'
			lcKonto = '202000'
		CASE tcOPT = 'DB' AND tcDB = '70.5'
			lcKonto = '202000'
		CASE tcOPT = 'DB' AND tcDB = '92.3'
			lcKonto = '208120'
		CASE tcOPT = 'DB' AND tcDB = '80.1'
			lcKonto = '322200'
		CASE tcOPT = 'KR' AND tcKR = '71'
			lcKonto = '103920'
		CASE tcOPT = 'KR' AND tcKR = '46.02'
			lcKonto = '103000'
		CASE tcOPT = 'KR' AND tcKR = '48.02'
			lcKonto = '388890'
		CASE tcOPT = 'KR' AND tcKR = '50.1'
			lcKonto = '100000'
		CASE tcOPT = 'KR' AND tcKR = '60.1'
			lcKonto = '201000'
		CASE tcOPT = 'KR' AND tcKR = '62.1'
			lcKonto = '103000'
		CASE tcKR = '68.12' AND tcDb = '67.2'
			lcKonto = IIF(tcopt = 'DB','203020','202002')
		CASE tcKR = '68.13' AND tcDb = '67.1'
			lcKonto = IIF(tcopt = 'DB','203010','202001')
		CASE tcKR = '68.15' AND tcDb = '67.5'
			lcKonto = IIF(tcopt = 'DB','203030','202003')
		CASE tcKR = '68.15' AND tcDb = '67.6'
			lcKonto = IIF(tcopt = 'DB','203030','202003')
		CASE tcKR = '68.16' AND tcDb = '67.7'
			lcKonto = IIF(tcopt = 'DB','203035','202004')
		CASE tcKR = '48.2' AND tcOpt =  'KR'
			lcKonto = '388890'
		CASE tcKR = '80.1' AND tcDb = '80.2'
			lcKonto = IIF(tcopt = 'DB','290030','291000')
		CASE tcDb = '41.2' AND tcOpt = 'DB'
			lcKonto = '201000'
		CASE tcDB = '71' AND LEFT(tcKR,2) = '50'
			lcKonto = IIF(tcopt = 'DB','103920','100000')
		CASE tcDB = '80.1' AND tcKR = '38.2'
			lcKonto = IIF(tcopt = 'DB','650900','203200')
		CASE tcDB = '38.2' AND tcOpt = 'DB' 
			lcKonto = '650900'
		CASE tcKR = '67.2' AND tcDb = '70.1'
			lcKonto = IIF(tcopt = 'DB','202000','202002')
		CASE tcKR = '67.5' AND tcDb = '70.1'
			lcKonto = IIF(tcopt = 'DB','202000','202003')
		CASE tcKR = '67.7' AND tcDb = '70.1'
			lcKonto = IIF(tcopt = 'DB','202000','202004')
		CASE tcdb = '68.13' AND tckR = '51'
			lcKonto = IIF(tcopt = 'DB','203010','100100')
		CASE tcdb = '46.02' AND tckR = '80.1'
			lcKonto = IIF(tcopt = 'DB','103000','322200')
		CASE tcKr = '46.02' AND tckR = '80.1'
			lcKonto = IIF(tcopt = 'DB','103000','322200')

	ENDCASE
	
	IF ALLTRIM(lcKonto) = '02.04.20' OR ALLTRIM(lcKonto) = '02.01.20' OR ALLTRIM(lcKonto) = '03.03.20'
		lcKOnto = '999999'
	ENDIF
	
	
	Return lcKonto
Endfunc

FUNCTION fnc_remove_blank
LPARAMETERS tcStr
LOCAL lcStr
lcStr = ''
lcStr = ALLTRIM(tcStr)
IF AT(' ',lcStr) > 0
	lcStr = STUFF(lcStr,AT(' ',lcStr),1,'')
ENDIF

RETURN lcStr
ENDFUNC



Function fnc_tp
	Lparameters tcKonto
	Local lcTp
	lcTp = '800599'

	Do Case
		Case tcKonto = '100000'
			lcTp = ''
		Case tcKonto = '100100'
			lcTp = '800401'
		Case LEFT(tcKonto,3) = '202'
			lcTp = '800699'
		Case LEFT(tcKonto,3) = '203'
			lcTp = '014002'
	Endcase
	Return lcTp
Endfunc

Function fnc_tt
	Lparameters tcKonto
	Local lcTt
	lcTt = ''
	Return lcTt
Endfunc

Function fnc_kulud
	Lparameters tcKontoDb, tcKontoKr
	Local lcArt
	lcArt = ''
	Do Case
		Case Left(tcKontoDb,1) = '5' Or Left(tcKontoDb,1) = '6'
			lcArt = Left(tcKontoDb,4)
		Case Left(tcKontoKr,1) = '3'
			lcArt = Left(tcKontoKr,4)
		Case Left(tcKontoKr,3) = '103'
			lcArt = '3222'
	Endcase
	IF LEFT(lcArt,3) = '601'
		lcArt = '601'
	ENDIF
	
	Return lcArt
Endfunc

Function import_first_data

	Local lcString
	lcString = ''
	Create Table tmpSport (kpv d, dok c(10), selg m, db c(20), kr c(20), Summa N(12,2))

	Select sport1
	Scan
		Wait Window Str(Recno('sport1'))+ '/'+Str(Reccount('sport1')) Nowait
		Select tmpSport
		If !Empty(sport1.a)
			If !Empty(sport1.F)
				Append Blank
				Replace kpv With str_to_date(sport1.a),;
					dok With Ltrim(Rtrim(sport1.b)),;
					selg With Ltrim(Rtrim(sport1.c)),;
					db With Ltrim(Rtrim(sport1.d)),;
					kr With Ltrim(Rtrim(sport1.e)),;
					summa With Iif(Vartype(sport1.F)= 'C',Val(Alltrim(sport1.F)),sport1.F) In tmpSport
				lcString = Ltrim(Rtrim(sport1.c))
			Endif

		Else
			lcString = lcString + Chr(13)+ Ltrim(Rtrim(sport1.c))
			Replace selg With lcString In tmpSport
		Endif

	Endscan

	Select tmpSport
	Browse
	End Funct





Function str_to_date
	Lparameters tcKpv
	Local ldKpv
	ldKpv = {}
	If !Empty(tcKpv)
		ldKpv = Date(Val(Substr(tcKpv,7,4)),Val(Substr(tcKpv,4,2)),Val(Substr(tcKpv,1,2)))
	Endif

	Return ldKpv
