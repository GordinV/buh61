-- Function: fncteenus(integer, integer, date, integer)
/*
select * from library where kood = 'Kesk 1 - 34'

select fncInimised(43229,3)
-- DROP FUNCTION fncteenus(integer, integer, date, integer);
*/
CREATE OR REPLACE FUNCTION fncInimised(integer, integer)
  RETURNS numeric AS
$BODY$


DECLARE tnObjektId alias for $1;
	tnUhis alias for $2;


	lnKogus numeric;
	lnParentObjektId integer;
	lcTanav varchar(120);

begin	

	lnKogus = 0;

	if tnUhis = 0 then
		select nait02 into lnKogus
			from objekt where libid = tnObjektId;
	end if;
	if tnUhis = 1 then

	--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select sum(nait02) into lnKogus
			from objekt
			where objekt.libid = lnParentObjektId;

	end if;

	if tnUhis = 2 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select sum(nait02) into lnKogus
			from objekt
			where objekt.libid in (select library.id from library INNER join objekt on library.id = objekt.libid 
				where library = 'OBJEKT' and parentid = lnParentObjektId)
				and objekt.libid not in (select tun2 from library where tun1 = 1 );


	end if;

	if tnUhis = 3 then

		--otsime parent objekt
			
		select btrim(left(kood, length(kood)- (strpos(kood,'-')-2)))+'%'::varchar , objekt.nait14::integer into lcTanav, lnParentObjektId from objekt inner join library on library.id = objekt.libid where libid = tnObjektId;
		lcTanav = ifnull(lcTanav,'%');
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select sum(nait02) into lnKogus
			from objekt
			where objekt.libid in (select library.id from library INNER join objekt on library.id = objekt.libid 
				where library = 'OBJEKT' and upper(library.kood) like upper(lcTanav) and nait14 = lnParentObjektId)
				and objekt.libid not in (select tun2 from library where tun1 = 1 );


	end if;

	lnKogus = ifnull(lnKogus,0);



	return lnKogus;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION  fncInimised(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION  fncInimised(integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION  fncInimised(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION  fncInimised(integer, integer) TO dbvaatleja;
