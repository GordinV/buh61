﻿-- Function: sp_salvesta_holidays(integer, integer, integer, integer, character varying, text)
/*
select sp_salvesta_hootaabel(0,        3,        1,date(2012,12, 1),        0,        0,'')

*/
-- DROP FUNCTION sp_salvesta_holidays(integer, integer, integer, integer, character varying, text);

CREATE OR REPLACE FUNCTION sp_salvesta_hootaabel(integer, integer,integer, date, numeric, numeric, text)
  RETURNS integer AS
$BODY$
	tnNomId alias for $3;
	tdKpv alias for $4;
	tnKogus alias for $5;
	tnSumma alias for $6;
	ttmuud alias for $7;
	lnId int; 
	lrCurRec record;
begin
if tnId = 0 then
	-- uus kiri
	insert into hootaabel(isikid, nomid, kpv,kogus,summa, arvid,muud) 
		values (tnisikid, tnnomid, tdkpv,tnkogus,tnsumma, 0,ttmuud);
else
	-- muuda 
	update hootaabel set 
		isikid = tnIsikId, 
		nomid = tnNomid, 
		kpv = tdKpv,
		kogus = tnKogus,
		summa = tnSumma, 
		muud = ttmuud
	where id = tnId;
	lnId := tnId;
end if;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION sp_salvesta_hootaabel(integer, integer,integer, date, numeric, numeric, text) TO soametnik;
GRANT EXECUTE ON FUNCTION sp_salvesta_hootaabel(integer, integer,integer, date, numeric, numeric, text) TO hkametnik;