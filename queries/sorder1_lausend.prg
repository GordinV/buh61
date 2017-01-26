If empty(v_sorder2.nomId)
	Return .f.
Endif
If vartype(odb) <> 'O'
	Set classlib to classes\classlib
	odb = createobject('db')
Endif

tnNomId = v_sorder2.nomId
Select comNomRemote
Locate for id = tnNomId
Select comLausendRemote
locate for id = comNomRemote.lausendId
if !found()
	return .f.
endif
Insert into v_sorderjournal1 (lausendid, deebet, kreedit, nimetus, summa, kood1, kood2, kood3, kood4, kood5);
	values (comLausendRemote.id,comLausendRemote.deebet, comLausendRemote.kreedit,;
	comLausendRemote.nimetus, v_sorder2.summa, comNomRemote.kood1,comNomRemote.kood2, comNomRemote.kood3, comNomRemote.kood4,;
	comNomRemote.kood5 )
	If !empty (v_sorderjournal1.kood1)
		Select comObjektRemote
		Locate for id = v_sorderjournal1.kood1
		lcObjekt = comObjektRemote.kood
	Else
		lcObjekt = ''
	Endif
	If !empty (v_sorderjournal1.kood2)
		Select comallikadremote
		Locate for id = v_sorderjournal1.kood2
		lcAllikas = comallikadremote.kood
	Else
		lcAllikas = ''
	Endif
	If !empty (v_sorderjournal1.kood3)
		Select comArtikkelremote
		Locate for id = v_sorderjournal1.kood3
		lcArtikkel = comArtikkelremote.kood
	Else
		lcArtikkel = ''
	Endif
	If !empty (v_sorderjournal1.kood4)
		Select comTegevremote
		Locate for id = v_sorderjournal1.kood4
		lcTegev = comTegevremote.kood
	Else
		lcTegev = ''
	Endif
	If !empty (v_sorderjournal1.kood5)
		If !used ('comEelAllikasJournal')
			tcKood = '%%'
			tcNimetus = '%%'
			odb.use('comTuludeAllikad','comEelAllikasJournal')
		Endif
		Select comEelAllikasJournal
		Locate for id = v_sorderjournal1.kood5
		lcEelAllikas = comEelAllikasJournal.kood
	Else
		lcEelAllikas = ''
	Endif
	Replace artikkel with lcArtikkel,;
		objekt with lcObjekt,;
		allikas with lcAllikas,;
		tegev with lcTegev ,;
		eelallikas with lcEelAllikas in v_sorderjournal1

If reccount('v_sorderjournal') < 1
	Insert into v_sorderjournal (rekvid, userId, asutusid, kpv, dok, selg);
		values (grekv,gUserId,  v_sorder1.asutusid, v_sorder1.kpv, v_sorder1.number,v_dokprop.selg )
Else
	Update v_sorderjournal set;
		kpv = v_sorder1.kpv,;
		dok = v_sorder1.number,;
		selg = v_dokprop.selg,;
		asutusid = 	v_sorder1.asutusid
Endif

