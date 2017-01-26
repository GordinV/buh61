-- Function: sp_salvesta_leping1(integer, integer, integer, integer, character, date, date, text, text, text)

-- DROP FUNCTION sp_salvesta_leping1(integer, integer, integer, integer, character, date, date, text, text, text);

CREATE OR REPLACE FUNCTION sp_salvesta_leping1(integer, integer, integer, integer, character, date, date, text, text, text)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnasutusid alias for $2;
	tnrekvid alias for $3;
	tndoklausid alias for $4;
	tcnumber alias for $5;
	tdkpv alias for $6;
	tdtahtaeg alias for $7;
	ttselgitus alias for $8;
	ttdok alias for $9;
	ttmuud alias for $10;
	lnleping1Id int;
	lnId int; 
	lrCurRec record;
begin

if tnId = 0 then
	-- uus kiri
	insert into leping1 (asutusid,rekvid,doklausid,number,kpv,tahtaeg,selgitus,dok,muud) 
		values (tnasutusid,tnrekvid,tndoklausid,tcnumber,tdkpv,tdtahtaeg,ttselgitus,ttdok,ttmuud);


	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		lnleping1Id:= cast(CURRVAL('public.leping1_id_seq') as int4);
	else
		lnleping1Id = 0;
	end if;

	if lnleping1Id = 0 then
		raise exception 'Viga:%','Ei saa lisada kiri';
	end if;

else
	-- muuda 
	select * into lrCurRec from leping1 where id = tnId;
	if lrCurRec.asutusid <> tnasutusid or lrCurRec.rekvid <> tnrekvid or lrCurRec.doklausid <> tndoklausid or lrCurRec.number <> tcnumber or lrCurRec.kpv <> tdkpv or ifnull(lrCurRec.tahtaeg,date(1900,01,01)) <> ifnull(tdtahtaeg,date(1900,01,01)) or lrCurRec.selgitus <> ttselgitus or ifnull(lrCurRec.dok,space(1)) <> ifnull(ttdok,space(1)) or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) then 
	update leping1 set 
		asutusid = tnasutusid,
		rekvid = tnrekvid,
		doklausid = tndoklausid,
		number = tcnumber,
		kpv = tdkpv,
		tahtaeg = tdtahtaeg,
		selgitus = ttselgitus,
		dok = ttdok,
		muud = ttmuud
	where id = tnId;
	end if;
	lnleping1Id := tnId;
end if;

         return  lnleping1Id;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_leping1(integer, integer, integer, integer, character, date, date, text, text, text) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_leping1(integer, integer, integer, integer, character, date, date, text, text, text) TO public;
GRANT EXECUTE ON FUNCTION sp_salvesta_leping1(integer, integer, integer, integer, character, date, date, text, text, text) TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_leping1(integer, integer, integer, integer, character, date, date, text, text, text) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_leping1(integer, integer, integer, integer, character, date, date, text, text, text) TO dbpeakasutaja;
