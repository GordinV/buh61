CREATE OR REPLACE FUNCTION sp_salvesta_ladu_grupp(integer, integer, integer, integer, date,integer,integer,integer)
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

	lnKalor int:
	lnSahharid int;
	lnRasv int;
	lnVailkaine int;

	lnId int; 
	lnStaatus int;


begin

if tnId = 0 then
	-- uus kiri
	IF empty (tnkalor) and empty (tdValid) then
		-- lühike versioon
		insert into ladu_grupp (parentid, nomId) values (tnParentId, tnNomId);

	else
		insert into ladu_grupp (parentid, nomId, Kalor, valid, Sahharid, Rasv, vailkaine) 
			values (tnParentId, tnNomId,tnKalor, tdValid, tnSahharid, tnRasv, tnVailkaine);

	end if;

	lnId:= cast(CURRVAL('public.ladu_grupp_id_seq') as int4);

else
	-- muuda 
	IF empty (tnkalor) and empty (tdValid) then
		-- lühike versioon
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

-- arvestame kalor.

if lnStaatus = 0 then
	-- parandame produkt kalor ja ained

	select sum(ladu_grupp.kalor) into lnKalor, sum(ladu_grupp.sahharid) into lnSahharid, sum(ladu_grupp.rasv) into lnrasv,
		sum(ladu_grupp.vailkaine) into lnVailkaine
		from nomenklatuur inner join ladu_grupp on nomenklatuur.id = ladu_grupp.nomid	
		inner join varaitem on varaitem.nomid = nomenklatuur.id
		group by ladu_grupp.nomid
		where varaitem.parentid = lnId;

	if lnKalor > 0 or lnSahharid > 0 or lnRasv > 0 or lnVailkaine > 0 then
		update ladu_grupp set 
			kalor = lnKalor,
			Sahharid = lnSahharid,
			Rasv = lnRasv,
			Vailkaine = lnVailkaine
			where nomid = tnParentId;

	end if;
	
end if;


         return  lnId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE;
GRANT EXECUTE ON FUNCTION sp_salvesta_ladu_grupp(integer, integer, integer, integer, date,integer,integer,integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_ladu_grupp(integer, integer, integer, integer, date,integer,integer,integer) TO dbpeakasutaja;
