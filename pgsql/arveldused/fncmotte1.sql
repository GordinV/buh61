-- Function: fncmotte(integer, integer)

-- DROP FUNCTION fncmotte(integer, integer);

CREATE OR REPLACE FUNCTION fncmotte(integer, integer, varchar)
  RETURNS numeric AS
$BODY$


DECLARE tnObjektId alias for $1;
	tnUhis alias for $2;
	tcReturn alias for $3;

	lnKogus numeric;
	lnParentObjektId integer;

begin	

	lnKogus = 0;
	delete from tmp_fnc_selg where kpv < date();

	if tnUhis = 0 then
		select count(id)  into lnKogus
			from library 
			where tun2 = tnObjektId and library = 'MOTTED';

		insert into tmp_fnc_selg (kpv, rekvid, timestamp, nimetus, summa01)
			select date(), 1, tcReturn, library.nimetus, library.id 
				from objekt inner join library on library.id = objekt.libid 
				where tun2 = tnObjektId and library = 'MOTTED';

			
	end if;
	if tnUhis = 1 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		select count(id)  into lnKogus
			from library 
			where tun2 = lnParentObjektId and library = 'MOTTED';

		insert into tmp_fnc_selg (kpv, rekvid, timestamp, nimetus, summa01)
			select date(), 1, tcReturn, library.nimetus, library.id 
				from objekt inner join library on library.id = objekt.libid 
			where tun2 = lnParentObjektId and library = 'MOTTED';
		
	end if;
	if tnUhis = 2 then

		--seline variant puudub. Koik ajal on null 
		lnKogus = 0;	
	end if;

	lnKogus = ifnull(lnKogus,0);
	
	if lnKogus > 0 then
		lnKogus = 1;
	else
		lnKogus = 0;
	end if;	

	return lnKogus;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fncmotte(integer, integer, varchar) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fncmotte(integer, integer, varchar) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION fncmotte(integer, integer, varchar) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fncmotte(integer, integer, varchar) TO dbvaatleja;
