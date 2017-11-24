-- Function: sp_salvesta_palk_config(integer, integer, numeric, numeric, numeric, numeric, integer, integer, integer, character varying, numeric)

-- DROP FUNCTION sp_salvesta_palk_config(integer, integer, numeric, numeric, numeric, numeric, integer, integer, integer, character varying, numeric);

CREATE OR REPLACE FUNCTION sp_salvesta_palk_config(integer, integer, numeric, numeric, numeric, numeric, integer, integer, character varying, numeric, numeric, numeric, numeric, numeric, numeric)
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
	tnTm alias for $11;
	tnPm alias for $12;
	tnTka alias for $13;
	tnTki alias for $14;
	tnSm alias for $15;

	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
begin

if tnId = 0 then
	-- uus kiri
	insert into palk_config (  rekvid, minpalk, tulubaas, round, jaak, genlausend, suurasu, tm, pm, tka, tki, sm) 
		values (tnrekvid, tnminpalk, tntulubaas, tnround, tnjaak, tngenlausend, tnsuurasu, tnTm, tnPm, tnTka, tnTki, tnSm);


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
		 suurasu = tnSuurasu,
		 tm = tnTm, 
		 pm = tnPm,
		 tka = tnTka,
		 tki = tnTki,
		 sm = tnSm
		where id = tnId;

	lnId := tnId;

	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 26 and dokid = lnId) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (26, lnId,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 26 and dokid = lnId ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;
			
		end if;
	
	end if;

	
end if;


         return  lnId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_palk_config(integer, integer, numeric, numeric, numeric, numeric, integer, integer, character varying, numeric, numeric, numeric, numeric, numeric, numeric) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_config(integer, integer, numeric, numeric, numeric, numeric, integer, integer, character varying, numeric, numeric, numeric, numeric, numeric, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_palk_config(integer, integer, numeric, numeric, numeric, numeric, integer, integer, character varying, numeric, numeric, numeric, numeric, numeric, numeric) TO dbpeakasutaja;
