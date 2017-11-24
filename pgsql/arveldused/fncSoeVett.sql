-- Function: fncteenus(integer, integer, date, integer)
/*
select * from objekt

select fnckpind(446,0)
-- DROP FUNCTION fncteenus(integer, integer, date, integer);
*/
CREATE OR REPLACE FUNCTION fncSoeVett(integer, integer)
  RETURNS numeric AS
$BODY$


DECLARE tnObjektId alias for $1;
	tnUhis alias for $2;


	lnKogus numeric;
	lnParentObjektId integer;

begin	

	lnKogus = 0;

	if tnUhis = 0 then
		select nait06 into lnKogus
			from objekt where libid = tnObjektId;
	end if;
	if tnUhis = 1 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select (nait06) into lnKogus
			from objekt
			where objekt.libid = lnParentObjektId;

	end if;
	if tnUhis = 2 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select (nait06) into lnKogus
			from objekt
			where objekt.libid in (select library.id from library INNER join objekt on library.id = objekt.libid 
				where library = 'OBJEKT' and parentid = lnParentObjektId);


	end if;

	lnKogus = ifnull(lnKogus,0);



	return lnKogus;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION   fncSoeVett(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION   fncSoeVett(integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION   fncSoeVett(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION   fncSoeVett(integer, integer) TO dbvaatleja;
