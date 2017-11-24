-- Function: sp_kinni_hootaabel(integer, integer, integer, integer)

-- DROP FUNCTION sp_kinni_hootaabel(integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION sp_kinni_hootaabel(integer, integer, integer, integer)
  RETURNS integer AS
$BODY$
declare
	tnIsikid alias for $1;
	tnArvId alias for $2;
	tnAasta alias for $3;
	tnKuu alias for $4;

	lnreturn integer;
	lnIsikid integer;
	lcLisa varchar(120);
	lnArvLiik int;
begin
lnreturn = 0;
lnIsikId = tnIsikid;
if lnIsikId = 0 then
	select lisa into lcLisa from arv  where id = tnArvId;
	lcLisa = ifnull(lcLisa,space(1));
	lnIsikId = fnc_leiaisikukood(lcLisa);
end if;
raise notice 'lnIsikid %',lnIsikId;

select arv.liik into lnArvLiik from arv where id = tnArvId;
raise notice 'lnArvLiik %',lnArvLiik;
if lnArvLiik = 1 then
	if (select count(id) from hootaabel where isikid = lnIsikId and year(kpv) = tnAasta and month(kpv) = tnKuu and arvid = 0) > 0 then
		update hootaabel set arvid = tnArvId where isikid = lnIsikId and year(kpv) = tnAasta and month(kpv) = tnKuu and arvid = 0;
		lnReturn = 1;
	end if;
else
	if (select count(id) from hootaabel where isikid = lnIsikId and year(kpv) = tnAasta and month(kpv) = tnKuu and ifnull(tuluArvid,0) = 0) > 0 then
		raise notice 'Kinnitan taabel ';
		update hootaabel set tuluarvid = tnArvId where isikid = lnIsikId and year(kpv) = tnAasta and month(kpv) = tnKuu and ifnull(tuluarvid,0) = 0;
		lnReturn = 1;
	end if;

end if;
-- uhendame arved ja isik
if (select count(id) from hoouhendused where isikid = lnIsikId and dokid = tnArvId and doktyyp = 'ARVED') = 0 THEN
	raise notice 'Koostame uhendused ';
	insert into hoouhendused (isikid, dokid, doktyyp) values (lnIsikId, tnArvId, 'ARVED');
end if;


return  lnReturn;

end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_kinni_hootaabel(integer, integer, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_kinni_hootaabel(integer, integer, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_kinni_hootaabel(integer, integer, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_kinni_hootaabel(integer, integer, integer, integer) TO hkametnik;
GRANT EXECUTE ON FUNCTION sp_kinni_hootaabel(integer, integer, integer, integer) TO soametnik;
