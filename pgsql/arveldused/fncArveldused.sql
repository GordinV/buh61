-- Function: fncteenus(integer, integer, date, integer)
/*
select * from objekt

select fnckpind(446,0)
-- DROP FUNCTION fncteenus(integer, integer, date, integer);
*/
CREATE OR REPLACE FUNCTION fncInimised(integer, integer)
  RETURNS numeric AS
$BODY$


DECLARE tnObjektId alias for $1;
	tnUhis alias for $2;


	lnKogus numeric;
	lnParentObjektId integer;

begin	

	lnKogus = 0;

	if tnUhis = 0 then
		select nait02 into lnKogus
			from objekt where libid = tnObjektId;
	else

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select sum(nait02) into lnKogus
			from objekt
			where objekt.libid = lnParentObjektId;

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

-- Function: fncteenus(integer, integer, date, integer)
/*
select * from objekt

select fnckpind(446,0)
-- DROP FUNCTION fncteenus(integer, integer, date, integer);
*/
CREATE OR REPLACE FUNCTION fncK(integer, integer)
  RETURNS numeric AS
$BODY$


DECLARE tnObjektId alias for $1;
	tnUhis alias for $2;


	lnKogus numeric;
	lnParentObjektId integer;

begin	

	lnKogus = 0;

	if tnUhis = 0 then
		select nait04 into lnKogus
			from objekt where libid = tnObjektId;
	end if;
	
	if tnUhis = 1 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select sum(nait04) into lnKogus
			from objekt
			where objekt.libid = lnParentObjektId;

	end if;

	if tnUhis = 2 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select sum(nait04) into lnKogus
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
ALTER FUNCTION  fncK(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION  fncK(integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION  fncK(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION  fncK(integer, integer) TO dbvaatleja;

-- Function: fncteenus(integer, integer, date, integer)
/*
select * from objekt

select fnckpind(446,0)
-- DROP FUNCTION fncteenus(integer, integer, date, integer);
*/
CREATE OR REPLACE FUNCTION fncKateRatt(integer, integer)
  RETURNS numeric AS
$BODY$


DECLARE tnObjektId alias for $1;
	tnUhis alias for $2;


	lnKogus numeric;
	lnParentObjektId integer;

begin	

	lnKogus = 0;

	if tnUhis = 0 then
		select nait10 into lnKogus
			from objekt where libid = tnObjektId;
	end if;
	if tnUhis = 1 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select (nait10) into lnKogus
			from objekt
			where objekt.libid = lnParentObjektId;

	end if;
	if tnUhis = 2 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select (nait10) into lnKogus
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
ALTER FUNCTION   fncKateRatt(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION   fncKateRatt(integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION   fncKateRatt(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION   fncKateRatt(integer, integer) TO dbvaatleja;

-- Function: fncteenus(integer, integer, date, integer)
/*
select * from objekt

select fnckpind(446,0)
-- DROP FUNCTION fncteenus(integer, integer, date, integer);
*/
CREATE OR REPLACE FUNCTION fncKeskKutte(integer, integer)
  RETURNS numeric AS
$BODY$


DECLARE tnObjektId alias for $1;
	tnUhis alias for $2;


	lnKogus numeric;
	lnParentObjektId integer;

begin	

	lnKogus = 0;

	if tnUhis = 0 then
		select nait09 into lnKogus
			from objekt where libid = tnObjektId;
	end if;
	if tnUhis = 1 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select (nait09) into lnKogus
			from objekt
			where objekt.libid = lnParentObjektId;

	end if;
	if tnUhis = 2 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select (nait09) into lnKogus
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
ALTER FUNCTION   fncKeskKutte(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION   fncKeskKutte(integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION   fncKeskKutte(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION   fncKeskKutte(integer, integer) TO dbvaatleja;

-- Function: fncteenus(integer, integer, date, integer)
/*
select * from objekt

select fnckpind(453,1)
-- DROP FUNCTION fncteenus(integer, integer, date, integer);
*/
CREATE OR REPLACE FUNCTION fnckpind(integer, integer)
  RETURNS numeric AS
$BODY$


DECLARE tnObjektId alias for $1;
	tnUhis alias for $2;


	lnKogus numeric;
	lnParentObjektId integer;

begin	

	lnKogus = 0;

	if tnUhis = 0 then
		select nait07 into lnKogus
			from objekt where libid = tnObjektId;
	end if;
	if tnUhis = 1 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select sum(nait07) into lnKogus
			from objekt
			where objekt.libid = lnParentObjektId;

	end if;
	if tnUhis = 2 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select sum(nait07) into lnKogus
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
ALTER FUNCTION  fnckpind(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION  fnckpind(integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION  fnckpind(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION  fnckpind(integer, integer) TO dbvaatleja;

-- Function: fncteenus(integer, integer, date, integer)
/*
select * from objekt

select fnckpind(453,1)
-- DROP FUNCTION fncteenus(integer, integer, date, integer);
*/
CREATE OR REPLACE FUNCTION fnckpindA(integer, integer)
  RETURNS numeric AS
$BODY$


DECLARE tnObjektId alias for $1;
	tnUhis alias for $2;


	lnKogus numeric;
	lnParentObjektId integer;

begin	

	lnKogus = 0;

	if tnUhis = 0 then
		select nait07 into lnKogus
			from objekt where libid = tnObjektId and nait09 = 0;
	end if;
	if tnUhis = 1 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select sum(nait07) into lnKogus
			from objekt
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

	end if;

	lnKogus = ifnull(lnKogus,0);



	return lnKogus;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION  fnckpindA(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION  fnckpindA(integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION  fnckpindA(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION  fnckpindA(integer, integer) TO dbvaatleja;

-- Function: fncteenus(integer, integer, date, integer)
/*
select * from objekt

select fnckpind(453,1)
-- DROP FUNCTION fncteenus(integer, integer, date, integer);
*/
CREATE OR REPLACE FUNCTION fnckpindT(integer, integer)
  RETURNS numeric AS
$BODY$


DECLARE tnObjektId alias for $1;
	tnUhis alias for $2;


	lnKogus numeric;
	lnParentObjektId integer;

begin	

	lnKogus = 0;

	if tnUhis = 0 then
		select nait07 into lnKogus
			from objekt where libid = tnObjektId and nait09 = 1;
	end if;
	if tnUhis = 1 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select sum(nait07) into lnKogus
			from objekt
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

	end if;

	lnKogus = ifnull(lnKogus,0);



	return lnKogus;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION  fnckpindT(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION  fnckpindT(integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION  fnckpindT(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION  fnckpindT(integer, integer) TO dbvaatleja;

-- Function: fncteenus(integer, integer, date, integer)
/*
select * from objekt

select fnckpind(446,0)
-- DROP FUNCTION fncteenus(integer, integer, date, integer);
*/
CREATE OR REPLACE FUNCTION fncMotteViimaneNait(integer)
  RETURNS numeric AS
$BODY$


DECLARE tnParentId alias for $1;


	lnKogus numeric;
	lnParentObjektId integer;

begin	

	lnKogus = 0;

	select loppkogus into lnKogus from counter where parentid = tnParentId order by kpv desc limit 1;

	lnKogus = ifnull(lnKogus,0);


	return lnKogus;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION  fncMotteViimaneNait(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION  fncMotteViimaneNait(integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION  fncMotteViimaneNait(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION  fncMotteViimaneNait(integer) TO dbvaatleja;

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

		raise notice 'Parent %',lnParentObjektId;
		
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

		raise notice 'Parent %',lnParentObjektId;
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
/*
	IF lnKogus = 0 and tnUhis = 0 then
		--otsime mõtted, kui puuduvad, siis paneme kogus = 1
		if 	(select count(*)
			from counter inner join library on library.id = counter.parentid 
			where library.tun2 = tnObjektId 
			and library.tun3 = tnNomId
			and library.tun1 = 1) = 0 then

			lnKogus = 0;
			
		end if;	

	end if;	
	IF lnKogus = 0 and tnUhis = 1 then
		--otsile mõtted, kui puuduvad, siis paneme kogus = 1
		if 	(select count(*)
			from counter inner join library on library.id = counter.parentid 
			where (library.tun2 in (select libid from  Objekt where libid = lnParentObjektId))
			and library.tun3 = tnNomId
			and library.tun1 = 1) = 0 then

			lnKogus = 0;
			
		end if;	

	end if;	
*/

	return lnKogus;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fncTeenus(integer, integer, date, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fncTeenus(integer, integer, date, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION fncTeenus(integer, integer, date, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fncTeenus(integer, integer, date, integer) TO dbvaatleja;

--DROP FUNCTION fncTeenus(integer, integer, date);
/*
select * from library where library = 'OBJEKT'
SELECT * FROM Nomenklatuur where kood = 'DET'

SELECT fncTeenuseHind(462, 48)
*/
CREATE OR REPLACE FUNCTION fncTeenuseHind(integer, integer)
  RETURNS numeric AS
$BODY$



DECLARE tnObjektId alias for $1;
	tnNomId alias for $2;


	lnHind numeric (14,4);

begin	
	lnHind = 0;

	select hind into lnHind from leping2 inner join leping1 on leping1.id = leping2.parentid where objektid = tnObjektId and leping2.nomid = tnNomId order by leping1.id desc limit 1;

	lnHind = ifnull(lnHind,0);
	

	return lnHind;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fncTeenuseHind(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fncTeenuseHind(integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION fncTeenuseHind(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fncTeenuseHind(integer, integer) TO dbvaatleja;


-- Function: fncteenus(integer, integer, date, integer)
/*
select * from objekt

select fnckpind(446,0)
-- DROP FUNCTION fncteenus(integer, integer, date, integer);
*/
CREATE OR REPLACE FUNCTION fncTorud(integer, integer)
  RETURNS numeric AS
$BODY$


DECLARE tnObjektId alias for $1;
	tnUhis alias for $2;


	lnKogus numeric;
	lnParentObjektId integer;

begin	

	lnKogus = 0;

	if tnUhis = 0 then
		select nait05 into lnKogus
			from objekt where libid = tnObjektId;
	end if;
	if tnUhis = 1 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select sum(nait05) into lnKogus
			from objekt
			where objekt.libid = lnParentObjektId;

	end if;
	if tnUhis = 2 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select sum(nait05) into lnKogus
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
ALTER FUNCTION  fncTorud(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION  fncTorud(integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION  fncTorud(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION  fncTorud(integer, integer) TO dbvaatleja;

-- Function: fncteenus(integer, integer, date, integer)
/*
select * from objekt

select fnckpind(446,0)
-- DROP FUNCTION fncteenus(integer, integer, date, integer);
*/
CREATE OR REPLACE FUNCTION fncVeeRingVool(integer, integer)
  RETURNS numeric AS
$BODY$


DECLARE tnObjektId alias for $1;
	tnUhis alias for $2;


	lnKogus numeric;
	lnParentObjektId integer;

begin	

	lnKogus = 0;

	if tnUhis = 0 then
		select nait11 into lnKogus
			from objekt where libid = tnObjektId;
	end if;
	if tnUhis = 1 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select (nait11) into lnKogus
			from objekt
			where objekt.libid = lnParentObjektId;

	end if;
	if tnUhis = 2 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select (nait11) into lnKogus
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
ALTER FUNCTION   fncVeeRingVool(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION   fncVeeRingVool(integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION   fncVeeRingVool(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION   fncVeeRingVool(integer, integer) TO dbvaatleja;

-- Function: fncteenus(integer, integer, date, integer)
/*
select * from objekt

select fncVK(446,1)
-- DROP FUNCTION fncteenus(integer, integer, date, integer);
*/
CREATE OR REPLACE FUNCTION fncVK(integer, integer)
  RETURNS numeric AS
$BODY$


DECLARE tnObjektId alias for $1;
	tnUhis alias for $2;


	lnKogus numeric;
	lnParentObjektId integer;

begin	

	lnKogus = 0;

	if tnUhis = 0 then
		select nait08 into lnKogus
			from objekt where libid = tnObjektId;
	end if;
	if tnUhis = 1 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select sum(nait08) into lnKogus
			from objekt
			where objekt.libid = lnParentObjektId;

	end if;
	if tnUhis = 2 then

		--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select sum(nait08) into lnKogus
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
ALTER FUNCTION  fncVK(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION  fncVK(integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION  fncVK(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION  fncVK(integer, integer) TO dbvaatleja;

-- Function: gen_lausend_arv(integer)

-- DROP FUNCTION gen_lausend_arv(integer);

CREATE OR REPLACE FUNCTION gen_lausend_arv(integer)
  RETURNS integer AS
$BODY$
declare 
	tnId alias for $1;

	lnJournalNumber int4;
	lcDbKonto varchar(20);
	lcKrKonto varchar(20);
	lcDbTp varchar(20);
	lcKrTp varchar(20);
	lcKood5 varchar(20);
	lnAsutusId int4;
	lnJournal int4;
	lcKbmTp varchar(20);
	lcDbKbmTp varchar(20);
	v_arv arv%rowtype;
	v_dokprop dokprop%rowtype;
	v_aa aa%rowtype;
	v_arv1 record;
	v_asutus asutus%rowtype;
	lnUserId int;
	lnKontrol int;
	lcAllikas varchar(20);
	lcviga varchar;
	lnJournal1 int;
	lcOmaTP varchar(20);
	lcValuuta varchar(20);
	lnKuurs numeric (14,4);
begin


	select * into v_arv from arv where id = tnId;
	If v_arv.doklausid = 0 then
		Return 0;
	End if;

	select recalc into lnKontrol from rekv where id = v_arv.rekvid;
	if v_arv.rekvid > 1 then
		lcAllikas = 'LE-P';
	end if;
--	raise notice 'lnKontrol: %',lnKontrol;

	select * into v_dokprop from dokprop where id = v_arv.doklausid limit 1;
	If not Found or v_dokprop.registr = 0 then
		Return 0;
	End if;

	If v_arv.journalid > 0 then
		update arv set journalId = 0 where id = v_arv.id;
		select number into lnJournalNumber from journalId where journalId = v_arv.journalId;
		if ifnull(lnJournalNumber,0) > 0 then
			if sp_del_journal(v_arv.journalid,1) = 0 then
				Return 0;
			End if;
		end if;
	End if;
	select * into v_aa from aa where parentid = v_arv.rekvId limit 1;	
	select id into lnUserId from userid where userid.rekvid = v_arv.rekvid and userid.kasutaja = CURRENT_USER::varchar;

	lnJournal:= sp_salvesta_journal(0, v_arv.rekvId, v_arv.UserId, v_arv.kpv, v_arv.asutusId, ltrim(rtrim(v_dokprop.selg))+' '+ltrim(rtrim(v_arv.lisa)), 
		v_arv.number,space(1),v_arv.id, v_arv.objekt) ;

--	lisatud 01/02/2005
	Select tp into lcDbKbmTp from asutus where id = v_arv.Asutusid;
	lcDbKbmTp:= ifnull(lcDbKbmTp,'800599');
	lcKrTp:=ifnull(lcDbKbmTp,'800599');
	for v_arv1 in 
		select arv1.*, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs 
			from arv1 left outer join dokvaluuta1 on (arv1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 2) 
			where arv1.parentid = v_arv.Id
	loop
	--	lisatud 18/03/2005
		if not empty(v_arv1.tp) then 
			lcDbKbmTp:= v_arv1.tp;
		end if;
		if not empty(v_arv1.kood2) then
				lcAllikas = v_arv1.kood2;
		end if;
		lcKood5 = v_arv1.kood5;

		If v_arv.liik = 0 then
			if v_arv.objektId = 0 then
				if left(ltrim(rtrim(v_dokprop.konto)),6) = '103701' then
					lcDbKbmTp:= '014003';
				end if;

				lnJournal1 = sp_salvesta_journal1(0,lnJournal,v_arv1.kbmta,''::varchar,''::text,
					v_arv1.kood1,v_arv1.kood2,v_arv1.kood3,v_arv1.kood4,v_arv1.kood5,
					v_dokprop.konto,lcDbKbmTp,v_arv1.konto,lcDbKbmTp,v_arv1.valuuta,v_arv1.kuurs,v_arv1.kbmta*v_arv1.kuurs,
					v_arv1.tunnus,v_arv1.proj);

				-- kbm
				If v_arv1.kbm <> 0 then
					lnJournal1 = sp_salvesta_journal1(0,lnJournal,v_arv1.kbm,''::varchar,''::text,
						v_arv1.kood1,lcAllikas,v_arv1.kood3,v_arv1.kood4,lckood5,
						v_dokprop.konto,lcDbKbmTp,v_dokprop.kbmkonto,'014003',v_arv1.valuuta,v_arv1.kuurs,v_arv1.kbm*v_arv1.kuurs,
						v_arv1.tunnus,v_arv1.proj);
				END IF;
			else
				--	lisatud 30/12/2004 (mahakandmine)				

				if left(ltrim(rtrim(v_arv1.konto)),6) = '103701' then
					lcDbKbmTp:= '014003';
				end if;

				lnJournal1 = sp_salvesta_journal1(0,lnJournal,v_arv1.kbmta,''::varchar,''::text,
					v_arv1.kood1,lcAllikas,v_arv1.kood3,v_arv1.kood4,lckood5,
					v_arv1.konto,ifnull(v_asutus.tp,'800599'),v_dokprop.konto,ifnull(v_asutus.tp,'800599'),v_arv1.valuuta,v_arv1.kuurs,v_arv1.kbmta*v_arv1.kuurs,
					v_arv1.tunnus,v_arv1.proj);

/*
				Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, 
					kood3, kood4, kood5, tunnus, proj) Values 
					(lnJournal, v_arv1.kbmta, v_arv1.konto,  v_dokprop.konto, ifnull(v_asutus.tp,'800599'), ifnull(v_asutus.tp,'800599'), v_arv1.kood1,
					lcAllikas, v_arv1.kood3, v_arv1.kood4, lcKood5, v_arv1.tunnus, v_arv1.proj );
*/
				-- kbm
				If v_arv1.kbm <> 0 then

					lnJournal1 = sp_salvesta_journal1(0,lnJournal,v_arv1.kbm,''::varchar,''::text,
						v_arv1.kood1,lcAllikas,v_arv1.kood3,v_arv1.kood4,lckood5,
						v_dokprop.kbmkonto,'014003',v_dokprop.konto,ifnull(v_asutus.tp,'800599'),v_arv1.valuuta,v_arv1.kuurs,v_arv1.kbm*v_arv1.kuurs,
						v_arv1.tunnus,v_arv1.proj);

/*
					Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, 
						kood3, kood4, kood5, tunnus, proj) Values 
						(lnJournal, v_arv1.kbmta, v_dokprop.kbmkonto,  v_dokprop.konto, '014003', ifnull(v_asutus.tp,'800599'), v_arv1.kood1,
						lcAllikas, v_arv1.kood3, v_arv1.kood4, lcKood5, v_arv1.tunnus, v_arv1.proj );
*/
				end if;
			end if;

		
		Else
			if v_arv1.konto = '601000' or v_arv1.konto = '203000' then
				lcDbKbmTp := '014003';
			end if;
			if left(ltrim(rtrim(v_arv1.konto)),6) = '103701' then
				lcDbKbmTp:= '014003';
			end if;
			

			if lnKontrol = 1 then

				lcViga = sp_lausendikontrol(v_arv1.konto, v_dokprop.konto,  lcDbKbmTp, lcKrTp,v_arv1.kood1, lcAllikas, lckood5, v_arv1.kood3, 
							lcOmaTP, v_arv.Kpv);
				if left(ltrim(rtrim(lcViga)),4) = 'Viga' then
					raise exception ':%',lcViga;
				end if;
			end if;	

			lnJournal1 = sp_salvesta_journal1(0,lnJournal,v_arv1.kbmta,''::varchar,''::text,
					v_arv1.kood1,lcAllikas,v_arv1.kood3,v_arv1.kood4,lckood5,
					v_arv1.konto,lcDbKbmTp,v_dokprop.konto,lcKrTp,v_arv1.valuuta,v_arv1.kuurs,v_arv1.kbmta*v_arv1.kuurs,
					v_arv1.tunnus,v_arv1.proj);

/*
			Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, 
				kood3, kood4, kood5, tunnus, proj) Values 
				(lnJournal, v_arv1.kbmta, v_arv1.konto,  v_dokprop.konto, lcDbKbmTp, lcKrTp, v_arv1.kood1,
				lcAllikas, v_arv1.kood3, v_arv1.kood4, lckood5, v_arv1.tunnus, v_arv1.proj );
*/
			-- kbm
			If v_arv1.kbm <> 0 then

				lnJournal1 = sp_salvesta_journal1(0,lnJournal,v_arv1.kbm,''::varchar,''::text,
						v_arv1.kood1,lcAllikas,v_arv1.kood3,v_arv1.kood4,lckood5,
						v_dokprop.kbmkonto,'014003',v_dokprop.konto, lcKrTp,v_arv1.valuuta,v_arv1.kuurs,v_arv1.kbm*v_arv1.kuurs,
						v_arv1.tunnus,v_arv1.proj);

/*
				Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, 
					kood3, kood4, kood5, tunnus, proj) Values 
					(lnJournal, v_arv1.kbm, v_dokprop.kbmkonto,  v_dokprop.konto, '014003', lcKrTp, v_arv1.kood1,
					lcAllikas, v_arv1.kood3, v_arv1.kood4, lckood5, v_arv1.tunnus, v_arv1.proj );
*/
			end if;
		End if;
	End loop;

	update arv set journalId = lnJournal where id = v_arv.id;
	If v_arv.journalid > 0 and ifnull(lnJournalNumber,0) > 0 then
		update journalid set number = lnJournalNumber where journalid = lnJournal;
	end if;
--	commit;
	return lnJournal;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION gen_lausend_arv(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION gen_lausend_arv(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_arv(integer) TO dbpeakasutaja;

-- Function: sp_del_arved(integer, integer)

/*
select sp_del_arved(503, 0)
select * from nomenklatuur where id = 58

	select count(*)  from pg_stat_all_tables where UPPER(relname) = 'COUNTER';

		update counter set muud = ''  where ifnull(muud,'null') <> 'null' and muud = ltrim(rtrim(str(26842)));
	
select * from counter

*/

-- DROP FUNCTION sp_del_arved(integer, integer);

CREATE OR REPLACE FUNCTION sp_del_arved(integer, integer)
  RETURNS smallint AS
$BODY$


declare 


	tnId alias for $1;
	lnCount int;



begin


	DELETE FROM arv WHERE id = tnid;

	-- arveldused
	select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'COUNTER';
	if ifnull(lnCount,0) > 0 then
		update counter set muud = null where ifnull(muud,'null') <> 'null' and muud = ltrim(rtrim(str(tnid)));
	end if; 

	
	Return 1;


end; 


$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_del_arved(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_del_arved(integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_del_arved(integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_del_arved(integer, integer) TO dbkasutaja;


/*
select sp_salvesta_counter(0::int,451::int,date(2010,11,20),0.0000::numeric,100.0000::numeric,''::text)
*/

CREATE OR REPLACE  FUNCTION sp_salvesta_counter(integer, integer,date,numeric,numeric,text)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnparentid alias for $2;
	tdKpv alias for $3;
	tnAlgkogus alias for $4;
	tnLoppKogus alias for $5;
	ttMuud alias for $6;
	lnLastNait numeric(14,4);


	lnId int; 
--	lrCurRec record;
begin

	if tnId = 0 then
			-- lisame uus kiri
		insert into counter (parentid, kpv, algkogus, loppkogus, muud)
			values (tnparentid, tdkpv, tnalgkogus, tnloppkogus, ttmuud);
	else
		update counter set
			kpv = tdKpv,
			algkogus = tnAlgKogus,
			loppkogus = tnLoppKogus,
			muud = ttMuud
		where id = tnId;

	end if;
	
	select loppkogus into lnLastNait from counter where parentid = tnParentid order by kpv desc limit 1;

	lnLastNait = ifnull(lnLastNait,tnLoppKogus);
	
	update library set tun5 = lnLastNait where id = tnParentId;


         return  tnId;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_counter(integer, integer,date,numeric,numeric,text) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_counter(integer, integer,date,numeric,numeric,text) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_counter(integer, integer,date,numeric,numeric,text) TO dbpeakasutaja;

-- Function: sp_salvesta_journal(integer, integer, integer, date, integer, text, character, text, integer)

-- DROP FUNCTION sp_salvesta_journal(integer, integer, integer, date, integer, text, character, text, integer);

CREATE OR REPLACE FUNCTION sp_salvesta_journal(integer, integer, integer, date, integer, text, character, text, integer, character)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tnuserid alias for $3;
	tdkpv alias for $4;
	tnasutusid alias for $5;
	ttselg alias for $6;
	tcdok alias for $7;
	ttmuud alias for $8;
	tndokid alias for $9;
	tcObjekt alias for $10;
	lnjournalId int;
	lnId int; 
	lrCurRec record;
begin

if (fnc_aasta_kontrol(tnrekvid, tdkpv)= 0) then
	raise exception 'Perion on kinnitatud';
	return 0;
end if;


if tnId = 0 then
	-- uus kiri
	insert into journal (rekvid,userid,kpv,asutusid,selg,dok,muud,dokid, objekt) 
		values (tnrekvid,tnuserid,tdkpv,tnasutusid,ttselg+' ',tcdok,ttmuud,tndokid,ifnull(tcObjekt,space(20)) );


	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
	--	raise notice 'lnId %',lnId;
		lnjournalId:= cast(CURRVAL('public.journal_id_seq') as int4);
	--	raise notice 'lnaastaId %',lnaastaId;
	else
		lnjournalId = 0;
	end if;

	if lnjournalId = 0 then
		raise exception ':%','Ei saa lisada kiri';
	end if;


--	lnjournalId:= cast(CURRVAL('public.journal_id_seq') as int4);

else
	-- muuda 
	select * into lrCurRec from journal where id = tnId;
	if lrCurRec.rekvid <> tnrekvid or lrCurRec.userid <> tnuserid or lrCurRec.kpv <> tdkpv or lrCurRec.asutusid <> tnasutusid 
		or lrCurRec.selg <> ttselg or lrCurRec.dok <> tcdok or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) 
		or lrCurRec.dokid <> tndokid or lrCurRec.objekt <> tcObjekt then 
	update journal set 
		rekvid = tnrekvid,
		userid = tnuserid,
		kpv = tdkpv,
		asutusid = tnasutusid,
		selg = ttselg,
		dok = tcdok,
		objekt = tcObjekt,
		muud = ttmuud,
		dokid = tndokid
	where id = tnId;
	end if;
	lnjournalId := tnId;
end if;



         return  lnjournalId;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_journal(integer, integer, integer, date, integer, text, character, text, integer, character) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_journal(integer, integer, integer, date, integer, text, character, text, integer, character) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_journal(integer, integer, integer, date, integer, text, character, text, integer, character) TO dbpeakasutaja;


-- Function: sp_salvesta_leping1(integer, integer, integer, integer, character, date, date, text, text, text)

-- DROP FUNCTION sp_salvesta_leping1(integer, integer, integer, integer, character, date, date, text, text, text);

CREATE OR REPLACE FUNCTION sp_salvesta_leping1(integer, integer, integer, integer, character, date, date, text, text, text, integer, integer)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnasutusid alias for $2;
	tnrekvid alias for $3;
	tndoklausid alias for $4;
	tcnumber alias for $5;
	tdkpv alias for $6;
	tdtahtaeg alias for $7;
	ttselgitus alias for $8;
	ttdok alias for $9;
	ttmuud alias for $10;
	tnPakettId alias for $11;
	tnObjektId alias for $12;
	lnleping1Id int;
	lnId int; 
	lrCurRec record;
begin

if tnId = 0 then
	-- uus kiri
	insert into leping1 (asutusid,rekvid,doklausid,pakettid, objektId, number,kpv,tahtaeg,selgitus,dok,muud) 
		values (tnasutusid,tnrekvid,tndoklausid,tnPakettId, tnObjektId, tcnumber,tdkpv,tdtahtaeg,ttselgitus,ttdok,ttmuud);


	GET DIAGNOSTICS lnId = ROW_COUNT;

	if lnId > 0 then
		lnleping1Id:= cast(CURRVAL('public.leping1_id_seq') as int4);
	else
		lnleping1Id = 0;
	end if;

	if lnleping1Id = 0 then
		raise exception 'Viga:%','Ei saa lisada kiri';
	end if;

else
	-- muuda 
	select * into lrCurRec from leping1 where id = tnId;
	if lrCurRec.asutusid <> tnasutusid or lrCurRec.rekvid <> tnrekvid or lrCurRec.doklausid <> tndoklausid or lrCurRec.number <> tcnumber or 
		lrCurRec.kpv <> tdkpv or ifnull(lrCurRec.tahtaeg,date(1900,01,01)) <> ifnull(tdtahtaeg,date(1900,01,01)) or lrCurRec.selgitus <> ttselgitus 
		or ifnull(lrCurRec.dok,space(1)) <> ifnull(ttdok,space(1)) or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) 
		or lrCurRec.pakettid <> tnpakettId or  lrCurRec.objektid <> tnobjektid then 
	update leping1 set 
		asutusid = tnasutusid,
		rekvid = tnrekvid,
		doklausid = tndoklausid,
		pakettid = tnPakettid,
		objektid = tnObjektid,
		number = tcnumber,
		kpv = tdkpv,
		tahtaeg = tdtahtaeg,
		selgitus = ttselgitus,
		dok = ttdok,
		muud = ttmuud
	where id = tnId;
	end if;
	lnleping1Id := tnId;
end if;

         return  lnleping1Id;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_leping1(integer, integer, integer, integer, character, date, date, text, text, text, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_leping1(integer, integer, integer, integer, character, date, date, text, text, text, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_leping1(integer, integer, integer, integer, character, date, date, text, text, text, integer, integer) TO dbpeakasutaja;

-- Function: sp_salvesta_leping3(integer, integer, date, numeric, numeric, text)

-- DROP FUNCTION sp_salvesta_leping3(integer, integer, date, numeric, numeric, text);

CREATE OR REPLACE FUNCTION sp_salvesta_leping3(integer, integer, date, numeric, numeric, text)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnparentid alias for $2;
	tdkpv alias for $3;
	tnalgkogus alias for $4;
	tnloppkogus alias for $5;
	ttmuud alias for $6;
	lnleping3Id int;
	lnId int; 
	lrCurRec record;
begin

if tnId = 0 then
	-- uus kiri
	insert into leping3 (parentid,kpv,algkogus,loppkogus,muud) 
		values (tnparentid,tdkpv,tnalgkogus,tnloppkogus,ttmuud);

	lnleping3Id:= cast(CURRVAL('public.leping3_id_seq') as int4);

else
	-- muuda 
	select * into lrCurRec from leping3 where id = tnId;
	if lrCurRec.parentid <> tnparentid or lrCurRec.kpv <> tdkpv or lrCurRec.algkogus <> tnalgkogus or lrCurRec.loppkogus <> tnloppkogus or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1)) then 
	update leping3 set 
		parentid = tnparentid,
		kpv = tdkpv,
		algkogus = tnalgkogus,
		loppkogus = tnloppkogus,
		muud = ttmuud
	where id = tnId;
	end if;
	lnleping3Id := tnId;
end if;

         return  lnleping3Id;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_leping3(integer, integer, date, numeric, numeric, text) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_leping3(integer, integer, date, numeric, numeric, text) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_leping3(integer, integer, date, numeric, numeric, text) TO dbpeakasutaja;

CREATE OR REPLACE  FUNCTION sp_salvesta_objekt(integer, integer, character varying, character varying, text, integer, integer, integer, integer, integer,
	integer,integer, integer, numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,text)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnrekvid alias for $2;
	tcKood alias for $3;
	tcNimetus alias for $4;
	ttMuud alias for $5;
	tnTun1 alias for $6;
	tnTun2 alias for $7;
	tntun3 alias for $8;
	tntun4 alias for $9;
	tnTun5 alias for $10;
	tnLibId alias for $11;
	tnParentId alias for $12;
	tnAsutusid alias for $13;
	tnNait01 alias for $14;
	tnNait02 alias for $15;
	tnNait03 alias for $16;
	tnNait04 alias for $17;
	tnNait05 alias for $18;
	tnNait06 alias for $19;
	tnNait07 alias for $20;
	tnNait08 alias for $21;
	tnNait09 alias for $22;
	tnNait10 alias for $23;
	tnNait11 alias for $24;
	tnNait12 alias for $25;
	tnNait13 alias for $26;
	tnNait14 alias for $27;
	tnNait15 alias for $28;
	ttSelg alias for $29;

	lcLibrary varchar(20);

	lnId int; 
	lrCurRec record;
begin
	if tnId = 0 then
		lcLibrary = 'OBJEKT';
	else
		select library into lcLibrary from library where id = tnId;
	end if;

	lnId = sp_salvesta_library(tnId, tnRekvId, tcKood, tcNimetus, lcLibrary, ttMuud, tnTun1, tnTun2, tnTun3, tnTun4, tnTun5);

	if (select count(id) from objekt where libid = lnId) = 0 then
			-- lisame uus kiri
		insert into objekt (parentid, libid, asutusid, nait01, nait02, nait03, nait04, nait05, nait06, nait07, nait08, nait09, nait10,nait11, nait12, nait13, nait14, nait15, muud)
			values (tnParentId, lnId, tnAsutusId, tnnait01,tnnait02,tnnait03,tnnait04, tnnait05,tnnait06,tnnait07,tnnait08,tnnait09,tnnait10,
			tnnait11,tnnait12,tnnait13,tnnait14,tnnait15,ttMuud);
	else
		update objekt set
			parentid = tnParentId,
			libid = lnId,
			asutusid = tnAsutusId,
			nait01 = tnnait01,
			nait02 = tnnait02,
			nait03 = tnnait03,
			nait04 = tnnait04,
			nait05 = tnnait05,
			nait06 = tnnait06,
			nait07 = tnnait07,
			nait08 = tnnait08,
			nait09 = tnnait09,
			nait10 = tnnait10,
			nait11 = tnnait11,
			nait12 = tnnait12,
			nait13 = tnnait13,
			nait14 = tnnait14,
			nait15 = tnnait15,
			muud = ttMuud
		where libid = lnId;

	end if;


         return  lnId;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;

ALTER FUNCTION sp_salvesta_objekt(integer, integer, character varying, character varying,  text, integer, integer, integer, integer, integer,
	integer,integer, integer, numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,text) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_objekt(integer, integer, character varying, character varying,  text, integer, integer, integer, integer, integer,
	integer,integer, integer, numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,text) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_objekt(integer, integer, character varying, character varying,  text, integer, integer, integer, integer, integer,
	integer,integer, integer, numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,text) TO dbpeakasutaja;



CREATE OR REPLACE  FUNCTION sp_salvesta_pakett(integer, integer,integer,numeric,numeric,integer,text)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;
	tnLibid alias for $2;
	tnNomId alias for $3;
	tnHind alias for $4;
	tnKogus alias for $5;
	tnStatus alias for $6;
	ttFormula alias for $7;


	lnId int; 
	lrCurRec record;
begin

	if tnId = 0 then
			-- lisame uus kiri
		insert into pakett (libid, nomid, hind, kogus,status, formula)
			values (tnLibId, tnNomId, tnHind, tnKogus,tnStatus,ttFormula);
	else
		update pakett set
			nomid = tnNomId,
			libid = tnLibId,
			hind = tnHind,
			kogus = tnKogus,
			status = tnStatus,
			formula = ttFormula
		where id = tnId;

	end if;


         return  tnId;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_salvesta_pakett(integer, integer,integer,numeric,numeric,integer,text) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_salvesta_pakett(integer, integer,integer,numeric,numeric,integer,text) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_salvesta_pakett(integer, integer,integer,numeric,numeric,integer,text) TO dbpeakasutaja;


-- Function: sp_tasuarv(integer, integer, integer, date, numeric, integer, integer)

-- DROP FUNCTION sp_tasuarv(integer, integer, integer, date, numeric, integer, integer);

CREATE OR REPLACE FUNCTION sp_tasuarv(integer, integer, integer, date, numeric, integer, integer)
  RETURNS numeric AS
$BODY$declare 
	tnDokId alias for 	$1;
	tnArvId alias for 	$2; 
	tnRekvId alias for 	$3; 
	tdkpv	 alias for 	$4; 
	tnSumma  alias for 	$5; 
	tnDokTyyp alias for 	$6; 
	tnNomId	  alias for 	$7;
	lnArvSumma numeric (12,4);
	lnTasuSumma numeric (12,4);
	lnJaak numeric (12,4);
	lnId int;
	lcKonto varchar(20);
	qryArv record;
	lnKuurs numeric (14,4);
	lcValuuta varchar(20);
	lcDok varchar(20);

begin
	lnArvSumma := 0;
	lnTasuSumma := 0;
	lnJaak := 0;
-- KUSTUTA VANA TASU INF
	delete FROM Arvtasu WHERE Arvtasu.sorderid = tnDokId and arvId = tnArvId ;
-- uus kiri		
	select dokprop.konto, arv.liik into qryArv from dokprop inner join arv on arv.doklausid = dokprop.id where arv.id = tnArvId;

	qryArv.Konto := ifnull(qryArv.Konto,space(20));
	if tnDokTyyp = 2 then
		-- kassa order
		select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
			from korder2 left outer join dokvaluuta1 on (korder2.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 11)
			where korder2.parentid = tnDokId;

		select dokvaluuta1.kuurs, dokvaluuta1.valuuta into lnKuurs, lcValuuta
			from dokvaluuta1 where dokid = tnDokId and dokliik = 10;

		select number into lcDok from korder1 where id 	= tnDokId;
			
	else

	
		if tnDokTyyp = 1 then
			select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
				from mk1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = mk1.id and dokvaluuta1.dokliik = 4) 
				where mk1.parentid = tnDokId;

			select dokvaluuta1.kuurs, dokvaluuta1.valuuta into lnKuurs, lcValuuta
				from dokvaluuta1 
				where dokid in (select id from mk1 where parentid = tnDokId order by id desc limit 1) 
				and dokliik = 4;

			select number into lcDok from mk where id 	= tnDokId;

		else
			if qryArv.liik = 0 then
				select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
				from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
				where journal1.parentid = tnDokId and kreedit = qryArv.konto;
			else
				select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
				from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1) 
				where journal1.parentid = tnDokId and deebet = qryArv.konto;
			end if;

			select dokvaluuta1.kuurs, dokvaluuta1.valuuta into lnKuurs, lcValuuta
				from dokvaluuta1 
				where dokid in (select id from journal1 where parentid = tnDokId order by id desc limit 1)    
				and dokliik = 1;

			select str(number)::varchar into lcDok from journalid where journalid 	= tnDokId;

			
		end if;
		-- kreedit arve
		if ifnull(lnTasuSumma,0) = 0 then
			raise notice 'kreedit arve';
			--kontrollime kas on kreedit arve
			select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnArvSumma 
				from arv1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = arv1.id and dokvaluuta1.dokliik = 2) 
				where arv1.parentid = tnArvId;
			if ifnull(lnArvSumma,0) < 0 then
				raise notice 'lnArvSumma: %',lnArvSumma;
				-- kreedit arve
				if qryArv.liik = 0 then
					select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
						from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
						where parentid = tnDokId and deebet = qryArv.konto;
				else
					select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
						from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
						where parentid = tnDokId and kreedit = qryArv.konto;
				end if;

				select dokvaluuta1.kuurs, dokvaluuta1.valuuta into lnKuurs, lcValuuta
					from dokvaluuta1 
					where dokid in (select id from journal1 where parentid = tnDokId order by id desc limit 1)    
					and dokliik = 1;

				select str(number)::varchar into lcDok from journalid where journalid 	= tnDokId;
				
			end if;			
		end if;

	end if;
	lnTasuSumma := ifnull(lnTasuSumma,0);
	raise notice 'arvtasu SUMMA: %',lnTasuSumma;

	lcValuuta = ifnull(lcValuuta,'EEK');
	lnKuurs = ifnull(lnKuurs,1);

	lcDok = ifnull(lcDok,'');
	
	insert into arvtasu (rekvId, arvId, kpv, summa, sorderId, pankKassa, nomId, dok) values
	(tnRekvId, tnArvId, tdKpv, lnTasuSumma, tnDokId, tnDokTyyp, tnNomId, lcDok);
	lnId:= cast(CURRVAL('public.arvtasu_id_seq') as int4);

	--valuuta

	insert into dokvaluuta1 (dokliik,dokid, valuuta, kuurs) 
		values (21, lnId,lcValuuta, lnKuurs);

	raise notice 'arvtasu id: %',lnId;
	return sp_updateArvJaak(tnArvId, tdKpv);


end; 

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_tasuarv(integer, integer, integer, date, numeric, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_tasuarv(integer, integer, integer, date, numeric, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_tasuarv(integer, integer, integer, date, numeric, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_tasuarv(integer, integer, integer, date, numeric, integer, integer) TO dbpeakasutaja;


-- Function: sp_tasuarv(integer, integer, integer, date, numeric, integer, integer)

-- DROP FUNCTION sp_tasuarv(integer, integer, integer, date, numeric, integer, integer);

CREATE OR REPLACE FUNCTION sp_tasuarv(integer, integer, integer, date, numeric, integer, integer)
  RETURNS numeric AS
$BODY$declare 
	tnDokId alias for 	$1;
	tnArvId alias for 	$2; 
	tnRekvId alias for 	$3; 
	tdkpv	 alias for 	$4; 
	tnSumma  alias for 	$5; 
	tnDokTyyp alias for 	$6; 
	tnNomId	  alias for 	$7;
	lnArvSumma numeric (12,4);
	lnTasuSumma numeric (12,4);
	lnJaak numeric (12,4);
	lnId int;
	lcKonto varchar(20);
	qryArv record;
	lnKuurs numeric (14,4);
	lcValuuta varchar(20);
	lcDok varchar(20);

begin
	lnArvSumma := 0;
	lnTasuSumma := 0;
	lnJaak := 0;
-- KUSTUTA VANA TASU INF
	delete FROM Arvtasu WHERE Arvtasu.sorderid = tnDokId and arvId = tnArvId ;
-- uus kiri		
	select dokprop.konto, arv.liik, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta into qryArv 
		from dokprop inner join arv on arv.doklausid = dokprop.id 
		left outer join dokvaluuta1 on (dokvaluuta1.dokid = arv.id and dokvaluuta1.dokliik = 3)
		where arv.id = tnArvId;

	qryArv.Konto := ifnull(qryArv.Konto,space(20));
	if tnDokTyyp = 2 then
		-- kassa order
		select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
			from korder2 left outer join dokvaluuta1 on (korder2.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 11)
			where korder2.parentid = tnDokId;

		select dokvaluuta1.kuurs, dokvaluuta1.valuuta into lnKuurs, lcValuuta
			from dokvaluuta1 where dokid = tnDokId and dokliik = 10;

		select number into lcDok from korder1 where id 	= tnDokId;
			
	else

	
		if tnDokTyyp = 1 then
			select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
				from mk1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = mk1.id and dokvaluuta1.dokliik = 4) 
				where mk1.parentid = tnDokId;

			select dokvaluuta1.kuurs, dokvaluuta1.valuuta into lnKuurs, lcValuuta
				from dokvaluuta1 
				where dokid in (select id from mk1 where parentid = tnDokId order by id desc limit 1) 
				and dokliik = 4;

			select number into lcDok from mk where id 	= tnDokId;

		else
			if qryArv.liik = 0 then
				select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
				from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
				where journal1.parentid = tnDokId and kreedit = qryArv.konto;
			else
				select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
				from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1) 
				where journal1.parentid = tnDokId and deebet = qryArv.konto;
			end if;

			select dokvaluuta1.kuurs, dokvaluuta1.valuuta into lnKuurs, lcValuuta
				from dokvaluuta1 
				where dokid in (select id from journal1 where parentid = tnDokId order by id desc limit 1)    
				and dokliik = 1;

			select str(number)::varchar into lcDok from journalid where journalid 	= tnDokId;

			
		end if;
		-- kreedit arve
		if ifnull(lnTasuSumma,0) = 0 then
			raise notice 'kreedit arve';
			--kontrollime kas on kreedit arve
			select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnArvSumma 
				from arv1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = arv1.id and dokvaluuta1.dokliik = 2) 
				where arv1.parentid = tnArvId;
			if ifnull(lnArvSumma,0) < 0 then
				raise notice 'lnArvSumma: %',lnArvSumma;
				-- kreedit arve
				if qryArv.liik = 0 then
					select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
						from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
						where parentid = tnDokId and deebet = qryArv.konto;
				else
					select sum(summa * ifnull(dokvaluuta1.kuurs,1)) into lnTasuSumma 
						from journal1 left outer join dokvaluuta1 on (dokvaluuta1.dokid = journal1.id and dokvaluuta1.dokliik = 1)
						where parentid = tnDokId and kreedit = qryArv.konto;
				end if;

				select dokvaluuta1.kuurs, dokvaluuta1.valuuta into lnKuurs, lcValuuta
					from dokvaluuta1 
					where dokid in (select id from journal1 where parentid = tnDokId order by id desc limit 1)    
					and dokliik = 1;

				select str(number)::varchar into lcDok from journalid where journalid 	= tnDokId;
				
			end if;			
		end if;

	end if;

	lcValuuta = ifnull(lcValuuta,'EEK');
	lnKuurs = ifnull(lnKuurs,1);

	lnTasuSumma := ifnull(lnTasuSumma,0) / qryArv.Kuurs;
	raise notice 'arvtasu SUMMA: %',lnTasuSumma;


	lcDok = ifnull(lcDok,'');
	
	insert into arvtasu (rekvId, arvId, kpv, summa, sorderId, pankKassa, nomId, dok) values
	(tnRekvId, tnArvId, tdKpv, lnTasuSumma, tnDokId, tnDokTyyp, tnNomId, lcDok);
	lnId:= cast(CURRVAL('public.arvtasu_id_seq') as int4);

	--valuuta

	insert into dokvaluuta1 (dokliik,dokid, valuuta, kuurs) 
		values (21, lnId,qryArv.Valuuta, qryArv.Kuurs);

	raise notice 'arvtasu id: %',lnId;
	return sp_updateArvJaak(tnArvId, tdKpv);


end; 

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_tasuarv(integer, integer, integer, date, numeric, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_tasuarv(integer, integer, integer, date, numeric, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_tasuarv(integer, integer, integer, date, numeric, integer, integer) TO dbpeakasutaja;

-- Function: sp_updatearvjaak(integer, date)

-- DROP FUNCTION sp_updatearvjaak(integer, date);

CREATE OR REPLACE FUNCTION sp_updatearvjaak(integer, date)
  RETURNS numeric AS
$BODY$
declare tnArvId alias for 	$1; 	
	tdKpv alias for 	$2; 	
	lnArvSumma numeric (12,4);
	lnTasuSumma numeric (12,4);
	lnJaak numeric (12,4);
	ldKpv date;
	v_arvtasu record;
	lnJournalId int;

	lnKuurs numeric(12,4);
begin
/*	lnArvSumma := 0;
	lnTasuSumma := 0;
	lnJaak := 0;
*/
-- kontrollin kas on vigased kirjad
select sorderid into lnJournalid from arvtasu where arvid = tnArvId and pankkassa = 3 order by id desc limit 1;

if ifnull(lnJournalId,0) > 0 then

for v_arvtasu in
	select * from arvtasu where arvid = tnArvId and pankkassa <> 3
	loop
		if v_arvtasu.pankkassa = 1 and (select count(mk1.id) from mk1 inner join mk on mk.id = mk1.parentid 
				where mk1.journalid = lnJournalid and mk.id = v_arvtasu.sorderid) > 0 then
			raise notice 'leitud vigane kiri, kustutan..%',v_arvtasu.id;
			delete from arvtasu where id = v_arvtasu.id;
		end if;
		if v_arvtasu.pankkassa = 2 and (select count(id) from korder1 where journalid = lnJournalid and korder1.id = v_arvtasu.sorderid) > 0 then
			raise notice 'leitud vigane kiri, kustutan..%',v_arvtasu.id;
			delete from arvtasu where id = v_arvtasu.id;
		end if;
	end loop;
end if;

	SELECT (arv.summa * ifnull(dokvaluuta1.kuurs,1))::numeric, ifnull(dokvaluuta1.kuurs,1)  into lnArvSumma , lnKuurs
		FROM arv left outer join dokvaluuta1 on (dokvaluuta1.dokid = arv.id and dokvaluuta1.dokliik = 3) 
		WHERE arv.id = tnArvId ;

	SELECT sum(arvtasu.summa * ifnull(dokvaluuta1.kuurs,1)), max(arvtasu.kpv) into lnTasuSumma, ldKpv 
		FROM arvtasu left outer join dokvaluuta1 on (arvtasu.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 21) 
		WHERE arvtasu.arvId = tnArvId;
		
	lnTasuSumma := ifnull(lnTasuSumma,0);	
	ldKpv := ifnull(ldKpv,tdKpv);	
	lnArvsumma := ifnull(lnArvSumma,0);


	
	if lnArvSumma < 0 then
		-- kreeditarve
		if lnTasuSumma < 0 then
			lnJaak := -1 * ((-1 * lnArvSumma) - (-1 * lnTasuSumma));			
		else
			lnJaak := lnArvSumma + lnTasuSumma;
		end if;
	else
		lnJaak := lnArvSumma - lnTasuSumma;
	end if;
	if lnTasuSumma = 0 then
		ldKpv := null;
	end if;

	lnJaak = lnJaak / lnKuurs; 	

	UPDATE arv SET tasud = ldkpv,
		jaak = lnJaak  WHERE id = tnArvId;		

	return lnJaak;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_updatearvjaak(integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_updatearvjaak(integer, date) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_updatearvjaak(integer, date) TO dbpeakasutaja;

-- Function: sp_update_arv_jaak(integer)

-- DROP FUNCTION sp_update_arv_jaak(integer);

CREATE OR REPLACE FUNCTION sp_update_arv_jaak(integer)
  RETURNS numeric AS
$BODY$
declare 
	tnId alias for $1;
	lnJaak numeric;
	lnSumma numeric;
	v_arv record;
	ldTasud date;

begin
-- arv jaak
	select arv.summa * ifnull(dokvaluuta1.kuurs,1) , arv.tasud, arv.jaak, ifnull(dokvaluuta1.kuurs,1) into v_arv  from arv left outer join dokvaluuta1 on (arv.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 3) where arv.id = tnId;
	
-- tasu summa 	
	SELECT sum(Arvtasu.summa * ifnull(dokvaluuta1.kuurs,1)) into lnsumma FROM Arvtasu left outer join dokvaluuta1 on (arvtasu.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 21)
		WHERE Arvtasu.arvid = tnId;
		
	lnJaak := ifnull(v_arv.summa,0) - ifnull(lnSumma,0) / v_arv.kuurs;
	if lnJaak <> ifnull(v_arv.jaak,0) then
		-- uuendame tasu info

		select kpv into ldTasud from arvtasu where arvid = tnId order by kpv desc limit 1;
		update arv set jaak = lnJaak, tasud = ldTasud where id = tnId;
 
	end if;
	
        return  lnJaak;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_update_arv_jaak(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_update_arv_jaak(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_update_arv_jaak(integer) TO dbpeakasutaja;

-- Function: sp_recalcarvjaak(integer)

-- DROP FUNCTION sp_recalcarvjaak(integer);

CREATE OR REPLACE FUNCTION sp_recalcarvjaak(integer)
  RETURNS numeric AS
$BODY$
declare tnArvId alias for 	$1;
	tmpArv record;	
	tmpSorder record;
	tmpVorder record;
	tmpSMK record;
	tmpVMK record;
	tmpJournal record;

	lnSumma numeric (12,4);
	lcArvKonto varchar(20);
	lctasuKonto varchar(20);
begin
-- arv prop

	Select * into tmpARV From arv Where Id = tnArvId ;

-- delete from arvtasu

	Delete From arvtasu Where arvid = tnArvId;

-- check for kassa

	for tmpSorder in 
	Select * From korder1 WHERE arvid = tnArvId And tyyp = 1 and rekvid = tmpArv.rekvid 
	loop
		if tmpARV.liik = 0 then
		
			lnSumma := tmpSorder.Summa;
		else
			lnSumma := -1 * tmpSorder.Summa;
		end if;

		Insert Into arvtasu (arvid, rekvid, kpv, pankkassa, sorderid, Summa) Values 
			(tnArvId, tmpARV.rekvid, tmpSorder.kpv, 1, tmpSorder.Id, lnSumma);

	end loop;

	for tmpvorder in
	Select * From korder1 WHERE arvid = tnArvId And tyyp = 2 and rekvid = tmpArv.rekvid
	loop
		if tmpARV.liik = 1 then

			lnSumma := tmpvorder.Summa;
		else
			lnSumma := -1 * tmpvorder.Summa;
		end if;

		Insert Into arvtasu (arvid, rekvid, kpv, pankkassa, sorderid, Summa) Values 
				(tnArvId, tmpARV.rekvid, tmpvorder.kpv, 1, tmpvorder.Id, lnSumma);

	end loop;


-- check for pank

	
	for tmpSMk in 
		Select mk.*, mk1.summa From mk inner join mk1 on mk.id = mk1.parentid 
			Where mk.arvid = tnArvId And mk.opt = 0 and mk1.asutusId = tmpArv.asutusId and mk.rekvid = tmpArv.rekvid
	loop

		if tmpARV.liik = 0 then


			lnSumma := tmpSMk.Summa;
		else
			lnSumma := -1 * tmpSMk.Summa;
		end if;
		Insert Into arvtasu (arvid, rekvid, kpv, pankkassa, sorderid, Summa) Values 
			(tnArvId, tmpARV.rekvid, tmpSMk.kpv, 1, tmpSMk.Id, lnSumma);

	end loop;

	for tmpVMk in
		Select mk.*, mk1.summa From mk inner join mk1 on mk.id = mk1.parentid 
			Where mk.arvid = tnArvId And mk.opt = 1 and mk1.asutusId = tmpArv.asutusId and mk.rekvid = tmpArv.rekvid
	loop
		if tmpARV.liik = 1 then
			lnSumma := tmpVMk.Summa;
		else
			lnSumma :=  -1 * tmpVMk.Summa;
		end if;
		Insert Into arvtasu (arvid, rekvid, kpv, pankkassa, sorderid, Summa) Values 
				(tnArvId, tmpARV.rekvid, tmpVMk.kpv, 1, tmpVMk.Id, lnSumma);

	end loop;
	

-- lausend

	If tmpARV.doklausId > 0 then

		raise notice 'lausend';

		Select konto Into lcArvKonto From dokprop Where Id = tmpARV.doklausId; 


		If tmpARV.liik = 0 then
			raise notice 'tmpARV.liik %',tmpARV.liik;
			raise notice 'tmpARV.asutusid %',tmpARV.asutusid;
			raise notice 'tmpARV.Number %',tmpARV.Number;

			if tmpArv.journalId > 0 then
				-- kontrollime arve konto
				select deebet into lctasukonto from journal1 where parentid = tmpArv.journalid order by id limit 1;
				if lcArvKonto <> lctasukonto then
					-- arve dokprop oli vigane, vahetame arve konto
					lcArvKonto := lctasukonto;
				end if;
			end if;

			for tmpJournal in
			Select Sum(curJournal.Summa) As Summa, Max(curJournal.kpv) As kpv, curJournal.Id  From curJournal
				where curJournal.asutusId = tmpARV.asutusId 
				AND Alltrim(curJournal.dok) = tmpARV.Number 
				AND curJournal.rekvid = tmpARV.rekvid
				AND curJournal.kreedit = lcArvKonto
				GROUP By curJournal.Id
			loop
				raise notice 'tmpJournal.Id %',tmpJournal.Id;

				Insert Into arvtasu (arvid, rekvid, kpv, pankkassa, sorderid, Summa) Values 
					(tnArvId, tmpARV.rekvid, tmpJournal.kpv, 3, tmpJournal.Id, tmpJournal.Summa);

			end loop;
		Else
			raise notice 'tmpARV.liik %',tmpARV.liik;
				-- kontrollime arve konto
			select kreedit into lctasukonto from journal1 where parentid = tmpArv.journalid order by id limit 1;
			if lcArvKonto <> lctasukonto then
				-- arve dokprop oli vigane, vahetame arve konto
				lcArvKonto := lctasukonto;
			end if;

			for tmpJournal in 
			Select Sum(curJournal.Summa) As Summa, Max(curJournal.kpv) as kpv, curJournal.Id From curJournal
				where curJournal.asutusId = tmpARV.asutusId 
				AND Alltrim(curJournal.dok) = tmpARV.Number 
				AND curJournal.rekvid = tmpARV.rekvid
				AND curJournal.deebet = lcArvKonto
				GROUP By curJournal.Id


			loop
				raise notice 'tmpJournal.Id %',tmpJournal.Id;
				Insert Into arvtasu (arvid, rekvid, kpv, pankkassa, sorderid, Summa) Values 
					(tnArvId, tmpARV.rekvid, tmpJournal.kpv, 3, tmpJournal.Id, tmpJournal.Summa);

			end loop;

		End if;

		

	End if;

	Return sp_updatearvjaak(tmpARV.Id,date());

end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_recalcarvjaak(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_recalcarvjaak(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_recalcarvjaak(integer) TO dbpeakasutaja;




