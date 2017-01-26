-- Function: fnc_get_asutuse_staatus(integer, integer)

-- DROP FUNCTION fnc_get_asutuse_staatus(integer, integer);

CREATE OR REPLACE FUNCTION fnc_get_asutuse_staatus(integer, integer)
  RETURNS integer AS
$BODY$

DECLARE tnRekvid alias for $1;
	tnOmaRekv alias for $2;

	lnReturn integer;
	lnParentId integer;
	lnParentIdSub integer;


begin	


lnReturn = 999; -- tase
lnParentId = 0;


select parentId into lnParentId from rekv where id = tnOmaRekv;
select parentId into lnParentIdSub from rekv where id = tnRekvId;

--raise notice 'tnRekvId rekvid %',tnRekvId;
--raise notice 'tnOmaRekv rekvid %',tnOmaRekv;
--raise notice 'lnParentId %',lnParentId;
--raise notice 'lnParentIdSub %',lnParentIdSub;


if lnParentIdSub = 0 then
	-- eelarve pidaja
	lnReturn = 0;
--	raise notice 'eelarve pidaja %',lnReturn;
end if;

if tnRekvId = tnOmaRekv then
	-- omaasutus
	lnReturn = 3;
--	raise notice 'omaasutus %',lnReturn;
end if;


if lnreturn = 999 and (tnRekvId = lnparentId or tnRekvId = tnOmaRekv) then
	-- meie ülemasutus
	lnReturn = 1; 
--	raise notice 'meie ülemasutus %',lnReturn;

end if;
if lnreturn = 999 and lnParentIdSub = tnOmaRekv  then
	--meie madala asutus
	lnReturn = 4;
--	raise notice 'meie madala asutus %',lnReturn;
end if;

if lnParentIdSub <> tnOmaRekv then
--		raise notice 'lnParentIdSub <> tnRekvId';
	if (select parentid from rekv where id = lnParentIdSub) = tnOmaRekv then
--		raise notice 'sub alasutus';
		lnReturn = 4;				
	end if;
end if;


if lnreturn = 999 then 
--	if (select count(id) from rekv where parentid = tnrekvId) > 0 and 

--	raise notice 'muud';
	lnReturn = 2;
end if;

RETURN lnReturn;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnc_get_asutuse_staatus(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnc_get_asutuse_staatus(integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION fnc_get_asutuse_staatus(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fnc_get_asutuse_staatus(integer, integer) TO dbvaatleja;
