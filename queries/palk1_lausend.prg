IF !used ('qryPalkLib') or empty (qryPalkLib.lausendid) or !used ('v_palk_oper')
	RETURN .f.
ENDIF
tnId = v_palk_oper.lepingId
IF USED ('qryTooleping')
	USE IN qryTooleping
ENDIF
WITH odb
	.use ('qryTooleping')
	lnIsikId = qryTooleping.parentid
	IF !used ('v_palk_kaart')
		tnId = lnIsikId
		.use ('v_palk_kaart')
	ENDIF
	SELECT comLausendRemote
	LOCATE for id = qryPalkLib.lausendid
	IF found()
		SELECT v_palkjournal1
		INSERT into v_palkjournal1 (lausendid, deebet, kreedit, nimetus, summa);
			values (qryPalkLib.lausendid,comLausendRemote.deebet, comLausendRemote.kreedit,;
			comLausendRemote.nimetus, v_palk_oper.summa)
		tnNomid1 = 0
		tnNomId2 = 999999999
		tnPalk1 = 0
		tnPalk2 = 999999999
		tnLib1 = v_palk_oper.libid
		tnLib2 = v_palk_oper.libid
		.use ('v_klassiflib')

		IF 'EELARVE' $ curKey.versia
			IF reccount ('v_klassiflib') > 0
				REPLACE v_palkjournal1.kood1 with  v_klassiflib.kood1,;
					v_palkjournal1.kood2 with  v_klassiflib.kood2,;
					v_palkjournal1.kood3 with  v_klassiflib.kood3,;
					v_palkjournal1.kood5 with  v_klassiflib.kood5,;
					v_palkjournal1.kood4 with  v_klassiflib.kood4 in v_palkjournal1
			ENDIF

			IF !empty (v_palkjournal1.kood1)
				SELECT comObjektRemote
				LOCATE for id = v_palkjournal1.kood1
				lcObjekt = comObjektRemote.kood
			ELSE
				lcObjekt = ''
			ENDIF
			IF !empty (v_palkjournal1.kood2)
				SELECT comallikadremote
				LOCATE for id = v_palkjournal1.kood2
				lcAllikas = comallikadremote.kood
			ELSE
				lcAllikas = ''
			ENDIF
			IF !empty (v_palkjournal1.kood3)
				SELECT comArtikkelremote
				LOCATE for id = v_palkjournal1.kood3
				lcArtikkel = comArtikkelremote.kood
			ELSE
				lcArtikkel = ''
			ENDIF
			IF !empty (v_palkjournal1.kood4)
				SELECT comTegevremote
				LOCATE for id = v_palkjournal1.kood4
				lcTegev = comTegevremote.kood
			ELSE
				lcTegev = ''
			ENDIF
			IF !empty (v_palkjournal1.kood5)
				IF !used ('comEelAllikasJournal')
					tcKood = '%%'
					tcNimetus = '%%'
					.use('comTuludeAllikad','comEelAllikasJournal')
				ENDIF
				SELECT comEelAllikasJournal
				LOCATE for id = v_palkjournal1.kood5
				lcEelAllikas = comEelAllikasJournal.kood
			ELSE
				lcEelAllikas = ''
			ENDIF
			REPLACE artikkel with lcArtikkel,;
				objekt with lcObjekt,;
				allikas with lcAllikas,;
				tegev with lcTegev ,;
				eelallikas with lcEelAllikas in v_palkjournal1
		ENDIF

		INSERT into v_palkjournal (rekvid, userId, asutusid, kpv,selg);
			values (grekv,gUserId,  lnIsikId, v_palk_oper.kpv, v_dokprop.selg )
		IF reccount ('v_klassiflib') > 0 and !empty (v_klassiflib.tunnusId)
			REPLACE v_palkjournal.tunnusId with v_klassiflib.tunnusId in v_palkjournal
		ENDIF
		USE in v_klassiflib
		IF empty (v_palk_kaart.tunnusId)
			tnOsakond = qryTooleping.osakondid
			tnAmet = qryTooleping.ametid
			.use ('v_palk_asutus')

			IF !empty (v_palk_asutus.tunnusId)
				REPLACE v_palkjournal.tunnusId with v_palk_asutus.tunnusId in v_palkjournal
			ENDIF
		ENDIF
		IF !empty (v_palk_kaart.tunnusId)
			REPLACE v_palkjournal.tunnusId with v_palk_kaart.tunnusId in v_palkjournal
		ENDIF
	ENDIF
	IF used ('qryTooleping')
		USE in qryTooleping
	ENDIF
ENDWITH
