-- Function: fnckpinda(integer, integer)

-- DROP FUNCTION fnckpinda(integer, integer);

CREATE OR REPLACE FUNCTION fnckpinda(integer, integer, varchar)
  RETURNS numeric AS
$BODY$


DECLARE tnObjektId alias for $1;
	tnUhis alias for $2;
	tcreturn alias for $3;


	lnKogus numeric;
	lnParentObjektId integer;

begin	

	lnKogus = 0;

	if tnUhis = 0 then
		select nait07 into lnKogus
			from objekt 
			where libid = tnObjektId and nait09 = 0;

		insert into tmp_fnc_selg (kpv, rekvid, timestamp, nimetus, summa01)
			select date(), 1, tcReturn, library.nimetus, nait07 
				from objekt inner join library on library.id = objekt.libid 
				where libid = tnObjektId;

	end if;
	if tnUhis = 1 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select sum(nait07) into lnKogus
			from objekt
			where objekt.libid = lnParentObjektId and nait09 = 0;

		insert into tmp_fnc_selg (kpv, rekvid, timestamp, nimetus, summa01)
			select date(), 1, tcReturn, library.nimetus, nait07 
				from objekt inner join library on library.id = objekt.libid 
			where objekt.libid = lnParentObjektId and nait09 = 0;


	end if;
	if tnUhis = 2 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select sum(nait07) into lnKogus
			from objekt
			where objekt.libid in (select library.id from library INNER join objekt on library.id = objekt.libid 
				where library = 'OBJEKT' and parentid = lnParentObjektId) and nait09 = 0;

		insert into tmp_fnc_selg (kpv, rekvid, timestamp, nimetus, summa01)
			select date(), 1, tcReturn, library.nimetus, nait07 
				from objekt inner join library on library.id = objekt.libid 
			where objekt.libid in (select library.id from library INNER join objekt on library.id = objekt.libid 
				where library = 'OBJEKT' and parentid = lnParentObjektId) and nait09 = 0;

	end if;

	lnKogus = ifnull(lnKogus,0);



	return lnKogus;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnckpinda(integer, integer, varchar) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnckpinda(integer, integer, varchar) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION fnckpinda(integer, integer, varchar) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fnckpinda(integer, integer, varchar) TO dbvaatleja;
