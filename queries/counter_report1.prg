Parameter cWhere
If isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
	tnId = cWhere
Endif
If vartype(odb) <> 'O'
	Set classlib to classes\classlib
	odb = createobject('db')
Endif
Create CURSOR counter_report1 (id int, asutus c(254) default comAsutusremote.nimetus,;
	regkood c(20) default comAsutusremote.regkood , aadress c(254) default comAsutusremote.aadress,;
	number c(20) default qryleping1.number, kpv d default qryleping1.kpv ,;
	selgitus m default qryleping1.selgitus, nimetus c(120) default comNomRemote.nimetus,;
	kood c(20) default comNomRemote.kood, kpv1 d default qryleping3.kpv, ;
	algkogus n(12,3) default qryleping3.algkogus , loppkogus n(12,3) default qryleping3.loppkogus, ;
	kogus n(12,3) default qryleping3.loppkogus - qryleping3.algkogus,;
	uhik c(20)  default comNomRemote.uhik, hind y default qryleping2.hind )
With odb
	.use ('v_leping3','qryleping3')
	tnId = qryleping3.parentid
	.use ('v_leping1','qryleping1')
	.use ('v_leping2','qryleping2')
Endwith
Select comAsutusremote
If tag() <> 'ID'
	Set order to id
Endif
Seek qryLeping1.asutusId
select qryLeping2
locate for id = qryleping3.parentid
select comNomRemote
If tag() <> 'ID'
	Set order to id
Endif
seek qryleping2.nomId
Select qryleping3
Scan
	Select counter_report1
	Append blank
Endscan
if used ('qryLeping1')
	use in qryLeping1
endif
if used ('qryLeping2')
	use in qryLeping2
endif
if used ('qryLeping3')
	use in qryLeping3
endif
Select counter_report1