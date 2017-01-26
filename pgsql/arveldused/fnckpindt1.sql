-- Function: fnckpindt(integer, integer)

-- DROP FUNCTION fnckpindt(integer, integer);

CREATE OR REPLACE FUNCTION fnckpindt(integer, integer, varchar)
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
		select nait07 into lnKogus
			from objekt 
			where libid = tnObjektId and nait09 = 1;
			
		insert into tmp_fnc_selg (kpv, rekvid, timestamp, nimetus, summa01)
			select date(), 1, tcReturn, library.nimetus, nait07
				from objekt inner join library on library.id = objekt.libid 
				where libid = tnObjektId and nait09 = 1;
			
	end if;
	if tnUhis = 1 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select sum(nait07) into lnKogus
			from objekt
			where objekt.libid = lnParentObjektId and nait09 = 1;

		insert into tmp_fnc_selg (kpv, rekvid, timestamp, nimetus, summa01)
			select date(), 1, tcReturn, library.nimetus, nait07
				from objekt inner join library on library.id = objekt.libid 
			where objekt.libid = lnParentObjektId and nait09 = 1;

	end if;
	if tnUhis = 2 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select sum(nait07) into lnKogus
			from objekt
			where objekt.libid in (select library.id from library INNER join objekt on library.id = objekt.libid 
				where library = 'OBJEKT' and parentid = lnParentObjektId) and nait09 = 1;

		insert into tmp_fnc_selg (kpv, rekvid, timestamp, nimetus, summa01)
			select date(), 1, tcReturn, library.nimetus, nait07
				from objekt inner join library on library.id = objekt.libid 
			where objekt.libid in (select library.id from library INNER join objekt on library.id = objekt.libid 
				where library = 'OBJEKT' and parentid = lnParentObjektId) and nait09 = 1;

	end if;

	lnKogus = ifnull(lnKogus,0);



	return lnKogus;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnckpindt(integer, integer, varchar) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnckpindt(integer, integer, varchar) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION fnckpindt(integer, integer, varchar) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fnckpindt(integer, integer, varchar) TO dbvaatleja;
