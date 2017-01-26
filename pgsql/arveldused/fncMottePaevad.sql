-- Function: fncteenus(integer, integer, date, integer)
/*

select fncMottePaevad(library.id, 0, date()) from library where library = 'OBJEKT'
-- DROP FUNCTION fncteenus(integer, integer, date, integer);
*/
CREATE OR REPLACE FUNCTION fncMottePaevad(integer, integer, date)
  RETURNS numeric AS
$BODY$


DECLARE tnObjektId alias for $1;
	tnUhis alias for $2;
	tdKpv alias for $3;


	lnKogus numeric;
	lnParentObjektId integer;
	ldKpv date;

begin	
	lnKogus = 0;

	if tnUhis = 0 then
		if (select count(id) from library where library.tun2 = tnObjektId) = 0 then
			-- motte puudub, tagastame kogu kuu
			lnKogus = gomonth(date(year(tdKpv),month(tdKpv),1),1)-1 - (date(year(tdKpv),month(tdKpv),1)-1);
		else
			select sum(counter.paevad)  into lnKogus
				from library inner join counter on library.id = counter.parentid 
				where library.tun2 = tnObjektId and library = 'MOTTED' and year(counter.kpv) = year(tdKpv) and month(counter.kpv) = month(tdKpv);
		end if;
	end if;
	if tnUhis = 1 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		select sum(counter.paevad)  into lnKogus
			from library inner join counter on library.id = counter.parentid 
			where tun2 = lnParentObjektId and library = 'MOTTED' and year(counter.kpv) = year(tdKpv) and month(counter.kpv) = month(tdKpv);
		
	end if;
	if tnUhis = 2 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;

		select sum(counter.paevad)  into lnKogus
			from library inner join counter on library.id = counter.parentid 
			where library.tun2 in (select library.id from library INNER join objekt on library.id = objekt.libid 
				where library = 'OBJEKT' and objekt.parentid = lnParentObjektId);

	end if;

	lnKogus = ifnull(lnKogus,0);
	
	return lnKogus;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION  fncMottePaevad(integer, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION  fncMottePaevad(integer, integer, date) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION  fncMottePaevad(integer, integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION  fncMottePaevad(integer, integer, date) TO dbvaatleja;
