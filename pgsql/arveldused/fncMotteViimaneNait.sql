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
