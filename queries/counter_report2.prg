Parameter cWhere
If isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
	tnId = cWhere
else
	tnid = curlepingud.id
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
	.use ('v_leping1','qryleping1')
	.use ('v_leping2','qryleping2')
	Select comAsutusremote
	If tag() <> 'ID'
		Set order to id
	Endif
	Seek qryleping1.asutusId
	Select qryleping2
	Scan
		Select comNomRemote
		If tag() <> 'ID'
			Set order to id
		Endif
		Seek qryleping2.nomId

		tnId = qryleping2.id
		.use ('v_leping3','qryleping3')
		select qryLeping3
		scan
			Select counter_report1
			Append blank
		endscan
	Endscan
Endwith

If used ('qryLeping1')
	Use in qryleping1
Endif
If used ('qryLeping2')
	Use in qryleping2
Endif
If used ('qryLeping3')
	Use in qryleping3
Endif
Select counter_report1
