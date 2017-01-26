-- Function: sp_salvesta_ladu_grupp(integer, integer, integer, numeric, date, numeric, numeric, numeric)
/*
CREATE ROLE ladukasutaja
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE;
*/
-- DROP FUNCTION sp_salvesta_ladu_grupp(integer, integer, integer, numeric, date, numeric, numeric, numeric);

CREATE OR REPLACE FUNCTION sp_salvesta_ladu_grupp(integer, integer, integer, numeric, date, numeric, numeric, numeric)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnParentid alias for $2;
	tnNomId alias for $3;
	tnKalor alias for $4;
	tdValid alias for $5;
	tnSahharid alias for $6;
	tnRasv alias for $7;
	tnVailkaine alias for $8;

	lnId int; 
	lnStaatus int;


begin

if tnId = 0 then
	-- uus kiri
	IF empty (tnkalor) and empty (tdValid) then
		-- lьhike versioon
		insert into ladu_grupp (parentid, nomId) values (tnParentId, tnNomId);

	else
		insert into ladu_grupp (parentid, nomId, Kalor, valid, Sahharid, Rasv, vailkaine) 
			values (tnParentId, tnNomId,tnKalor, tdValid, tnSahharid, tnRasv, tnVailkaine);

	end if;

	lnId:= cast(CURRVAL('public.ladu_grupp_id_seq') as int4);

else
	-- muuda 
	IF empty (tnkalor) and empty (tdValid) then
		-- lьhike versioon
		update ladu_grupp set 
			parentid = tnParentId, 
			nomId = tnNomId
		where id = tnId;

	else
		update ladu_grupp set 
			parentid = tnParentId, 
			nomId = tnNomId,
			Kalor = tnKalor, 
			valid = tdValid, 
			Sahharid = tnSahharid, 
			Rasv = tnRasv, 
			vailkaine = tnvailkaine
		where id = tnId;
	end if;

	lnId := tnId;

end if;
-- status

if (select count(id) from varaItem where parentid = tnParentId) > 0 then
	-- see ei ole material
	lnStaatus = 1;
else
	lnStaatus = 0;
end if;
update ladu_grupp set staatus = lnStaatus where id = lnId;


         return  lnId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_ladu_grupp(integer, integer, integer, numeric, date, numeric, numeric, numeric) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_ladu_grupp(integer, integer, integer, numeric, date, numeric, numeric, numeric) TO public;
GRANT EXECUTE ON FUNCTION sp_salvesta_ladu_grupp(integer, integer, integer, numeric, date, numeric, numeric, numeric) TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_ladu_grupp(integer, integer, integer, numeric, date, numeric, numeric, numeric) TO ladukasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_ladu_grupp(integer, integer, integer, numeric, date, numeric, numeric, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_ladu_grupp(integer, integer, integer, numeric, date, numeric, numeric, numeric) TO dbpeakasutaja;
