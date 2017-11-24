-- Function: sp_salvesta_holidays(integer, integer, integer, integer, character varying, text)
/*
CREATE TABLE hootaabel
(
  id serial NOT NULL,
  isikid integer NOT NULL DEFAULT 0,
  nomid integer NOT NULL DEFAULT 0,
  kpv date NOT NULL,
  kogus numeric(18,4) NOT NULL DEFAULT 0,
  summa numeric(18,6) NOT NULL DEFAULT 0,
  arvid integer NOT NULL DEFAULT 0,
  muud 
*/
-- DROP FUNCTION sp_salvesta_holidays(integer, integer, integer, integer, character varying, text);

CREATE OR REPLACE FUNCTION sp_salvesta_hootaabel(integer, integer,integer, date, numeric, numeric, text)
  RETURNS integer AS
$BODY$
declare
	tnid alias for $1;
	tnIsikId alias for $2;
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
	insert into hootaabel(isikid, nomid, kpv,kogus,summa, arvid,tuluarvid, muud) 
		values (tnisikid, tnnomid, tdkpv,tnkogus,tnsumma, 0,0, ttmuud);

	lnId:= cast(CURRVAL('public.hootaabel_id_seq') as int4);

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
return  lnId;

end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION sp_salvesta_hootaabel(integer, integer,integer, date, numeric, numeric, text) TO soametnik;
GRANT EXECUTE ON FUNCTION sp_salvesta_hootaabel(integer, integer,integer, date, numeric, numeric, text) TO hkametnik;
