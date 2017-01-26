-- Function: sp_salvesta_leping3(integer, integer, date, numeric, numeric, text)

-- DROP FUNCTION sp_salvesta_leping3(integer, integer, date, numeric, numeric, text);

CREATE OR REPLACE FUNCTION sp_salvesta_leping3(integer, integer, date, numeric, numeric, text)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnparentid alias for $2;
	tdkpv alias for $3;
	tnalgkogus alias for $4;
	tnloppkogus alias for $5;
	ttmuud alias for $6;
	lnleping3Id int;
	lnId int; 
	lrCurRec record;
begin

if tnId = 0 then
	-- uus kiri
	insert into leping3 (parentid,kpv,algkogus,loppkogus,muud) 
		values (tnparentid,tdkpv,tnalgkogus,tnloppkogus,ttmuud);

	lnleping3Id:= cast(CURRVAL('public.leping3_id_seq') as int4);

else
	-- muuda 
	select * into lrCurRec from leping3 where id = tnId;
	if lrCurRec.parentid <> tnparentid or lrCurRec.kpv <> tdkpv or lrCurRec.algkogus <> tnalgkogus or lrCurRec.loppkogus <> tnloppkogus or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) then 
	update leping3 set 
		parentid = tnparentid,
		kpv = tdkpv,
		algkogus = tnalgkogus,
		loppkogus = tnloppkogus,
		muud = ttmuud
	where id = tnId;
	end if;
	lnleping3Id := tnId;
end if;

         return  lnleping3Id;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_leping3(integer, integer, date, numeric, numeric, text) OWNER TO vladislav;
GRANT EXECUTE ON FUNCTION sp_salvesta_leping3(integer, integer, date, numeric, numeric, text) TO vladislav;
GRANT EXECUTE ON FUNCTION sp_salvesta_leping3(integer, integer, date, numeric, numeric, text) TO public;
GRANT EXECUTE ON FUNCTION sp_salvesta_leping3(integer, integer, date, numeric, numeric, text) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_leping3(integer, integer, date, numeric, numeric, text) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_leping3(integer, integer, date, numeric, numeric, text) TO "BS2";
