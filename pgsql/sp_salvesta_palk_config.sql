-- Function: sp_salvesta_mk1(integer, integer, integer, integer, numeric, character varying, character varying, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying)

/*
select * from palk_config

select sp_salvesta_palk_config(0, 110, 278::numeric, 144::numeric, 0::integer, 0::integer, 1::integer, 0::integer, 
	'EUR':: character varying, 15.6466::numeric) 

	from palk_config 

select * from rekv where id not in (select rekvid from palk_config)

*/
CREATE OR REPLACE FUNCTION sp_salvesta_palk_config(integer, integer, numeric, numeric, integer, integer, integer, integer, character varying, numeric)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tnMinpalk alias for $3;
	tntulubaas alias for $4;
	tnround alias for $5;
	tnjaak alias for $6;
	tngenlausend alias for $7;
	tnsuurasu alias for $8;
	tcvaluuta alias for $9;
	tnKuurs alias for $10;

	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
begin

if tnId = 0 then
	-- uus kiri
	insert into palk_config (  rekvid, minpalk, tulubaas, round, jaak, genlausend, suurasu) 
		values (tnrekvid, tnminpalk, tntulubaas, tnround, tnjaak, tngenlausend, tnsuurasu);


	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		lnId:= cast(CURRVAL('public.palk_config_id_seq') as int4);
	else
		lnId = 0;
	end if;

	if lnId = 0 then
		raise exception 'Viga:%','Ei saa lisada kiri';
	end if;

	-- valuuta

	insert into dokvaluuta1 (dokliik,dokid, valuuta, kuurs) 
		values (26, lnId,tcValuuta, tnKuurs);


else
	-- muuda 
	update palk_config set 
		 rekvid = tnRekvId, 
		 minpalk = tnMinPalk, 
		 tulubaas = tnTulubaas, 
		 round = tnRound, 
		 jaak = tnJaak, 
		 genlausend = tnGenLausend, 
		 suurasu = tnSuurasu
		where id = tnId;

	lnId := tnId;

	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 26 and dokid = lnId) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (26, tnId,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 26 and dokid = tnId ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;
			
		end if;
	
	end if;

	
end if;


         return  lnId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_palk_config(integer, integer, numeric, numeric, integer, integer, integer, integer, character varying, numeric) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_config(integer, integer, numeric, numeric, integer, integer, integer, integer, character varying, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_config(integer, integer, numeric, numeric, integer, integer, integer, integer, character varying, numeric) TO dbpeakasutaja;
