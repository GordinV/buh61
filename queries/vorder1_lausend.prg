If empty(v_Vorder2.nomId)
	Return .f.
Endif
If vartype(odb) <> 'O'
	Set classlib to classes\classlib
	odb = createobject('db')
Endif
tnNomId = v_Vorder2.nomId
select comNomRemote
locate for id = tnNomid
&&oDb.Use ('queryDokLausend')
tnId = v_Vorder1.doklausId

Select comLausendRemote
Locate for id = comNomremote.lausendid
Insert into v_Vorderjournal1 (lausendid, deebet, kreedit, nimetus, summa, kood1, kood2, kood3, kood4, kood5);
		values (comLausendRemote.id,comLausendRemote.deebet, comLausendRemote.kreedit,;
		comLausendRemote.nimetus, v_Vorder2.summa, comNomRemote.kood1, comNomRemote.kood2, comNomRemote.kood3,;
		comNomRemote.kood4, comNomRemote.kood5)
If 'EELARVE' $ curKey.versia
	tnNomid1 = v_Vorder2.nomId
	tnNomId2 = v_Vorder2.nomId
	tnPalk1 = 0
	tnPalk2 = 999999999
	tnLib1 = 0
	tnLib2 = 999999999
	If !empty (v_Vorderjournal1.kood1)
		Select comObjektRemote
		Locate for id = v_Vorderjournal1.kood1
		lcObjekt = comObjektRemote.kood
	Else
		lcObjekt = ''
	Endif
	If !empty (v_Vorderjournal1.kood2)
		Select comallikadremote
		Locate for id = v_Vorderjournal1.kood2
		lcAllikas = comallikadremote.kood
	Else
		lcAllikas = ''
	Endif
	If !empty (v_Vorderjournal1.kood3)
		Select comArtikkelremote
		Locate for id = v_Vorderjournal1.kood3
		lcArtikkel = comArtikkelremote.kood
	Else
		lcArtikkel = ''
	Endif
	If !empty (v_Vorderjournal1.kood4)
		Select comTegevremote
		Locate for id = v_Vorderjournal1.kood4
		lcTegev = comTegevremote.kood
	Else
		lcTegev = ''
	Endif
	If !empty (v_Vorderjournal1.kood5)
		If !used ('comEelAllikasJournal')
			tcKood = '%%'
			tcNimetus = '%%'
			odb.use('comTuludeAllikad','comEelAllikasJournal')
		Endif
		Select comEelAllikasJournal
		Locate for id = v_Vorderjournal1.kood5
		lcEelAllikas = comEelAllikasJournal.kood
	Else
		lcEelAllikas = ''
	Endif
	Replace artikkel with lcArtikkel,;
		objekt with lcObjekt,;
		allikas with lcAllikas,;
		tegev with lcTegev ,;
		eelallikas with lcEelAllikas in v_Vorderjournal1

Endif
If reccount('v_Vorderjournal') < 1
	Insert into v_Vorderjournal (rekvid, userId, asutusid, kpv, dok, selg);
		values (grekv,gUserId,  v_Vorder1.asutusid, v_Vorder1.kpv, v_Vorder1.number,v_dokprop.selg )
Else
	Update v_Vorderjournal set;
		kpv = v_Vorder1.kpv,;
		dok = v_Vorder1.number,;
		selg = v_dokprop.selg,;
		asutusid = 	v_Vorder1.asutusid
Endif

