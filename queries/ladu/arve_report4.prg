Parameter cWhere
If Isdigit(Alltrim(cWhere))
	cWhere = Val(Alltrim(cWhere))
Endif
tnId = cWhere
*!*	cQuery = 'print_arv1'
*!*	oDb.Use(cQuery,'arve_report1')
WITH oDb
	.use('v_arv','tmpArv')
	.use('v_arvread','tmpArvRead')
	.use('queryarvtasu','ArvTasu_report1') 	
ENDWITH

SELECT comAsutusRemote
LOCATE FOR id = v_arv.asutusId

CREATE CURSOR arve_report1 (ID int, number c(20), kpv d, lisa c(120), tahtaeg d, asutusid int,  ;
	kood c(20), uhik c(20), doklausid int, nomid int, hind n(18,4), kogus n(18,4), soodus n(18,4),;
	kbm n(18,4), summa n(18,4), arvkbmta n(18,4), arvkbm n(18,4), kokku n(18,4), km c(20), muud m,;
	reamuud m, nomnimi c(254), 	regkood c(120), asutus c(254), aadress m,  tel c(120), faks c(120),;
	email c(254), reamark m, konto c(20), valuuta c(20), kuurs n(18,4), jaak n(18,4), tasu1 n(18,4),;
	tasukpv1 d, tasudok1 c(20), tasuliik1 c(20), tasu2 n(18,4),;
	tasukpv2 d, tasudok2 c(20), tasuliik2 c(20), tasu3 n(18,4),;
	tasukpv3 d, tasudok3 c(20), tasuliik3 c(20),tasu4 n(18,4),;
	tasukpv4 d, tasudok4 c(20), tasuliik4 c(20), tasu5 n(18,4),;
	tasukpv5 d, tasudok5 c(20), tasuliik5 c(20) )

SELECT tmpArvRead
scan

	SELECT arve_report1
	APPEND BLANK

replace id WITH tmpArv.id,;
	number WITH tmpArv.number,;
	kpv WITH tmpArv.kpv,;
	lisa WITH tmpArv.lisa,;
	tahtaeg WITH tmpArv.tahtaeg,;
	asutusId WITH tmparv.asutusId,;
	kood WITH tmpArvread.kood,;
	uhik WITH tmpArvRead.uhik,;
	nomid WITH tmpArvRead.nomId,;
	hind WITH tmpArvRead.hind,;
	kogus WITH tmpArvRead.kogus,;
	soodus WITH tmpArvRead.soodus,;
	kbm WITH tmpArvRead.kbm,;
	summa WITH tmpArvRead.summa,;
	reamuud WITH tmpArvRead.muud,;
	nomnimi WITH tmpArvRead.nimetus,;
	arvkbmta WITH tmpArv.kbmta,;
	kokku WITH tmpArv.summa,;
	valuuta WITH tmpArv.valuuta,;
	kuurs WITH tmpArv.kuurs,;
	muud WITH tmpArv.muud,;
	regkood WITH comAsutusRemote.regkood,;
	asutus WITH comAsutusRemote.nimetus,;
	aadress WITH comAsutusRemote.aadress,;
	tel WITH comAsutusRemote.tel,;
	faks WITH comAsutusRemote.faks,;
	email WITH comAsutusRemote.email,;
	reamark WITH tmpArvRead.muud,;
	jaak WITH tmpArv.jaak  IN arve_report1


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
		otherwise
			lcKbm =  'Vaba'
	Endcase

	SELECT arve_report1
	Replace km With lcKbm In arve_report1

ENDSCAN
SELECT queryarvtasu
lnrea = 0
SCAN
	lnrea = lnRea + 1
	DO CASE 
		CASE lnrea = 1
			UPDATE arve_report1 SET tasu1 =  queryarvtasu.summa,;
				tasukpv1 = queryarvtasu.kpv,;
				tasudok1 = queryarvtasu.dok,;
				tasuliik1 = queryarvtasu.liik 

		CASE lnrea = 2
			UPDATE arve_report1 SET tasu2 =  queryarvtasu.summa,;
				tasukpv2 = queryarvtasu.kpv,;
				tasudok2 = queryarvtasu.dok,;
				tasuliik2 = queryarvtasu.liik 

		CASE lnrea = 3
			UPDATE arve_report1 SET tasu3 =  queryarvtasu.summa,;
				tasukpv3 = queryarvtasu.kpv,;
				tasudok3 = queryarvtasu.dok,;
				tasuliik3 = queryarvtasu.liik 

		CASE lnrea = 4
			UPDATE arve_report1 SET tasu4 =  queryarvtasu.summa,;
				tasukpv4 = queryarvtasu.kpv,;
				tasudok4 = queryarvtasu.dok,;
				tasuliik4 = queryarvtasu.liik 

		CASE lnrea = 5
			UPDATE arve_report1 SET tasu5 =  queryarvtasu.summa,;
				tasukpv5 = queryarvtasu.kpv,;
				tasudok5 = queryarvtasu.dok,;
				tasuliik5 = queryarvtasu.liik 
	ENDCASE
	

ENDSCAN


&&use (cQuery) in 0 alias arve_report1
Select arve_report1
INDEX ON KM TAG Km 
SET ORDER TO KM
GO top