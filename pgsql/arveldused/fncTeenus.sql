-- Function: adk(character varying, integer, integer, date, date)
/*


select fncTeenus(    38534,      115,date(2010,11,1),2)

select fncTeenus(    38534,      115,date(2010,11,1),0)

			lnMaxDay = Day(Gomonth(Date(Year(Date()),Month(Date()),1),1)-1)
select fncTeenus(      447,       81,date(2010,12,1),2)

select * from library where library = 'OBJEKT'

			select LEPING2.*, LEPING1.* from leping2 inner join leping1 on leping1.id = leping2.parentid 
				where leping1.objektId in (select library.id from library INNER join objekt on library.id = objekt.libid 
					where library = 'OBJEKT' and parentid = 453)
				and leping2.nomid = 81 and leping2.status = 1;


*/



--DROP FUNCTION fncTeenus(integer, integer, date);

CREATE OR REPLACE FUNCTION fncTeenus(integer, integer, date, integer)
  RETURNS numeric AS
$BODY$



DECLARE tnObjektId alias for $1;
	tnNomId alias for $2;
	tdKpv alias for $3;
	tnUhis alias for $4;


	lnKogus numeric (14,4);
	lnParentObjektId integer;
	lnHind numeric (14,4);

begin	

	lnKogus = 0;

	if tnUhis = 0 then
		select sum(loppkogus - algkogus) into lnKogus
			from counter inner join library on library.id = counter.parentid 
			where library.tun2 = tnObjektId 
			and library.tun3 = tnNomId 
			and month(counter.kpv) = month(tdKpv) 
			and year(counter.kpv) = year(tdKpv)
			and empty(counter.muud) 
			and library.tun1 = 1;


		lnKogus = ifnull(lnKogus,0);

		if lnKogus = 0 then
			-- otsime lepingu kogus
			select sum(leping2.kogus) into lnKogus from leping2 inner join leping1 on leping1.id = leping2.parentid 
				where leping1.objektId = tnObjektId and leping2.nomid = tnNomId ;
		end if;	
	end if;

	if tnUhis = 1 then
		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select sum(loppkogus - algkogus) into lnKogus
			from counter inner join library on library.id = counter.parentid 
			where (library.tun2 in (select libid from  Objekt where libid = lnParentObjektId))
			and library.tun3 = tnNomId 
			and month(counter.kpv) = month(tdKpv) 
			and year(counter.kpv) = year(tdKpv) 
			and empty(counter.muud) 
			and library.tun1 = 1;

	end if;

	if tnUhis = 2 then
		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
-- * fncTeenuseHind(library.tun2,tnNomId)
		select sum((loppkogus - algkogus) )  into lnKogus
			from counter inner join library on library.id = counter.parentid 
			where library.tun2 in (select library.id from library INNER join objekt on library.id = objekt.libid where library = 'OBJEKT' and parentid = lnParentObjektId) 
			and library.tun3 = tnNomId 
			and month(counter.kpv) = month(tdKpv) 
			and year(counter.kpv) = year(tdKpv)
			and library.tun1 = 1;

--		select fncTeenuseHind(library.tun2,tnNomId) into lnHind from library where library.tun2 in 
--			(select library.id from library INNER join objekt on library.id = objekt.libid 
--			where library = 'OBJEKT' and parentid = lnParentObjektId) 
--			and library.tun3 = tnNomId and library.tun1 = 1;

		lnKogus = ifnull(lnKogus,0);

		if lnKogus = 0 then
			-- otsime lepingu kogus
			select sum(leping2.kogus) into lnKogus from leping2 inner join leping1 on leping1.id = leping2.parentid 
				where leping1.objektId in (select library.id from library INNER join objekt on library.id = objekt.libid 
					where library = 'OBJEKT' and parentid = lnParentObjektId)
				and leping2.nomid = tnNomId ;
		end if;	

			
	end if;

	lnKogus = ifnull(lnKogus,0);
--	raise notice 'kogus %',lnKogus;
--	raise notice 'hind %',lnHind;

	return lnKogus;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fncTeenus(integer, integer, date, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fncTeenus(integer, integer, date, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION fncTeenus(integer, integer, date, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fncTeenus(integer, integer, date, integer) TO dbvaatleja;
