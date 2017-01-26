-- Function: sp_salvesta_luba1(integer, integer, integer, numeric, numeric, integer, numeric, numeric, integer, text)
/*

select sp_salvesta_luba1(0::int,1698::int,5337::int,100::int,1.0000::numeric,0::int,0.0000::numeric,100.0000::numeric,0::int,''::text,'EEK'::varchar,1.0000::numeric)


*/
-- DROP FUNCTION sp_salvesta_luba1(integer, integer, integer, numeric, numeric, integer, numeric, numeric, integer, text);

CREATE OR REPLACE FUNCTION sp_salvesta_luba1(integer, integer, integer, numeric, numeric, integer, numeric, numeric, integer, text, character varying, numeric)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnParentid alias for $2;
	tnNomid alias for $3;
	tnMaksumaar alias for $4;
	tnKogus alias for $5;
	tnSoodus_tyyp alias for $6;
	tnSoodus alias for $7;
	tnSumma alias for $8;
	tnStaatus alias for $9;
	ttMuud alias for $10;
	tcValuuta alias for $11;
	tnKuurs alias for $12;
	lnId int; 
	lnCount int; 

	v_dokvaluuta record;
begin

if tnId = 0 then
	-- uus kiri
	insert into luba1 (parentid, nomid, maksumaar, kogus, soodus_tyyp, soodus, summa, staatus, muud) 
		values (tnparentid, tnnomid, tnmaksumaar, tnkogus, tnsoodus_tyyp, tnsoodus, tnsumma, tnstaatus, ttmuud);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		lnId:= cast(CURRVAL('public.luba1_id_seq') as int4);
	else
		lnId = 0;
	end if;

	if lnId = 0 then
		raise exception 'Viga:%','Ei saa lisada kiri';
	end if;

	-- valuuta

	insert into dokvaluuta1 (dokliik,dokid, valuuta, kuurs) 
		values (25, lnId,tcValuuta, tnKuurs);



else
	-- muuda 
	update luba1 set 
		parentid = tnparentid,
		nomid = tnNomid,
                maksumaar = tnMaksumaar, 
                kogus = tnKogus, 
                soodus_tyyp = tnsoodus_tyyp, 
                soodus = tnSoodus, 
                summa = tnSumma, 
		staatus = tnStaatus,
		muud = ttMuud
	where id = tnId;

	lnId := tnId;


	if (select count(id) from dokvaluuta1 where dokliik = 25 and dokid = lnId) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (25, lnId,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 25 and dokid = lnId ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;
			
		end if;
	
	end if;
	

end if;

	-- kontrollin valuuta luba taabelis

	if (select count(id) from dokvaluuta1 where dokliik = 23 and dokid = tnParentId) = 0 then
	
		insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs) 
			values (tnParentId,23,tcValuuta, tnKuurs);
	else
	
			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where dokid = tnParentId and dokliik = 23;

	end if;



         return  lnId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION sp_salvesta_luba1(integer, integer, integer, numeric, numeric, integer, numeric, numeric, integer, text, character varying, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_luba1(integer, integer, integer, numeric, numeric, integer, numeric, numeric, integer, text, character varying, numeric) TO dbpeakasutaja;
