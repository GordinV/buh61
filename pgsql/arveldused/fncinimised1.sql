-- Function: fncinimised(integer, integer)
/*

select fncinimised(41400, 2, '111')

select * from library where kood like 'Ranna 29%'
select * from tmp_fnc_selg where timestamp = '111'


*/


-- DROP FUNCTION fncinimised(integer, integer);

CREATE OR REPLACE FUNCTION fncinimised(integer, integer, varchar)
  RETURNS numeric AS
$BODY$


DECLARE tnObjektId alias for $1;
	tnUhis alias for $2;
	tcReturn alias for $3;


	lnKogus numeric;
	lnParentObjektId integer;
	lcTanav varchar(120);

begin	
/*
tmp_fnc_selg
	(
	id serial NOT NULL,
	nimetus character varying(254) NOT NULL DEFAULT space(1),
	summa01 numeric(14,2) NOT NULL DEFAULT 0,
	summa02 numeric(14,2) NOT NULL DEFAULT 0,
	summa03 numeric(14,2) NOT NULL DEFAULT 0,
	summa04 numeric(14,2) NOT NULL DEFAULT 0,
	summa05 numeric
*/
	lnKogus = 0;

	delete from tmp_fnc_selg where kpv < date();
--lcreturn := ltrim(rtrim(str(tnrekvId)))+to_char(now(), 'YYYYMMDDMISSSS');
	if tnUhis = 0 then
		select nait02 into lnKogus
			from objekt where libid = tnObjektId;
			
		insert into tmp_fnc_selg (kpv, rekvid, timestamp, nimetus, summa01)
			select date(), 1, tcReturn, library.nimetus, nait02 
				from objekt inner join library on library.id = objekt.libid 
				where libid = tnObjektId;

	end if;
	if tnUhis = 1 then

	--otsime parent objekt
			
		select objekt.parentid into lnParentObjektId from objekt where libid = tnObjektId;
		lnParentObjektId = ifnull(lnParentObjektId,0);

--		raise notice 'Parent %',lnParentObjektId;
		
		select sum(nait02) into lnKogus
			from objekt
			where objekt.libid = lnParentObjektId;

		insert into tmp_fnc_selg (kpv, rekvid, timestamp, nimetus, summa01)
			select date(), 1, tcReturn, library.nimetus, nait02 
				from objekt inner join library on library.id = objekt.libid 
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
				where library = 'OBJEKT' and parentid = lnParentObjektId and library.tun1 = 1)
				and objekt.libid not in (select tun2 from library where tun1 = 1 )
				and objekt.nait06 = 1;


		insert into tmp_fnc_selg (kpv, rekvid, timestamp, nimetus, summa01)
			select date(), 1, tcReturn, library.nimetus, nait02 
				from objekt inner join library on library.id = objekt.libid 
				where objekt.libid in (select library.id from library INNER join objekt on library.id = objekt.libid 
					where library = 'OBJEKT' and parentid = lnParentObjektId and library.tun1 = 1)
					and objekt.libid not in (select tun2 from library where tun1 = 1 )
					and objekt.nait06 = 1;


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
				and objekt.libid not in (select tun2 from library where tun1 = 1 )
				and objekt.nait06 = 1;


		insert into tmp_fnc_selg (kpv, rekvid, timestamp, nimetus, summa01)
			select date(), 1, tcReturn, library.nimetus, nait02 
				from objekt inner join library on library.id = objekt.libid 
				where objekt.libid in (select library.id from library INNER join objekt on library.id = objekt.libid 
				where library = 'OBJEKT' and upper(library.kood) like upper(lcTanav) and nait14 = lnParentObjektId)
				and objekt.libid not in (select tun2 from library where tun1 = 1 )
				and objekt.nait06 = 1;


	end if;

	lnKogus = ifnull(lnKogus,0);



	return lnKogus;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fncinimised(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fncinimised(integer, integer, varchar) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION fncinimised(integer, integer, varchar) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fncinimised(integer, integer, varchar) TO dbvaatleja;
