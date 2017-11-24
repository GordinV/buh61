-- Function: fnckpindt(integer, integer)

-- DROP FUNCTION fnckpindt(integer, integer);
/*
select * from library where library = 'OBJEKT' 
and kood = 'Viru 25 - 1'

SELECT fncKorteriKogus(39160, 3)

select  btrim(left(kood, length(kood)- (strpos(kood,'-')-2)))+'%' from library where library = 'OBJEKT' ;


select * from objekt where libid = 466

		select nait03, nait09 from objekt where libid = 466 
		and nait09 = 1;

		select * 
			from objekt
			where objekt.libid in (select library.id from library INNER join objekt on library.id = objekt.libid 
				where library = 'OBJEKT' and nait14 = lnParentObjektId and nait15 > 0) ;
				--and nait09 = 1;
		

*/

CREATE OR REPLACE FUNCTION fncKorteriKogus(integer, integer)
  RETURNS numeric AS
$BODY$


DECLARE tnObjektId alias for $1;
	tnUhis alias for $2;


	lnKogus numeric;
	lnParentObjektId integer;
	lcTanav varchar(254);

begin	

	lnKogus = 0;

	if tnUhis = 0 then
		select nait03 into lnKogus
			from objekt where libid = tnObjektId;
--			 and nait09 = 1;
	end if;
	if tnUhis = 1 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select (nait03) into lnKogus
			from objekt
			where objekt.libid = lnParentObjektId;
			
			-- and nait09 = 1;

	end if;
	if tnUhis = 2 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select sum(nait03) into lnKogus
			from objekt
			where objekt.libid in (select library.id from library INNER join objekt on library.id = objekt.libid 
				where library = 'OBJEKT' and parentid = lnParentObjektId) ;

				--and nait09 = 1;

	end if;
	if tnUhis = 3 then

		--otsime parent objekt
			
		select btrim(left(kood, length(kood)- (strpos(kood,'-')-2)))+'%'::varchar , objekt.nait14::integer into lcTanav, lnParentObjektId from objekt inner join library on library.id = objekt.libid where libid = tnObjektId;
		lcTanav = ifnull(lcTanav,'%');

--		raise notice 'lcTanav %',lcTanav;
--		lcTanav = btrim(left(lcTanav, length(lcTanav)- (strpos(lcTanav,'-')-2)))+'%' ;

		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'lcTanav %',lcTanav;

		
		select count(nait03) into lnKogus
			from objekt
			where objekt.libid in (select library.id from library INNER join objekt on library.id = objekt.libid 
				where library = 'OBJEKT' and library.kood like lcTanav and nait14 = lnParentObjektId and nait15 > 0) ;
				--and nait09 = 1;

	end if;

	lnKogus = ifnull(lnKogus,0);



	return lnKogus;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION fncKorteriKogus(integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION fncKorteriKogus(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fncKorteriKogus(integer, integer) TO dbvaatleja;
