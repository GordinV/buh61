-- Function: sp_salvesta_mk(integer, integer, integer, integer, integer, date, date, character varying, text, character varying, integer, text, integer, integer, integer)

-- DROP FUNCTION sp_salvesta_mk(integer, integer, integer, integer, integer, date, date, character varying, text, character varying, integer, text, integer, integer, integer);

CREATE OR REPLACE FUNCTION sp_salvesta_mk(integer, integer, integer, integer, date, date, character varying, text, character varying, integer, text, integer, integer, integer)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tnaaid alias for $3;
	tndoklausid alias for $4;
	tdkpv alias for $5;
	tdmaksepaev alias for $6;
	tcnumber alias for $7;
	ttselg alias for $8;
	tcviitenr alias for $9;
	tnopt alias for $10;
	ttmuud alias for $11;
	tnarvid alias for $12;
	tndoktyyp alias for $13;
	tndokid alias for $14;
	lnmkId int;
	lnId int; 
	lrCurRec record;
begin

if tnId = 0 then
	-- uus kiri
	insert into mk (rekvid,aaid,doklausid,kpv,maksepaev,number,selg,viitenr,opt,muud,arvid,doktyyp,dokid) 
		values (tnrekvid,tnaaid,tndoklausid,tdkpv,tdmaksepaev,tcnumber,ttselg,tcviitenr,tnopt,ttmuud,tnarvid,tndoktyyp,tndokid);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
	--	raise notice 'lnId %',lnId;
		lnmkId:= cast(CURRVAL('public.mk_id_seq') as int4);
	--	raise notice 'lnaastaId %',lnaastaId;
	else
		lnmkId = 0;
	end if;

	if lnmkId = 0 then
		raise exception 'Viga:%','Ei saa lisada kiri';
	end if;



else
	-- muuda 
	select * into lrCurRec from mk where id = tnId;
	if lrCurRec.rekvid <> tnrekvid or  lrCurRec.aaid <> tnaaid or lrCurRec.doklausid <> tndoklausid or lrCurRec.kpv <> tdkpv or lrCurRec.maksepaev <> tdmaksepaev or lrCurRec.number <> tcnumber or lrCurRec.selg <> ttselg or lrCurRec.viitenr <> tcviitenr or lrCurRec.opt <> tnopt or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) or lrCurRec.arvid <> tnarvid or lrCurRec.doktyyp <> tndoktyyp or lrCurRec.dokid <> tndokid then 
	update mk set 
		rekvid = tnrekvid,
		aaid = tnaaid,
		doklausid = tndoklausid,
		kpv = tdkpv,
		maksepaev = tdmaksepaev,
		number = tcnumber,
		selg = ttselg,
		viitenr = tcviitenr,
		opt = tnopt,
		muud = ttmuud,
		arvid = tnarvid,
		doktyyp = tndoktyyp,
		dokid = tndokid
	where id = tnId;
	end if;
	lnmkId := tnId;
end if;

         return  lnmkId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_mk(integer, integer, integer, integer, date, date, character varying, text, character varying, integer, text, integer, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_mk(integer, integer, integer, integer, date, date, character varying, text, character varying, integer, text, integer, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_mk(integer, integer, integer, integer, date, date, character varying, text, character varying, integer, text, integer, integer, integer) TO dbpeakasutaja;
