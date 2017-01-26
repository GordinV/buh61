-- Function: sp_del_taotlus(integer, integer)
/*
select fnc_KontoPlaaniKontrol(id) from rekv where parentid < 999
*/

-- DROP FUNCTION sp_del_taotlus(integer, integer);

CREATE OR REPLACE FUNCTION fnc_KontoPlaaniKontrol(integer)
  RETURNS integer AS
$BODY$
declare

	tnRekvId alias for $1;
	v_konto record;
	lnCount integer;
begin
	lnCount = 0;
	if (select count(id) from library where library = 'KONTOD') <> (SELECT COUNT(id) from kontoinf where rekvid = tnRekvId) then
		raise notice 'Vordlus ei tule, kontrollime';
		for v_konto in
			select id, kood from library where library = 'KONTOD'
		loop
			raise notice 'Kontrollin konto %',v_konto.kood;
			if (select count(id) from kontoinf where parentid = v_konto.id and rekvid = tnRekvId) = 0 then
				raise notice 'konf. puudub, lisame';
				lnCount = lnCount + 1;
				insert into kontoinf (parentid, type, formula, aasta, liik, pohikonto, rekvid, algsaldo) values 
				(v_konto.id, 1,0,0,1,'',tnRekvId,0);
			else
				raise notice 'konf. on, edasi';
			end if;
			raise notice 'Kokku lisatud: %',lnCount;
		end loop;
	else
		raise notice 'Korras..';
	end if;
	return lnCount;
	
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;

