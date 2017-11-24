-- Function: fncteenus(integer, integer, date, integer)

-- DROP FUNCTION fncteenus(integer, integer, date, integer);
/*
select * from nomenklatuur where kood = 'vd2'

select * from nomenklatuur where kood like 'kut%'
select * from library where library = 'OBJEKT' and kood = 'Viru 25 - 1'

select fncteenus(39160, 132, date(2011,02,28), 0)

select * from library where id = 47702
select objekt.nait14::integer  from objekt where libid = 39160;

			select leping2.hind, kogus, leping1.id, leping1.objektId 
				from leping1 inner join leping2 on leping1.id = leping2.parentid
				where leping1.objektId in (select library.id from library INNER join objekt on library.id = objekt.libid 
					where library = 'OBJEKT' and nait14 = 25)
					and leping2.nomid = 115

			select sum(loppkogus - algkogus) 
				from counter inner join library on library.id = counter.parentid 
				where library.tun2 = 39160 
				and library.tun3 = 115 
				and month(counter.kpv) = 2 
				and year(counter.kpv) = 2011
				and library.tun1 = 1;
					


*/



CREATE OR REPLACE FUNCTION fncteenus(integer, integer, date, integer)
  RETURNS numeric AS
$BODY$



DECLARE tnObjektId alias for $1;
	tnNomId alias for $2;
	tdKpv alias for $3;
	tnUhis alias for $4;


	lnKogus numeric (14,4);
	lnParentObjektId integer;
	lnHind numeric (14,4);
	v_lepingud record;
	lnMajaNr integer;

begin	

	lnKogus = 0;

	if tnUhis = 0 then
		select sum(loppkogus - algkogus) into lnKogus
			from counter inner join library on library.id = counter.parentid 
			where library.tun2 = tnObjektId 
			and library.tun3 = tnNomId 
			and month(counter.kpv) = month(tdKpv) 
			and year(counter.kpv) = year(tdKpv)
			and library.tun1 = 1;
--			and empty(counter.muud) 


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
			and library.tun1 = 1;

--			and empty(counter.muud) 

	end if;

	if tnUhis = 2 then
		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

		raise notice 'Parent %',lnParentObjektId;
-- * fncTeenuseHind(library.tun2,tnNomId)

		lnKogus = 0;
		lnHind = 0;
		for v_lepingud in 
			select leping2.hind, kogus, leping1.id, leping1.objektId 
				from leping1 inner join leping2 on leping1.id = leping2.parentid
				where leping1.objektId in (select library.id from library INNER join objekt on library.id = objekt.libid 
					where library = 'OBJEKT' and parentid = lnParentObjektId)
					and leping2.nomid = tnNomId

		loop
			raise notice 'v_lepingud.objektid %',v_lepingud.objektid;
--			lnHind = v_lepingud.hind
					
			select sum(loppkogus - algkogus) into lnKogus
				from counter inner join library on library.id = counter.parentid 
				where library.tun2 = v_lepingud.ObjektId 
				and library.tun3 = tnNomId 
				and month(counter.kpv) = month(tdKpv) 
				and year(counter.kpv) = year(tdKpv)
				and library.tun1 = 1;
				
--				and empty(counter.muud) 
				
			lnKogus = ifnull(lnKogus,0);
			if lnKogus = 0 then
				lnKogus = v_lepingud.kogus;
			end if;
	
			lnHind = lnHind + lnKogus * v_lepingud.hind;	
			raise notice 'lnKogus %',lnKogus;
			raise notice 'v_lepingud.hind %',v_lepingud.hind;
			raise notice 'lnHind %',lnHind;

		end loop;

		lnKogus = ifnull(lnHind,0);	

	end if;

	if tnUhis = 3 then
			
		select objekt.nait14::integer into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select sum(loppkogus - algkogus) into lnKogus
			from counter inner join library on library.id = counter.parentid 
			where (library.tun2 in (select libid from  Objekt where nait14 = lnParentObjektId and nait15 = 0))
			and library.tun3 = tnNomId 
			and month(counter.kpv) = month(tdKpv) 
			and year(counter.kpv) = year(tdKpv) 
			and library.tun1 = 1;

--			and empty(counter.muud) 

		lnKogus = ifnull(lnKogus,0);
--		raise notice 'Kogus : %',lnKogus;

		if lnKogus = 0 then
-- summ koik maja korterid 
--			raise notice 'Otsime koik  : ';
			lnHind = 0;
--			raise notice 'tnNomId %',tnNomId;
--			raise notice 'lnParentObjektId %',lnParentObjektId;
			for v_lepingud in 
				select leping2.hind, kogus, leping1.id, leping1.objektId 
				from leping1 inner join leping2 on leping1.id = leping2.parentid
				where leping1.objektId in (select library.id from library INNER join objekt on library.id = objekt.libid 
					where library = 'OBJEKT' and nait14 = lnParentObjektId)
					and leping2.nomid = tnNomId

			loop
--				raise notice 'v_lepingud.objektid %',v_lepingud.objektid;
--			lnHind = v_lepingud.hind
					
				select sum(loppkogus - algkogus) into lnKogus
				from counter inner join library on library.id = counter.parentid 
				where library.tun2 = v_lepingud.ObjektId 
				and library.tun3 = tnNomId 
				and month(counter.kpv) = month(tdKpv) 
				and year(counter.kpv) = year(tdKpv)
				and library.tun1 = 1;
				
--				and empty(counter.muud) 
				
				lnKogus = ifnull(lnKogus,0);
				if lnKogus = 0 then
					lnKogus = v_lepingud.kogus;
				end if;
	
				lnHind = lnHind + lnKogus * v_lepingud.hind;	
--			raise notice 'lnKogus %',lnKogus;
--			raise notice 'v_lepingud.hind %',v_lepingud.hind;
--			raise notice 'lnHind %',lnHind;

			end loop;

			lnKogus = ifnull(lnHind,0);	

		end if;
	end if;
	
--	raise notice 'kogus %',lnKogus;
--	raise notice 'hind %',lnHind;
	lnKogus = ifnull(lnKogus,0);	

	return lnKogus;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fncteenus(integer, integer, date, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fncteenus(integer, integer, date, integer) TO vlad;
GRANT EXECUTE ON FUNCTION fncteenus(integer, integer, date, integer) TO public;
GRANT EXECUTE ON FUNCTION fncteenus(integer, integer, date, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION fncteenus(integer, integer, date, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fncteenus(integer, integer, date, integer) TO dbvaatleja;
