/*
select * from hooleping

select sp_arvesta_hoolepingujaak(8, 3)
*/


CREATE OR REPLACE FUNCTION sp_arvesta_hoolepingujaak(integer, integer)
  RETURNS numeric AS
$BODY$
declare
	tnHooldekoduid alias for $1;
	tnIsikId alias for $2;

	lnId int; 
	curLeping record;
	lnDeebet numeric (16,2);
	lnKreedit numeric (16,2);
	lnDbKov numeric (16,2);
	lnKrKOV numeric (16,2);

begin
	select * into curLeping from hooLeping where isikId = tnIsikId and hooldekoduid = tnHooldekoduid order by algkpv desc limit 1;
	
	select sum(summa) into lnDeebet 
		from arv inner join hoouhendused hu on (arv.id = hu.dokid and hu.doktyyp = 'ARVED')
		where asutusid = tnHooldekoduid and hu.isikId = tnIsikId;
	lnDeebet = ifnull(lnDeebet,0);

	select sum(summa) into lnDbKov 
		from arv inner join hoouhendused hu on (arv.id = hu.dokid and hu.doktyyp = 'ARVED')
		where asutusid = curLeping.omavalitsusId and hu.isikId = tnIsikId;
	lnDbKov = ifnull(lnDbKov,0);

	select sum(summa) into lnKreedit from arvtasu 
		where arvid in (select arv.id from arv inner join hoouhendused hu on (arv.id = hu.dokid and hu.doktyyp = 'ARVED')
		where asutusid = tnHooldekoduid and hu.isikId = tnIsikId);	
	lnKreedit = ifnull(lnKreedit,0);

	select sum(summa) into lnKrKov from arvtasu 
		where arvid in (select arv.id from arv inner join hoouhendused hu on (arv.id = hu.dokid and hu.doktyyp = 'ARVED')
		where asutusid = curLeping.omavalitsusId and hu.isikId = tnIsikId);	
	lnKrKov = ifnull(lnKrKov,0);

	-- uuendame lepingujaak

	update hooleping set jaak = lnDeebet - lnKreedit, kovjaak = lnDbKov - lnKrKov where hooldekoduid = tnHooldekoduid and isikid = tnIsikId;
	
return  (lnDeebet - lnKreedit);

end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION sp_arvesta_hoolepingujaak(integer, integer) TO soametnik;
GRANT EXECUTE ON FUNCTION sp_arvesta_hoolepingujaak(integer, integer) TO hkametnik;
