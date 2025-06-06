Parameter cWhere
If Isdigit(Alltrim(cWhere))
	cWhere = Val(Alltrim(cWhere))
ENDIF


tnId = cWhere
cQuery = 'print_arv1'
WITH odb
	.Use(cQuery,'arve_report1')

	Create Cursor arve_lausend (Id Int, lausend m)
	Insert Into arve_lausend (Id) Values (arve_report1.JOURNALID)
	tnId =arve_report1.JOURNALID
	tnAasta = Year (arve_report1.kpv)
	.Use ('QRYJOURNALNUMBER')
	If Reccount ('QRYJOURNALNUMBER') > 0
		tnId = QRYJOURNALNUMBER.JOURNALID
		.Use ('v_journal1','qryJournal1')
		Select qryJournal1
		Scan
			lcString =  'D '+Ltrim(Rtrim(qryJournal1.deebet))+Space(1)+;
				'K '+Ltrim(Rtrim(qryJournal1.kreedit)) + Space(1)+;
				alltrim(Str (qryJournal1.Summa,12,2)) + Chr(13)
			Replace arve_lausend.lausend With lcString Additive In arve_lausend
		Endscan

	Endif
	If Used ('QRYJOURNALNUMBER')
		Use In QRYJOURNALNUMBER
	Endif

ENDWITH

SELECT arve_report1
Select comAsutusRemote
*!*	If Tag() <> 'ID'
*!*		Set Order To Id
*!*	Endif
LOCATE FOR id =  arve_report1.asutusId


If Found()
	lnJaak = 0
	IF !EMPTY(arve_report1.konto)
		lnJaak = analise_formula('ASD('+Ltrim(Rtrim(arve_report1.konto))+','+Alltrim(Str(arve_report1.asutusId))+')', arve_report1.kpv, 'CursorAlgSaldo')
	ENDIF
	
	Update arve_report1 Set asutus = Rtrim(Ltrim(comAsutusRemote.nimetus))+Space(1)+Trim(comAsutusRemote.omvorm), jaak = lnJaak

Endif

Select arve_report1
Scan
	lnrecno = RECNO('arve_report1')
	Select comNomRemote
*!*		If Tag() <> 'ID'
*!*			Set Order To Id
*!*		Endif
	LOCATE FOR id = arve_report1.nomid
	lcKbm = ''

	Do Case
		Case comNomRemote.doklausid = 0
			lcKbm =  '18%'
		Case comNomRemote.doklausid = 1
			lcKbm =  '0%'
		Case comNomRemote.doklausid = 2
			lcKbm =  '5%'
		Case comNomRemote.doklausid = 4
			lcKbm =  '9%'
		Case comNomRemote.doklausid = 5
			lcKbm =  '20%'
		Case comNomRemote.doklausid = 6
			lcKbm =  '22%'
		Case comNomRemote.doklausid = 7
			lcKbm =  '24%'
		Case comNomRemote.doklausid = 8
			lcKbm =  '13%'
		otherwise
			lcKbm =  'Vaba'
	Endcase
	SELECT arve_report1
	Replace km With lcKbm In arve_report1
	GO lnRecno
Endscan

lcPeriod = ''
DIMENSION aKuu(12)

aKuu(1) = 'Jaanuar'
aKuu(2) = 'Veebruar'
aKuu(3) = 'Marts'
aKuu(4) = 'Aprill'
aKuu(5) = 'Mai'
aKuu(6) = 'Juuni'
aKuu(7) = 'Juuli'
aKuu(8) = 'August'
aKuu(9) = 'September'
aKuu(10) = 'Oktoober'
aKuu(11) = 'November'
aKuu(12) = 'Detsember'


CREATE CURSOR curEestiKuu (id int, kuu c(40))
FOR i = 1 TO 12
	INSERT INTO curEestiKuu (id, kuu)  VALUES (i,aKuu(i))
ENDFOR
aKuu = null

SELECT arve_report1
GO top

SELECT curEestiKuu 
LOCATE FOR id =  MONTH(arve_report1.kpv)

lcPeriod = ALLTRIM(curEestiKuu.kuu)+' ' + STR(YEAR(arve_report1.kpv),4)
USE IN curEestiKuu
UPDATE arve_report1 SET arvperiod = lcPeriod 

&&use (cQuery) in 0 alias arve_report1
Select arve_report1
INDEX ON KM TAG Km 
SET ORDER TO KM

