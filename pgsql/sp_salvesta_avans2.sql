-- Function: sp_salvesta_avans2(integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, numeric, text)
-- DROP FUNCTION sp_salvesta_avans2(integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, numeric, text);

CREATE OR REPLACE FUNCTION sp_salvesta_avans2(integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, numeric, text,character varying,numeric,character varying, integer)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnparentid alias for $2;
	tnnomid alias for $3;
	tckonto alias for $4;
	tckood1 alias for $5;
	tckood2 alias for $6;
	tckood3 alias for $7;
	tckood4 alias for $8;
	tckood5 alias for $9;
	tctunnus alias for $10;
	tnsumma alias for $11;
	tnkbm alias for $12;
	tnkokku alias for $13;
	ttmuud alias for $14;
	tcValuuta alias for $15;
	tnKuurs alias for $16;
	tcProj alias for $17;
	tnOpt alias for $18;
	lnavans2Id int;
	lnId int; 
	lrCurRec record;
	v_dokvaluuta record;
begin

if tnId = 0 then
	-- uus kiri
	insert into avans2 (parentid,nomid,konto,kood1,kood2,kood3,kood4,kood5,tunnus,summa,kbm,kokku,muud,proj) 
		values (tnparentid,tnnomid,tckonto,tckood1,tckood2,tckood3,tckood4,tckood5,tctunnus,tnsumma,tnkbm,tnkokku,ttmuud,tcProj);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
	--	raise notice 'lnId %',lnId;
		lnavans2Id:= cast(CURRVAL('public.avans2_id_seq') as int4);
	--	raise notice 'lnaastaId %',lnaastaId;
	else
		lnavans2Id = 0;
	end if;

	if lnavans2Id = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;

	-- valuuta

	insert into dokvaluuta1 (dokliik,dokid, valuuta, kuurs) 
		values (5, lnavans2Id,tcValuuta, tnKuurs);



else
	-- muuda 
	select * into lrCurRec from avans2 where id = tnId;
	if lrCurRec.parentid <> tnparentid or lrCurRec.nomid <> tnnomid or lrCurRec.konto <> tckonto or lrCurRec.kood1 <> tckood1 or
		lrCurRec.kood2 <> tckood2 or lrCurRec.kood3 <> tckood3 or lrCurRec.kood4 <> tckood4 or lrCurRec.kood5 <> tckood5 or 
		lrCurRec.tunnus <> tctunnus or lrCurRec.summa <> tnsumma or lrCurRec.proj <> tcProj or
		lrCurRec.kbm <> tnkbm or lrCurRec.kokku <> tnkokku or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) then 
	update avans2 set 
		parentid = tnparentid,
		nomid = tnnomid,
		konto = tckonto,
		kood1 = tckood1,
		kood2 = tckood2,
		kood3 = tckood3,
		kood4 = tckood4,
		kood5 = tckood5,
		tunnus = tctunnus,
		proj = tcProj,
		summa = tnsumma,
		kbm = tnkbm,
		kokku = tnkokku,
		muud = ttmuud
	where id = tnId;
	end if;
	lnavans2Id := tnId;

	-- valuuta
	if (select count(id) from dokvaluuta1 where dokliik = 5 and dokid = lnavans2Id) = 0 then

		insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs) 
			values (5, lnavans2Id,tcValuuta, tnKuurs);
	else
		select * into v_dokvaluuta from dokvaluuta1 where dokliik = 5 and dokid = lnavans2Id ;

		if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

			update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;
			
		end if;
	
	end if;
			

	
end if;
if tnOpt = 1 then
	-- lisa operatsioonid
	perform fnc_avansijaak(tnParentId);
	perform gen_lausend_avans(tnParentId);
end if;

         return  lnavans2Id;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_avans2(integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, numeric, text,character varying,numeric, character varying, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_avans2(integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, numeric, text,character varying,numeric, character varying, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_avans2(integer, integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, numeric, text,character varying,numeric, character varying, integer) TO dbpeakasutaja;
