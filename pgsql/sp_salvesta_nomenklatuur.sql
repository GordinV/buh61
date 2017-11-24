-- Function: sp_salvesta_nomenklatuur(integer, integer, integer, character, character, character, character, numeric, text, numeric, numeric, text)

-- DROP FUNCTION sp_salvesta_nomenklatuur(integer, integer, integer, character, character, character, character, numeric, text, numeric, numeric, text);

CREATE OR REPLACE FUNCTION sp_salvesta_nomenklatuur(integer, integer, integer, character, character, character, character, numeric, text, numeric, numeric, text, character, numeric)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tndoklausid alias for $3;
	tcdok alias for $4;
	tckood alias for $5;
	tcnimetus alias for $6;
	tcuhik alias for $7;
	tnhind alias for $8;
	ttmuud alias for $9;
	tnulehind alias for $10;
	tnkogus alias for $11;
	ttformula alias for $12;
	tcValuuta alias for $13;
	tnKuurs alias for $14;
	lnnomenklatuurId int;
	v_dokvaluuta record;
	lnId int; 
	lrCurRec record;
begin

if tnId = 0 then
	-- uus kiri
	insert into nomenklatuur (rekvid,doklausid,dok,kood,nimetus,uhik,hind,muud,ulehind,kogus,formula) 
		values (tnrekvid,tndoklausid,tcdok,tckood,tcnimetus,tcuhik,tnhind,ttmuud,tnulehind,tnkogus,ttformula);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
	--	raise notice 'lnId %',lnId;
		lnnomenklatuurId:= cast(CURRVAL('public.nomenklatuur_id_seq') as int4);
	--	raise notice 'lnaastaId %',lnaastaId;
	else
		lnnomenklatuurId = 0;
	end if;

	if lnnomenklatuurId = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

	-- valuuta

	insert into dokvaluuta1 (dokliik,dokid, valuuta, kuurs) 
		values (17, lnnomenklatuurId,tcValuuta, tnKuurs);



else
	-- muuda 
	select * into lrCurRec from nomenklatuur where id = tnId;
	if lrCurRec.rekvid <> tnrekvid or lrCurRec.doklausid <> tndoklausid or lrCurRec.dok <> tcdok or lrCurRec.kood <> tckood or lrCurRec.nimetus <> tcnimetus or lrCurRec.uhik <> tcuhik or lrCurRec.hind <> tnhind or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) or lrCurRec.ulehind <> tnulehind or lrCurRec.kogus <> tnkogus or lrCurRec.formula <> ttformula then 
	update nomenklatuur set 
		rekvid = tnrekvid,
		doklausid = tndoklausid,
		dok = tcdok,
		kood = tckood,
		nimetus = tcnimetus,
		uhik = tcuhik,
		hind = tnhind,
		muud = ttmuud,
		ulehind = tnulehind,
		kogus = tnkogus,
		formula = ttformula
	where id = tnId;
	end if;
	lnnomenklatuurId := tnId;

	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 17 and dokid = lnnomenklatuurId) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (17, lnnomenklatuurId,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 17 and dokid = lnnomenklatuurId ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;
			
		end if;
	
	end if;
			

	
end if;

         return  lnnomenklatuurId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_nomenklatuur(integer, integer, integer, character, character, character, character, numeric, text, numeric, numeric, text, character, numeric) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_nomenklatuur(integer, integer, integer, character, character, character, character, numeric, text, numeric, numeric, text,character, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_nomenklatuur(integer, integer, integer, character, character, character, character, numeric, text, numeric, numeric, text,character, numeric) TO dbpeakasutaja;
