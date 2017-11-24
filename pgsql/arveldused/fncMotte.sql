-- Function: fncteenus(integer, integer, date, integer)
/*
select * from objekt

select fnckpind(446,0)
-- DROP FUNCTION fncteenus(integer, integer, date, integer);
*/
CREATE OR REPLACE FUNCTION fncMotte(integer, integer)
  RETURNS numeric AS
$BODY$


DECLARE tnObjektId alias for $1;
	tnUhis alias for $2;


	lnKogus numeric;
	lnParentObjektId integer;

begin	

	lnKogus = 0;

	if tnUhis = 0 then
		select count(id)  into lnKogus
			from library where tun2 = tnObjektId and library = 'MOTTED';
	end if;
	if tnUhis = 1 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		select count(id)  into lnKogus
			from library where tun2 = lnParentObjektId and library = 'MOTTED';
		
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
ALTER FUNCTION   fncMotte(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION   fncMotte(integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION  fncMotte(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION   fncMotte(integer, integer) TO dbvaatleja;
