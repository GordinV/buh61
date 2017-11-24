-- Function: sp_salvesta_avans1(integer, integer, integer, integer, date, character varying, text, integer, integer, text)

-- DROP FUNCTION sp_salvesta_avans1(integer, integer, integer, integer, date, character varying, text, integer, integer, text);

CREATE OR REPLACE FUNCTION sp_salvesta_avans1(integer, integer, integer, integer, date, character varying, text, integer, text)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tnuserid alias for $3;
	tnasutusid alias for $4;
	tdkpv alias for $5;
	tcnumber alias for $6;
	ttselg alias for $7;
	tndokpropid alias for $8;
	ttmuud alias for $9;
	lnavans1Id int;
	lnId int; 
	lrCurRec record;
begin

if (fnc_aasta_kontrol(tnrekvid, tdkpv)= 0) then
	raise exception 'Perion on kinnitatud';
	return 0;
end if;


if tnId = 0 then
	-- uus kiri
	insert into avans1 (rekvid,userid,asutusid,kpv,number,selg,dokpropid,muud,jaak) 
		values (tnrekvid,tnuserid,tnasutusid,tdkpv,tcnumber,ttselg,tndokpropid,ttmuud,0);

	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
	--	raise notice 'lnId %',lnId;
		lnavans1Id:= cast(CURRVAL('public.avans1_id_seq') as int4);
	--	raise notice 'lnaastaId %',lnaastaId;
	else
		lnavans1Id = 0;
	end if;

	if lnavans1Id = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;




else
	-- muuda 
	select * into lrCurRec from avans1 where id = tnId;
	if lrCurRec.rekvid <> tnrekvid or lrCurRec.userid <> tnuserid or lrCurRec.asutusid <> tnasutusid or lrCurRec.kpv <> tdkpv or
		lrCurRec.number <> tcnumber or lrCurRec.selg <> ttselg  or lrCurRec.dokpropid <> tndokpropid or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) then 
	update avans1 set 
		rekvid = tnrekvid,
		userid = tnuserid,
		asutusid = tnasutusid,
		kpv = tdkpv,
		number = tcnumber,
		selg = ttselg,
		dokpropid = tndokpropid,
		muud = ttmuud
	where id = tnId;
	end if;
	lnavans1Id := tnId;
end if;
if lnavans1Id > 0 then
	perform fnc_avansijaak(lnavans1Id);
end if;
         return  lnavans1Id;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_avans1(integer, integer, integer, integer, date, character varying, text,  integer, text) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_avans1(integer, integer, integer, integer, date, character varying, text, integer, text) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_avans1(integer, integer, integer, integer, date, character varying, text, integer, text) TO dbpeakasutaja;
