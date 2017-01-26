Parameter cWhere
If Isdigit(Alltrim(cWhere))
	cWhere = Val(Alltrim(cWhere))
ENDIF
LOCAL lnJaak
lnJaak = 0
tnId = cWhere
If !Used('v_avans1')
	With odb
		.Use('v_avans1')
		.Use('v_avans2')
	Endwith
Endif
tnid = v_avans1.journalid
odb.use('v_journal1','qryJournal1')


SELECT comAsutusremote
LOCATE FOR id = v_avans1.asutusId
IF (!USED('v_dokprop') OR v_dokprop.id <> v_avans1.dokpropid) AND v_avans1.dokpropid > 0
	tnId = v_avans1.dokpropid
	odb.use ('v_dokprop')
endif
*!*	IF USED('v_dokprop') AND !EMPTY(v_dokprop.konto)
*!*		lnJaak  = analise_formula('ASD('+LTRIM(RTRIM(v_dokprop.konto))+','+ALLTRIM(STR(v_avans1.Asutusid))+')', v_avans1.kpv)
*!*	endif

SELECT v_avans2
SUM summa TO lnSumma
CREATE CURSOR avans_report1 (number c(20) DEFAULT v_avans1.number, kpv d default v_avans1.kpv, kokku y DEFAULT lnSumma,; 
	selg m DEFAULT v_avans1.selg , isik c(254) DEFAULT comAsutusRemote.nimetus,;
	nimetus c(254), muud m, summa y, konto c(20), tunnus c(20), kood1 c(20),;
		kood2 c(20), kood3 c(20), kood5 c(20), jaak y DEFAULT v_avans1.Jaak,;
		lausend int DEFAULT v_avans1.lausend, valuuta c(20), kuurs n(14,4))


CREATE CURSOR laus (laus m)
APPEND blank

SELECT qryJournal1
lcString = ''
SCAN
	lcString = lcString + 'D '+LTRIM(RTRIM(qryJournal1.deebet))+ 'K '+LTRIM(RTRIM(qryJournal1.kreedit)) +' '+qryJournal1.valuuta+' '+STR(qryJournal1.summa,12,2)+CHR(13)
endscan
USE IN qryJournal1
		
replace laus WITH lcString IN laus

INSERT INTO avans_report1 (nimetus, muud, summa, konto, tunnus, kood1, kood2, kood3, kood5, valuuta, kuurs );
SELECT nimetus, muud, summa, konto, tunnus, kood1, kood2, kood3, kood5, valuuta, kuurs FROM v_avans2

SELECT avans_report1
IF RECCOUNT()< 1
	APPEND blank
endif