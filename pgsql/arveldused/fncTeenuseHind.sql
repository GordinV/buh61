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
