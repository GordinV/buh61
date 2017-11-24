If empty(v_mk1.nomId)
	Return .f.
Endif
tnNomId = v_mk1.nomId
lnTyyp = iif (v_mk.opt = 0,1,2)
Select comNomRemote
Locate for id = tnNomId and tyyp = lnTyyp
&&oDb.Use ('queryDokLausend')
tnId = v_mk.doklausId

Select comLausendRemote
Locate for id = comNomRemote.lausendid
select v_mkjournal
lnBuffer = cursorgetprop ('buffering')
if lnBuffer > 1
	select v_mkjournal
	=tableupdate (.t.)
	select v_mkjournal1
	=tableupdate (.t.)
	=cursorsetprop ('buffering',1,'v_mkjournal')
	=cursorsetprop ('buffering',1,'v_mkjournal1')
endif
select v_mkjournal
lnFields = aFields (aTbl)
lnresult = ascan (aTbl,'REANR')
If lnresult = 0
	alter table v_mkjournal add column reanr int
Endif
select v_mkjournal1
lnFields = aFields (aTbl)
lnresult = ascan (aTbl,'REANR')
If lnresult = 0
	alter table v_mkjournal1 add column reanr int
Endif

Insert into v_mkjournal1 (lausendid, deebet, kreedit, nimetus, summa, kood1, kood2, kood3, kood4, kood5, reanr);
	values (comLausendRemote.id,comLausendRemote.deebet, comLausendRemote.kreedit,;
	comLausendRemote.nimetus, v_mk1.summa, comNomRemote.kood1, comNomRemote.kood2, comNomRemote.kood3,;
	comNomRemote.kood4, comNomRemote.kood5, recno('v_mkjournal1'))
If 'EELARVE' $ curKey.versia
	tnNomid1 = v_mk1.nomId
	tnNomId2 = v_mk1.nomId
	tnPalk1 = 0
	tnPalk2 = 999999999
	tnLib1 = 0
	tnLib2 = 999999999
	If !empty (v_mkjournal1.kood1)
		Select comObjektRemote
		Locate for id = v_mkjournal1.kood1
		lcObjekt = comObjektRemote.kood
	Else
		lcObjekt = ''
	Endif
	If !empty (v_mkjournal1.kood2)
		Select comallikadremote
		Locate for id = v_mkjournal1.kood2
		lcAllikas = comallikadremote.kood
	Else
		lcAllikas = ''
	Endif
	If !empty (v_mkjournal1.kood3)
		Select comArtikkelremote
		Locate for id = v_mkjournal1.kood3
		lcArtikkel = comArtikkelremote.kood
	Else
		lcArtikkel = ''
	Endif
	If !empty (v_mkjournal1.kood4)
		Select comTegevremote
		Locate for id = v_mkjournal1.kood4
		lcTegev = comTegevremote.kood
	Else
		lcTegev = ''
	Endif
	If !empty (v_mkjournal1.kood5)
		If !used ('comEelAllikasJournal')
			tcKood = '%%'
			tcNimetus = '%%'
			odb.use('comTuludeAllikad','comEelAllikasJournal')
		Endif
		Select comEelAllikasJournal
		Locate for id = v_mkjournal1.kood5
		lcEelAllikas = comEelAllikasJournal.kood
	Else
		lcEelAllikas = ''
	Endif
	Replace artikkel with lcArtikkel,;
		objekt with lcObjekt,;
		allikas with lcAllikas,;
		tegev with lcTegev ,;
		eelallikas with lcEelAllikas in v_mkjournal1

Endif
Insert into v_mkjournal (rekvid, userId, asutusid, kpv, dok, selg, reanr);
	values (grekv,gUserId,  v_mk1.asutusid, v_mk.kpv, v_mk.number,v_dokprop.selg, recno('v_mkjournal1'))
replace reanr with v_mkjournal.reanr in v_mk1
=cursorsetprop ('buffering',5,'v_mkjournal')
=cursorsetprop ('buffering',5,'v_mkjournal1')
