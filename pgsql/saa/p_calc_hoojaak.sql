-- Function: sp_calc_palk_jaak(integer, integer, integer)
-- DROP FUNCTION sp_calc_palk_jaak(integer, integer, integer);
/*
select sp_calc_hoojaak(3)

update hoojaak set pension85 = 85 where isikid = 3

		select sum(summa) as summa, allikas 
			from 
				(select tyyp, case when ltrim(rtrim(tyyp)) = 'TULUD' then summa else -1*summa end as summa, allikas 
				from hootehingud where isikid = 3) tmp 
			group by allikas


*/

CREATE OR REPLACE FUNCTION sp_calc_hoojaak(integer)
  RETURNS smallint AS
$BODY$
declare 	tnisikId alias for $1;
	lnpension85 numeric(16,2);
	lnpension15 numeric(16,2);
	lntoetus numeric(16,2);
	lnvara numeric(16,2);
	lnomavalitsus numeric(16,2);
	lnlaen numeric(16,2);
	lnmuud numeric(16,2);
	lnid int;
	v_hoojaak record;
begin
	-- leiame jaagirea
	if (select count(id) from hoojaak where isikid = tnIsikId) = 0 then
		insert into hoojaak (isikid,pension85,pension15,toetus,vara,omavalitsus,laen, muud) 
			values (tnIsikid,0,0,0,0,0,0,0);
	end if;

	lnpension85 = 0;
	lnPension15 = 0;
	lnToetus = 0;
	lnVara = 0;
	lnOmavalitsus = 0;
	lnLaen = 0;
	lnMuud = 0;	
	for v_hoojaak in
		select sum(summa) as summa, allikas 
			from 
				(select tyyp, case when ltrim(rtrim(tyyp)) = 'TULUD' then summa else -1*summa end as summa, allikas 
				from hootehingud where isikid = tnIsikId) tmp 
			group by allikas

	loop
		if ltrim(rtrim(v_hoojaak.allikas)) = 'PENSION85' then
			raise notice ' leitud 85';
			lnpension85 = v_hoojaak.summa;
		end if;
		if ltrim(rtrim(v_hoojaak.allikas)) = 'PENSION15' then
			raise notice ' leitud 15 ';
			lnpension15 = v_hoojaak.summa;
		end if;
		if ltrim(rtrim(v_hoojaak.allikas)) = 'TOETUS' then
			lnToetus = v_hoojaak.summa;
		end if;
		if ltrim(rtrim(v_hoojaak.allikas)) = 'VARA' then
			lnVara = v_hoojaak.summa;
		end if;
		if ltrim(rtrim(v_hoojaak.allikas)) = 'OMAVALITSUS' then
			lnOmavalitsus = v_hoojaak.summa;
		end if;
		if ltrim(rtrim(v_hoojaak.allikas)) = 'LAEN' then
			lnlaen = v_hoojaak.summa;
		end if;
		if ltrim(rtrim(v_hoojaak.allikas)) = 'MUUD' then
			lnMuud = v_hoojaak.summa;
		end if;
	end loop;
	raise notice 'lnpension85 %',lnpension85;
	raise notice 'tnisikId %',tnisikId;
	update hoojaak set pension85 = lnpension85,
		pension15 = lnPension15,
		toetus = lnToetus,
		vara = lnVara,
		omavalitsus = lnOmavalitsus,
		laen = lnLaen, 
		muud = lnMuud 
		where isikId = tnisikId;
	return 1;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_hoojaak(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_hoojaak(integer) TO hkametnik;
GRANT EXECUTE ON FUNCTION sp_calc_hoojaak(integer) TO soametnik;
